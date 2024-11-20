#import "KeyboardViewController.h"
#import "ShowMsg.h"

@interface KeyboardViewController()<Epos2KbdKeyPressDelegate, Epos2ConnectionDelegate>
@end

@implementation KeyboardViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        keyboard_ = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setDoneToolbar];

    _textKeyboard.text = @"";
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
}

- (void)doneKeyboard:(id)sender
{
    [_textTarget resignFirstResponder];
}

- (IBAction)connectProcess:(id)sender
{
    if (![self initializeObject]) {
        return;
    }

    if (![self connectKeyboard]) {
        return;
    }

    _buttonConnect.enabled = NO;
}
- (IBAction)disconnectProcess:(id)sender
{
    [self disconnectKeyboard];

    [self finalizeObject];

    _buttonConnect.enabled = YES;
}

- (BOOL)initializeObject
{
    if (keyboard_ != nil) {
        [self finalizeObject];
    }

    keyboard_ = [[Epos2Keyboard alloc] init];
    if (keyboard_ == nil) {
        [ShowMsg showErrorEpos:EPOS2_ERR_MEMORY method:@"init"];
        return NO;
    }

    [keyboard_ setKeyPressEventDelegate:self];
    [keyboard_ setConnectionEventDelegate:self];

    return YES;
}

- (void)finalizeObject
{
    if (keyboard_ == nil) {
        return;
    }

    [keyboard_ setKeyPressEventDelegate:nil];
    [keyboard_ setConnectionEventDelegate:nil];

    keyboard_ = nil;
}

- (BOOL)connectKeyboard
{
    int result = EPOS2_SUCCESS;

    if (keyboard_ == nil) {
        return NO;
    }

    result = [keyboard_ connect:_textTarget.text timeout:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"connect"];
        [self finalizeObject];
        return NO;
    }
    isConnect_ = YES;

    return YES;
}

- (void)disconnectKeyboard
{
    int result = EPOS2_SUCCESS;

    if (keyboard_ == nil) {
        return;
    }

    if(isConnect_ == YES) {
        result = [keyboard_ disconnect];
        if (result != EPOS2_SUCCESS) {
            isConnect_ = NO;
            
            [ShowMsg showErrorEpos:result method:@"disconnect"];
        }
    }
    else {
        return;
    }
}

- (void)onKbdKeyPress:(Epos2Keyboard *)keyboardObj keyCode:(int)keyCode ascii:(NSString *)ascii
{
    NSString *CR = @"\n";

    switch (keyCode) {
        case EPOS2_VK_RETURN:
            _textKeyboard.text = [_textKeyboard.text stringByAppendingString:CR];
            break;
        default:
            _textKeyboard.text = [_textKeyboard.text stringByAppendingString:ascii];
            break;
    }

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

- (IBAction)clearKeyboard:(id)sender
{
    _textKeyboard.text = @"";
}

- (void)scrollText
{
    NSRange range;
    range = _textKeyboard.selectedRange;
    range.location = _textKeyboard.text.length;
    _textKeyboard.selectedRange = range;
    _textKeyboard.scrollEnabled = YES;

    CGFloat scrollY = _textKeyboard.contentSize.height + _textKeyboard.font.pointSize - _textKeyboard.bounds.size.height;
    CGPoint scrollPoint;

    if (scrollY < 0) {
        scrollY = 0;
    }

    scrollPoint = CGPointMake(0.0, scrollY);

    [_textKeyboard setContentOffset:scrollPoint animated:YES];
}

@end
