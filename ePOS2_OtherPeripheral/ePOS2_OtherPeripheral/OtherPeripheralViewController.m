#import "OtherPeripheralViewController.h"
#import "ShowMsg.h"

@interface OtherPeripheralViewController()<Epos2OtherReceiveDelegate, Epos2ConnectionDelegate>
@end

@implementation OtherPeripheralViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        other_ = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _textSendCommand.layer.borderWidth = 0.2f;
    _textSendCommand.layer.cornerRadius = 5.0f;
    
    [self setDoneToolbar];

    _textOtherPeripheral.text = @"";
    isConnect_ = NO;
}

- (void)setDoneToolbar
{
    UIToolbar *doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    
    [doneToolbar sizeToFit];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneOtherPeripheral:)];
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects:space, doneButton, nil];
    [doneToolbar setItems:items animated:YES];
    _textTarget.inputAccessoryView = doneToolbar;
    _textMethodName.inputAccessoryView = doneToolbar;
    _textSendCommand.inputAccessoryView = doneToolbar;
}

- (void)doneOtherPeripheral:(id)sender
{
    [_textTarget resignFirstResponder];
    [_textMethodName resignFirstResponder];
    [_textSendCommand resignFirstResponder];
}

- (IBAction)connectProcess:(id)sender
{
    if (![self initializeObject]) {
        return;
    }

    if (![self connectOtherPeripheral]) {
        return;
    }

    _buttonConnect.enabled = NO;
}
- (IBAction)disconnectProcess:(id)sender
{
    [self disconnectOtherPeripheral];

    [self finalizeObject];

    _buttonConnect.enabled = YES;
}

- (BOOL)initializeObject
{
    if (other_ != nil) {
        [self finalizeObject];
    }

    other_ = [[Epos2OtherPeripheral alloc] init];
    if (other_ == nil) {
        [ShowMsg showErrorEpos:EPOS2_ERR_MEMORY method:@"init"];
        return NO;
    }

    [other_ setReceiveEventDelegate:self];
    [other_ setConnectionEventDelegate:self];

    return YES;
}

- (void)finalizeObject
{
    if (other_ == nil) {
        return;
    }
    
    [other_ setReceiveEventDelegate:nil];
    [other_ setConnectionEventDelegate:nil];

    other_ = nil;
}

- (BOOL)connectOtherPeripheral
{
    int result = EPOS2_SUCCESS;

    if (other_ == nil) {
        return NO;
    }

    result = [other_ connect:_textTarget.text timeout:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"connect"];
        [self finalizeObject];
        return NO;
    }
    isConnect_ = YES;

    return YES;
}

- (void)disconnectOtherPeripheral
{
    int result = EPOS2_SUCCESS;

    if (other_ == nil) {
        return;
    }

    if(isConnect_ == YES) {
        result = [other_ disconnect];
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
    
    if (other_ == nil) {
        return;
    }
    
    result = [other_ sendData:_textMethodName.text data:_textSendCommand.text];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"sendData"];
    }
}

- (void) onOtherReceive:(Epos2OtherPeripheral *)otherObj eventName:(NSString *)eventName data:(NSString *)data
{
    _textOtherPeripheral.text = [_textOtherPeripheral.text stringByAppendingString:[NSString stringWithFormat:@"OnReceive:\n"]];
    _textOtherPeripheral.text = [_textOtherPeripheral.text stringByAppendingString:[NSString stringWithFormat:@"  eventName:%@\n", eventName]];
    _textOtherPeripheral.text = [_textOtherPeripheral.text stringByAppendingString:[NSString stringWithFormat:@"  data:%@\n", data]];
    
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

- (IBAction)clearOtherPeripheral:(id)sender
{
    _textOtherPeripheral.text = @"";
}

- (void)scrollText
{
    NSRange range;
    range = _textOtherPeripheral.selectedRange;
    range.location = _textOtherPeripheral.text.length;
    _textOtherPeripheral.selectedRange = range;
    _textOtherPeripheral.scrollEnabled = YES;

    CGFloat scrollY = _textOtherPeripheral.contentSize.height + _textOtherPeripheral.font.pointSize - _textOtherPeripheral.bounds.size.height;
    CGPoint scrollPoint;

    if (scrollY < 0) {
        scrollY = 0;
    }

    scrollPoint = CGPointMake(0.0, scrollY);

    [_textOtherPeripheral setContentOffset:scrollPoint animated:YES];
}

@end
