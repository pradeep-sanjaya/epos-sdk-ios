#import "POSKeyboardViewController.h"
#import "ShowMsg.h"

@interface POSKeyboardViewController()<Epos2POSKbdKeyPressDelegate, Epos2ConnectionDelegate>
@end

@implementation POSKeyboardViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        poskeyboard_ = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setDoneToolbar];

    _textPOSKeyboard.text = @"";
    isConnect_ = NO;
}

- (void)setDoneToolbar
{
    UIToolbar *doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    
    [doneToolbar sizeToFit];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePOSKeyboard:)];
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects:space, doneButton, nil];
    [doneToolbar setItems:items animated:YES];
    _textTarget.inputAccessoryView = doneToolbar;
}

- (void)donePOSKeyboard:(id)sender
{
    [_textTarget resignFirstResponder];
}

- (IBAction)connectProcess:(id)sender
{
    if (![self initializeObject]) {
        return;
    }

    if (![self connectPOSKeyboard]) {
        return;
    }

    _buttonConnect.enabled = NO;
}
- (IBAction)disconnectProcess:(id)sender
{
    [self disconnectPOSKeyboard];

    [self finalizeObject];

    _buttonConnect.enabled = YES;
}

- (BOOL)initializeObject
{
    if (poskeyboard_ != nil) {
        [self finalizeObject];
    }

    poskeyboard_ = [[Epos2POSKeyboard alloc] init];
    if (poskeyboard_ == nil) {
        [ShowMsg showErrorEpos:EPOS2_ERR_MEMORY method:@"init"];
        return NO;
    }

    [poskeyboard_ setKeyPressEventDelegate:self];
    [poskeyboard_ setConnectionEventDelegate:self];

    return YES;
}

- (void)finalizeObject
{
    if (poskeyboard_ == nil) {
        return;
    }

    [poskeyboard_ setKeyPressEventDelegate:nil];
    [poskeyboard_ setConnectionEventDelegate:nil];

    poskeyboard_ = nil;
}

- (BOOL)connectPOSKeyboard
{
    int result = EPOS2_SUCCESS;

    if (poskeyboard_ == nil) {
        return NO;
    }

    result = [poskeyboard_ connect:_textTarget.text timeout:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"connect"];
        [self finalizeObject];
        return NO;
    }
    isConnect_ = YES;
    return YES;
}

- (void)disconnectPOSKeyboard
{
    int result = EPOS2_SUCCESS;

    if (poskeyboard_ == nil) {
        return;
    }

    if(isConnect_ == YES) {
        result = [poskeyboard_ disconnect];
        if (result != EPOS2_SUCCESS) {
            isConnect_ = NO;
            
            [ShowMsg showErrorEpos:result method:@"disconnect"];
        }
    }
    else {
        return;
    }
}

- (void) onPOSKbdKeyPress:(Epos2POSKeyboard *)poskeyboardObj posKeyCode:(int)posKeyCode;
{
    _textPOSKeyboard.text = [_textPOSKeyboard.text stringByAppendingString:[NSString stringWithFormat:@"KeyCode:%x\n", posKeyCode]];

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

- (IBAction)clearPOSKeyboard:(id)sender
{
    _textPOSKeyboard.text = @"";
}

- (void)scrollText
{
    NSRange range;
    range = _textPOSKeyboard.selectedRange;
    range.location = _textPOSKeyboard.text.length;
    _textPOSKeyboard.selectedRange = range;
    _textPOSKeyboard.scrollEnabled = YES;

    CGFloat scrollY = _textPOSKeyboard.contentSize.height + _textPOSKeyboard.font.pointSize - _textPOSKeyboard.bounds.size.height;
    CGPoint scrollPoint;

    if (scrollY < 0) {
        scrollY = 0;
    }

    scrollPoint = CGPointMake(0.0, scrollY);

    [_textPOSKeyboard setContentOffset:scrollPoint animated:YES];
}

@end
