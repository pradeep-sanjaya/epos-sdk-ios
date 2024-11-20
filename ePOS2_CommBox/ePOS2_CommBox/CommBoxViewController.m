#import "CommBoxViewController.h"
#import "ShowMsg.h"

@interface CommBoxViewController()<Epos2CommBoxReceiveDelegate, Epos2CommBoxSendMessageDelegate, Epos2ConnectionDelegate>
@end

@implementation CommBoxViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        commBox_ = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setDoneToolbar];

    _textCommBox.text = @"";
    _buttonSendData.enabled = NO;
    isConnect_ = NO;
}

- (void)setDoneToolbar
{
    UIToolbar *doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;

    [doneToolbar sizeToFit];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneKeyboard:)];

    NSMutableArray *items = [NSMutableArray arrayWithObjects:space, doneButton, nil];
    [doneToolbar setItems:items animated:YES];
    _textTarget.inputAccessoryView = doneToolbar;
    _textMyID.inputAccessoryView = doneToolbar;
    _textTargetID.inputAccessoryView = doneToolbar;
    _textMessage.inputAccessoryView = doneToolbar;
}

- (void)doneKeyboard:(id)sender
{
    [_textTarget resignFirstResponder];
    [_textMyID resignFirstResponder];
    [_textTargetID resignFirstResponder];
    [_textMessage resignFirstResponder];
}

- (IBAction)connectProcess:(id)sender
{
    if (![self initializeObject]) {
        return;
    }

    if (![self connectCommBox]) {
        return;
    }

    _buttonConnect.enabled = NO;
    _buttonSendData.enabled = YES;
}

- (IBAction)disconnectProcess:(id)sender
{
    [self disconnectCommBox];

    [self finalizeObject];

    _buttonConnect.enabled = YES;
    _buttonSendData.enabled = NO;
}

- (BOOL)initializeObject
{
    if (commBox_ != nil) {
        [self finalizeObject];
    }

    commBox_ = [[Epos2CommBox alloc] init];
    if (commBox_ == nil) {
        [ShowMsg showErrorEpos:EPOS2_ERR_MEMORY method:@"init"];
        return NO;
    }

    [commBox_ setReceiveEventDelegate:self];
    [commBox_ setConnectionEventDelegate:self];

    return YES;
}

- (void)finalizeObject
{
    if (commBox_ == nil) {
        return ;
    }

    [commBox_ setReceiveEventDelegate:nil];
    [commBox_ setConnectionEventDelegate:nil];
    commBox_ = nil;
}

- (BOOL)connectCommBox
{
    int result = EPOS2_SUCCESS;

    if (commBox_ == nil) {
        return NO;
    }

    result = [commBox_ connect:_textTarget.text timeout:EPOS2_PARAM_DEFAULT myId:_textMyID.text];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"connect"];
        [self finalizeObject];
        return NO;
    }
    isConnect_ = YES;

    return YES;
}

- (void)disconnectCommBox
{
    int result = EPOS2_SUCCESS;

    if (commBox_ == nil) {
        return;
    }

    if(isConnect_ == YES) {
        result = [commBox_ disconnect];
        if (result != EPOS2_SUCCESS) {
            isConnect_ = NO;
            
            [ShowMsg showErrorEpos:result method:@"disconnect"];
        }
    }
    else {
        return;
    }
}

- (IBAction)onSendData:(id)sender
{
    int result = EPOS2_SUCCESS;

    if (commBox_ == nil) {
        return;
    }

    result = [commBox_ sendMessage:_textMessage.text targetId:_textTargetID.text delegate:self];
    if (EPOS2_SUCCESS != result) {
        [ShowMsg showErrorEpos:result method:@"sendMessage"];
        return;
    }
}

- (void) onCommBoxReceive:(Epos2CommBox *)commBoxObj senderId:(NSString *)senderId receiverId:(NSString *)receiverId message:(NSString *)message
{
    _textCommBox.text = [_textCommBox.text stringByAppendingString:[NSString stringWithFormat:@"From:%@\t%@\n", senderId, message]];

    [self scrollText];
}

- (void) onConnection:(id)deviceObj eventType:(int)eventType
{
    if(eventType == EPOS2_EVENT_DISCONNECT) {
        isConnect_ = NO;
    }
    else {
        //Do each process.
    }
}

- (IBAction)clearCommBox:(id)sender
{
    _textCommBox.text = @"";
}

- (void) onCommBoxSendMessage:(Epos2CommBox *)commBoxObj code:(int)code count:(long)count
{
    [ShowMsg showResult:code];
}

- (void)scrollText
{
    NSRange range;
    range = _textCommBox.selectedRange;
    range.location = _textCommBox.text.length;
    _textCommBox.selectedRange = range;
    _textCommBox.scrollEnabled = YES;

    CGFloat scrollY = _textCommBox.contentSize.height + _textCommBox.font.pointSize - _textCommBox.bounds.size.height;
    CGPoint scrollPoint;

    if (scrollY < 0) {
        scrollY = 0;
    }

    scrollPoint = CGPointMake(0.0, scrollY);

    [_textCommBox setContentOffset:scrollPoint animated:YES];
}

@end
