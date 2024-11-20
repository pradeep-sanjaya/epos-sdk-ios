#import "BarcodeScannerViewController.h"
#import "ShowMsg.h"
#import "UIViewController+Extension.h"

@interface BarcodeScannerViewController() <Epos2ScanDelegate, Epos2ConnectionDelegate>
@end

@implementation BarcodeScannerViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        barcodeScanner_ = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setDoneToolbar];

    _textScanner.text = @"";
    isConnect_ = NO;
    
    int result = [Epos2Log setLogSettings:EPOS2_PERIOD_TEMPORARY output:EPOS2_OUTPUT_STORAGE ipAddress:nil port:0 logSize:50 logLevel:EPOS2_LOGLEVEL_LOW];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"setLogSettings"];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self initializeObject];
    target_ = _textTarget.text;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self finalizeObject];
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
    target_ = _textTarget.text;
}

- (IBAction)connectProcess:(id)sender
{
    [self showIndicator:NSLocalizedString(@"wait", @"")];
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        if (![self connectScanner]) {
            [self hideIndicator];
            return;
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            _buttonConnect.enabled = NO;
        }];
        [self hideIndicator];
    }];
}

- (IBAction)disconnectProcess:(id)sender
{
    [self showIndicator:NSLocalizedString(@"wait", @"")];
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        [self disconnectScanner];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            _buttonConnect.enabled = YES;
        }];
        [self hideIndicator];
    }];
}

- (BOOL)initializeObject
{
    barcodeScanner_ = [[Epos2BarcodeScanner alloc] init];
    if (barcodeScanner_ == nil) {
        [ShowMsg showErrorEpos:EPOS2_ERR_MEMORY method:@"init"];
        return NO;
    }

    [barcodeScanner_ setScanEventDelegate:self];
    [barcodeScanner_ setConnectionEventDelegate:self];

    return YES;
}

- (void)finalizeObject
{
    if (barcodeScanner_ == nil) {
        return;
    }

    [barcodeScanner_ setScanEventDelegate:nil];
    [barcodeScanner_ setConnectionEventDelegate:nil];
    barcodeScanner_ = nil;
}

- (BOOL)connectScanner
{
    int result = EPOS2_SUCCESS;

    if (barcodeScanner_ == nil) {
        return NO;
    }

    //Note: This API must be used from background thread only
    result = [barcodeScanner_ connect:target_ timeout:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"connect"];
        return NO;
    }
    isConnect_ = YES;

    return YES;
}

- (void)disconnectScanner
{
    int result = EPOS2_SUCCESS;

    if (barcodeScanner_ == nil) {
        return;
    }

    if(isConnect_ == YES) {
        //Note: This API must be used from background thread only
        result = [barcodeScanner_ disconnect];
        if (result != EPOS2_SUCCESS) {
            isConnect_ = NO;
            
            [ShowMsg showErrorEpos:result method:@"disconnect"];
        }
    }
    else {
        return;
    }
}

- (void) onScanData:(Epos2BarcodeScanner *)scannerObj scanData:(NSString *)scanData
{
    NSString *CR = @"\n";

    if (_textScanner.text.length != 0) {
        _textScanner.text = [_textScanner.text stringByAppendingString:CR];
    }
    _textScanner.text = [_textScanner.text stringByAppendingString:scanData];

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

- (IBAction)clearScanner:(id)sender
{
    _textScanner.text = @"";
}

- (void)scrollText
{
    NSRange range;
    range = _textScanner.selectedRange;
    range.location = _textScanner.text.length;
    _textScanner.selectedRange = range;
    _textScanner.scrollEnabled = YES;

    CGFloat scrollY = _textScanner.contentSize.height + _textScanner.font.pointSize - _textScanner.bounds.size.height;
    CGPoint scrollPoint;

    if (scrollY < 0) {
        scrollY = 0;
    }
    scrollPoint = CGPointMake(0.0, scrollY);

    [_textScanner setContentOffset:scrollPoint animated:YES];
}

@end
