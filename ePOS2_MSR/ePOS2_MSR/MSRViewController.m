#import "MSRViewController.h"
#import "ShowMsg.h"

@interface MSRViewController()<Epos2MSRDataDelegate, Epos2ConnectionDelegate>
@end

@implementation MSRViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        msr_ = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setDoneToolbar];

    _textMSR.text = @"";
    isConnect_ = NO;
}

- (void)setDoneToolbar
{
    UIToolbar *doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    
    [doneToolbar sizeToFit];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneMSR:)];
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects:space, doneButton, nil];
    [doneToolbar setItems:items animated:YES];
    _textTarget.inputAccessoryView = doneToolbar;
}

- (void)doneMSR:(id)sender
{
    [_textTarget resignFirstResponder];
}

- (IBAction)connectProcess:(id)sender
{
    if (![self initializeObject]) {
        return;
    }

    if (![self connectMSR]) {
        return;
    }

    _buttonConnect.enabled = NO;
}
- (IBAction)disconnectProcess:(id)sender
{
    [self disconnectMSR];

    [self finalizeObject];

    _buttonConnect.enabled = YES;
}

- (BOOL)initializeObject
{
    if (msr_ != nil) {
        [self finalizeObject];
    }

    msr_ = [[Epos2MSR alloc] init];
    if (msr_ == nil) {
        [ShowMsg showErrorEpos:EPOS2_ERR_MEMORY method:@"init"];
        return NO;
    }

    [msr_ setDataEventDelegate:self];
    [msr_ setConnectionEventDelegate:self];

    return YES;
}

- (void)finalizeObject
{
    if (msr_ == nil) {
        return;
    }

    [msr_ setDataEventDelegate:nil];
    [msr_ setConnectionEventDelegate:nil];

    msr_ = nil;
}

- (BOOL)connectMSR
{
    int result = EPOS2_SUCCESS;

    if (msr_ == nil) {
        return NO;
    }

    result = [msr_ connect:_textTarget.text timeout:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"connect"];
        [self finalizeObject];
        return NO;
    }
    isConnect_ = YES;

    return YES;
}

- (void)disconnectMSR
{
    int result = EPOS2_SUCCESS;

    if (msr_ == nil) {
        return;
    }

    if(isConnect_ == YES) {
        result = [msr_ disconnect];
        if (result != EPOS2_SUCCESS) {
            isConnect_ = NO;
            
            [ShowMsg showErrorEpos:result method:@"disconnect"];
        }
    }
    else {
        return;
    }
}

- (void) onMSRData:(Epos2MSR *)msrObj data:(Epos2MSRData *)data
{
    _textMSR.text = [_textMSR.text stringByAppendingString:[NSString stringWithFormat:@"OnData:\n"]];
    _textMSR.text = [_textMSR.text stringByAppendingString:[NSString stringWithFormat:@"  Track1:%@\n", [data getTrack1]]];
    _textMSR.text = [_textMSR.text stringByAppendingString:[NSString stringWithFormat:@"  Track2:%@\n", [data getTrack2]]];
    _textMSR.text = [_textMSR.text stringByAppendingString:[NSString stringWithFormat:@"  Track4:%@\n", [data getTrack4]]];
    _textMSR.text = [_textMSR.text stringByAppendingString:[NSString stringWithFormat:@"  AccountNumber:%@\n", [data getAccountNumber]]];
    _textMSR.text = [_textMSR.text stringByAppendingString:[NSString stringWithFormat:@"  ExpirationData:%@\n", [data getExpirationData]]];
    _textMSR.text = [_textMSR.text stringByAppendingString:[NSString stringWithFormat:@"  Surname:%@\n", [data getSurname]]];
    _textMSR.text = [_textMSR.text stringByAppendingString:[NSString stringWithFormat:@"  FirstName:%@\n", [data getFirstName]]];
    _textMSR.text = [_textMSR.text stringByAppendingString:[NSString stringWithFormat:@"  MiddleInitial:%@\n", [data getMiddleInitial]]];
    _textMSR.text = [_textMSR.text stringByAppendingString:[NSString stringWithFormat:@"  Title:%@\n", [data getTitle]]];
    _textMSR.text = [_textMSR.text stringByAppendingString:[NSString stringWithFormat:@"  ServiceCode:%@\n", [data getServiceCode]]];
    _textMSR.text = [_textMSR.text stringByAppendingString:[NSString stringWithFormat:@"  Track1_dd:%@\n", [data getTrack1_dd]]];
    _textMSR.text = [_textMSR.text stringByAppendingString:[NSString stringWithFormat:@"  Track2_dd:%@\n", [data getTrack2_dd]]];
    
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

- (IBAction)clearMSR:(id)sender
{
    _textMSR.text = @"";
}

- (void)scrollText
{
    NSRange range;
    range = _textMSR.selectedRange;
    range.location = _textMSR.text.length;
    _textMSR.selectedRange = range;
    _textMSR.scrollEnabled = YES;

    CGFloat scrollY = _textMSR.contentSize.height + _textMSR.font.pointSize - _textMSR.bounds.size.height;
    CGPoint scrollPoint;

    if (scrollY < 0) {
        scrollY = 0;
    }

    scrollPoint = CGPointMake(0.0, scrollY);

    [_textMSR setContentOffset:scrollPoint animated:YES];
}

@end
