#import <AVFoundation/AVFoundation.h>
#import <QRCodeCapture.h>
#import "MainViewController.h"
#import "IndicatorView.h"
#import "ePOSEasySelect.h"
#import "ePOS2.h"
#import "Utility.h"

typedef NS_ENUM(NSInteger, QuickParingError) {
    QuickParingErrorOpen = 0,
    QuickParingErrorPrint,
};

@interface MainViewController () <QRCodeCaptureDelegate, UIAlertViewDelegate, Epos2PtrReceiveDelegate> {
    IndicatorView *qpIndicatorView_;
    EposEasySelectInfo *easySelectInfo_;
    QRCodeCapture *qpQrCodeCapture_;  //  using libzxing

    Epos2Printer *printer_;
}
@end

@implementation MainViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        qpIndicatorView_ = nil;
        easySelectInfo_ = nil;
        qpQrCodeCapture_ = nil;
        printer_ = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    qpQrCodeCapture_ = [[QRCodeCapture alloc] init];
    BOOL isConnectedSuccess = [qpQrCodeCapture_ connectCaptureSettion];
    if (isConnectedSuccess) {
        _qpCannotUseVideoUILabel.hidden = YES;
    }
    else {
        qpQrCodeCapture_ = nil;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self initializeTargetInfo];
    self.printUIButton.enabled = NO;

    self.qpInfoBackgroundUIView.layer.cornerRadius = 5;
    self.qpInfoBackgroundUIView.clipsToBounds = true;

    // Resize preview view
    CGFloat height = (_qpQrCodeScanUILable.frame.origin.y - 20) - _qpPreviewTargetUIView.frame.origin.y;
    if (height > 0) {
        CGRect frame = CGRectMake(_qpPreviewTargetUIView.frame.origin.x, _qpPreviewTargetUIView.frame.origin.y,
                                  _qpPreviewTargetUIView.frame.size.width, height);
        [_qpPreviewTargetUIView setFrame:frame];
    }

    [qpQrCodeCapture_ startCapture:self.qpPreviewTargetUIView scanDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [qpQrCodeCapture_ stopCapture];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    easySelectInfo_ = nil;
    [qpQrCodeCapture_ disConnectCaptureSettion];
}

- (void)willEnterForeground
{
    qpQrCodeCapture_.delegate = self;
}

- (void)didEnterBackground
{
    [self initializeTargetInfo];

    self.printUIButton.enabled = NO;
    qpQrCodeCapture_.delegate = nil;
}

- (void)showIndicator
{
    qpIndicatorView_ = [[IndicatorView alloc] init];
    [qpIndicatorView_ show:[[UIApplication sharedApplication] keyWindow]];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
}

- (void)hideIndicator
{
    [qpIndicatorView_ hide];
    qpIndicatorView_ = nil;
}

- (void)initializeTargetInfo
{
    _connectingUILabel.text = @"";
    _targetDeviceNameUILabel.text = @"";
    _targetInterfaceUILabel.text = @"";
    _targetMACAddressUILabel.text = @"";

    easySelectInfo_ = nil;
}

//----------------------------------------------------------------------------//
#pragma mark - QRCodeCapture & parseQR
//----------------------------------------------------------------------------//
- (void)didScanResult:(NSString *)result
{
    qpQrCodeCapture_.delegate = nil;

    // Analyze QR code
    EposEasySelect *easySelect = [[EposEasySelect alloc] init];
    EposEasySelectInfo *easySelectInfo = [easySelect parseQR:result];

    if (easySelectInfo) {
        [qpQrCodeCapture_ setFrameColor:[UIColor greenColor]];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];  // for update display

        [self updateTargetInfo:easySelectInfo];
        _connectingUILabel.text = NSLocalizedString(@"QP_Lbl_Connecting", @"");
        [qpQrCodeCapture_ stopCapture];
        [self showIndicator];

        // If you want to print immediately, run isAlivePrinter instead of runPrintSequence.
        BOOL printerAlive = [self isAlivePrinter:easySelectInfo];

        [self hideIndicator];
        _connectingUILabel.text = @"";

        if (printerAlive) {
            self.printUIButton.enabled = YES;
            [qpQrCodeCapture_ startCapture:self.qpPreviewTargetUIView scanDelegate:self];
        }
        else {
            self.printUIButton.enabled = NO;
            [self showQpErrorMsg:QuickParingErrorOpen];
            // Start capturing after alert ok button clicked (-alertView:clickedButtonAtIndex:)
        }
    }
    else {
        qpQrCodeCapture_.delegate = self;
    }
}

- (BOOL)isAlivePrinter:(EposEasySelectInfo *)easySelectInfo
{
    // Connect printer
    int printerSeries = [Utility convertPrinterNameToPrinterSeries:easySelectInfo.printerName];

    Epos2Printer *printer = [[Epos2Printer alloc] initWithPrinterSeries:printerSeries lang:EPOS2_MODEL_ANK];
    if (printer == nil) {
        return NO;
    }

    // Create target string
    NSString *targetText = [Utility convertEasySelectInfoToTargetString:easySelectInfo];
    int result = [printer connect:targetText timeout:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        return NO;
    }

    result = [printer disconnect];
    if (result != EPOS2_SUCCESS) {
        return NO;
    }

    return YES;
}

- (void)updateTargetInfo:(EposEasySelectInfo *)easySelectInfo
{
    _targetDeviceNameUILabel.text = easySelectInfo.printerName;
    _targetInterfaceUILabel.text = [Utility convertEposConnectionTypeToInterfaceString:easySelectInfo.deviceType];
    _targetMACAddressUILabel.text = easySelectInfo.macAddress;

    easySelectInfo_ = easySelectInfo;
    return;
}

//----------------------------------------------------------------------------//
#pragma mark - Printing Sequence
//----------------------------------------------------------------------------//
- (IBAction)pressPrintUIButton:(id)sender
{
    [qpQrCodeCapture_ stopCapture];
    [self showIndicator];

    BOOL bPrintingStart = [self runPrintSequence];

    if (!bPrintingStart) {
        [self hideIndicator];
        [self showQpErrorMsg:QuickParingErrorPrint];
    }
}

- (BOOL)runPrintSequence
{
    if (![self initializeObject]) {
        return NO;
    }

    if (![self createPrintData]) {
        [self finalizeObject];
        return NO;
    }

    if (![self printData]) {
        [self finalizeObject];
        return NO;
    }

    return YES;
}

- (BOOL)initializeObject
{
    int printerSeries = [Utility convertPrinterNameToPrinterSeries:easySelectInfo_.printerName];

    // initializeObject
    printer_ = [[Epos2Printer alloc] initWithPrinterSeries:printerSeries lang:EPOS2_MODEL_ANK];
    if (printer_ == nil) {
        return NO;
    }

    [printer_ setReceiveEventDelegate:self];

    return YES;
}

- (BOOL)createPrintData
{
    if (printer_ == nil) {
        return NO;
    }

    int result = EPOS2_ERR_FAILURE;
    result = [printer_ addText:@"--------------------"];
    if (EPOS2_SUCCESS != result) {
        return NO;
    }

    result = [printer_ addFeedLine:1];
    if (EPOS2_SUCCESS != result) {
        return NO;
    }

    [printer_ addText:@"Sample Print"];
    if (EPOS2_SUCCESS != result) {
        return NO;
    }

    result = [printer_ addFeedLine:1];
    if (EPOS2_SUCCESS != result) {
        return NO;
    }

    result = [printer_ addText:@"--------------------"];
    if (EPOS2_SUCCESS != result) {
        return NO;
    }

    result = [printer_ addFeedLine:2];
    if (EPOS2_SUCCESS != result) {
        return NO;
    }

    // DeviceName
    result = [printer_ addText:easySelectInfo_.printerName];
    if (EPOS2_SUCCESS != result) {
        return NO;
    }

    result = [printer_ addFeedLine:1];
    if (EPOS2_SUCCESS != result) {
        return NO;
    }

    // Address
    NSString *address =
        [NSString stringWithFormat:@"%@ Address:%@",
                                   [Utility convertEposConnectionTypeToInterfaceString:easySelectInfo_.deviceType],
                                   easySelectInfo_.macAddress];
    result = [printer_ addText:address];
    if (EPOS2_SUCCESS != result) {
        return NO;
    }

    result = [printer_ addFeedLine:5];
    if (EPOS2_SUCCESS != result) {
        return NO;
    }

    result = [printer_ addTextAlign:EPOS2_ALIGN_CENTER];
    if (EPOS2_SUCCESS != result) {
        return NO;
    }

    result = [printer_ addText:@"Print successfully!!"];
    if (EPOS2_SUCCESS != result) {
        return NO;
    }

    result = [printer_ addFeedLine:2];
    if (EPOS2_SUCCESS != result) {
        return NO;
    }

    result = [printer_ addCut:EPOS2_CUT_FEED];
    if (EPOS2_SUCCESS != result) {
        return NO;
    }

    return YES;
}

- (BOOL)printData
{
    int result = EPOS2_SUCCESS;

    Epos2PrinterStatusInfo *status = nil;

    if (printer_ == nil) {
        return NO;
    }

    if (![self connectPrinter]) {
        return NO;
    }

    status = [printer_ getStatus];

    if (![self isPrintable:status]) {
        [self disconnectPrinter];
        return NO;
    }

    result = [printer_ sendData:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [self disconnectPrinter];
        return NO;
    }

    return YES;
}

- (BOOL)connectPrinter
{
    int result = EPOS2_SUCCESS;

    if (printer_ == nil) {
        return NO;
    }

    // Create target string
    NSString *targetText = [Utility convertEasySelectInfoToTargetString:easySelectInfo_];
    if ([targetText isEqualToString:@""]) {
        return NO;
    }

    result = [printer_ connect:targetText timeout:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        return NO;
    }

    result = [printer_ beginTransaction];
    if (result != EPOS2_SUCCESS) {
        [self disconnectPrinter];
        return NO;
    }

    return YES;
}

- (BOOL)isPrintable:(Epos2PrinterStatusInfo *)status
{
    if (status == nil) {
        return NO;
    }

    if (status.connection == EPOS2_FALSE) {
        return NO;
    }
    else if (status.online == EPOS2_FALSE) {
        return NO;
    }
    else {
        ;  // print available
    }

    return YES;
}

- (void)onPtrReceive:(Epos2Printer *)printerObj
                code:(int)code
              status:(Epos2PrinterStatusInfo *)status
          printJobId:(NSString *)printJobId
{
    [self hideIndicator];

    [self performSelectorInBackground:@selector(disconnectPrinter) withObject:nil];

    if (code == EPOS2_SUCCESS) {
        // start capturing
        [qpQrCodeCapture_ startCapture:self.qpPreviewTargetUIView scanDelegate:self];
    }
    else {
        [self showQpErrorMsg:QuickParingErrorPrint];
        // Start capturing after alert ok button clicked  (-alertView:clickedButtonAtIndex:)
    }
}

- (void)disconnectPrinter
{
    if (printer_ == nil) {
        return;
    }

    [printer_ endTransaction];

    [printer_ disconnect];

    [self finalizeObject];
}

- (void)finalizeObject
{
    if (printer_ == nil) {
        return;
    }

    [printer_ clearCommandBuffer];

    [printer_ setReceiveEventDelegate:nil];

    printer_ = nil;
}

//----------------------------------------------------------------------------//
#pragma mark - Error Message Method
//----------------------------------------------------------------------------//
- (void)showQpErrorMsg:(QuickParingError)errorid
{
    NSString *msg = [self qrErrorMsg:errorid];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"dialog_title_error", @"")
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"dialog_button_ok", @""), nil];
    [alert show];
}

- (NSString *)qrErrorMsg:(QuickParingError)errorid
{
    switch (errorid) {
        case QuickParingErrorOpen:
            return NSLocalizedString(@"QP_msg_ErrorPrinterOpen", @"");
        case QuickParingErrorPrint:
            return NSLocalizedString(@"QP_msg_PrintError", @"");
        default:
            return @"";
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Error alert ok button clicked, start capturing
    [qpQrCodeCapture_ startCapture:self.qpPreviewTargetUIView scanDelegate:self];
}

@end
