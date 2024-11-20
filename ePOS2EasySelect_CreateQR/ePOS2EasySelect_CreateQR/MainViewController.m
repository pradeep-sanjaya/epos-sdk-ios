#import "MainViewController.h"
#import "ShowMsg.h"
#import "Utility.h"

#define KEY_RESULT @"Result"
#define KEY_METHOD @"Method"

@interface MainViewController () <Epos2PtrReceiveDelegate>
@end

@implementation MainViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        printer_ = nil;
        printerSeries_ = EPOS2_TM_M10;
        eposEasySelectDeviceType_ = EPOS_EASY_SELECT_DEVTYPE_TCP;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    printerList_ = [[PickerTableView alloc] init];
    NSArray *items = @[ @"TM-m10", @"TM-m30", @"TM-P20", @"TM-P60II", @"TM-P80", @"TM-T88V", @"TM-T88VI", @"TM-m30II", @"TM-m50", @"TM-T88VII", @"TM-L100", @"TM-P20II", @"TM-P80II", @"TM-m30III", @"TM-m50II", @"TM-m55" ];
    [printerList_ setItemList:items];
    [_buttonPrinter setTitle:[printerList_ getItem:0] forState:UIControlStateNormal];
    printerList_.delegate = self;
    printerSeries_ = [Utility convertPrinterNameToPrinterSeries:[printerList_ getItem:0]];

    _textWarnings.text = @"";

    int result = [Epos2Log setLogSettings:EPOS2_PERIOD_TEMPORARY
                                   output:EPOS2_OUTPUT_STORAGE
                                ipAddress:nil
                                     port:0
                                  logSize:1
                                 logLevel:EPOS2_LOGLEVEL_LOW];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"setLogSettings"];
    }
}

- (IBAction)eventButtonDidPush:(id)sender
{
    switch (((UIView *)sender).tag) {
        case 1:
            [printerList_ show];
            break;
        case 2:
            // Print QR Code
            [self updateButtonState:NO];
            if (![self runPrintQRCodeSequence]) {
                [self updateButtonState:YES];
            }
            break;
        default:
            break;
    }
}

- (void)updateButtonState:(BOOL)state
{
    _buttonReceipt.enabled = state;
}

- (void)onSelectPrinter:(Epos2DeviceInfo *)deviceInfo
{
    _textTarget.text = deviceInfo.target;
    _textInterface.text = [Utility convertEpos2DeficeInfoToInterfaceString:deviceInfo];
    eposEasySelectDeviceType_ = [Utility convertEpos2DeviceInfoToEposEasySelectDeviceType:deviceInfo];
    _textAddress.text = [Utility getAddressFromEpos2DeviceInfo:deviceInfo];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *view = nil;

    if ([segue.identifier isEqualToString:@"DiscoveryView"]) {
        view = (DiscoveryViewController *)[segue destinationViewController];

        ((DiscoveryViewController *)view).delegate = self;
    }
}

- (void)onSelectPickerItem:(NSInteger)position obj:(id)obj
{
    if (obj == printerList_) {
        [_buttonPrinter setTitle:[printerList_ getItem:position] forState:UIControlStateNormal];
        printerSeries_ = [Utility convertPrinterNameToPrinterSeries:[printerList_ getItem:position]];
    }
    else {
        ;  // do nothing
    }
}

//----------------------------------------------------------------------------//
#pragma mark - QR Code Print Sequence
//----------------------------------------------------------------------------//
- (BOOL)runPrintQRCodeSequence
{
    _textWarnings.text = @"";

    if (![self initializeObject]) {
        return NO;
    }

    if (![self createQrCodeData]) {
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
    printer_ = [[Epos2Printer alloc] initWithPrinterSeries:printerSeries_ lang:EPOS2_MODEL_ANK];

    if (printer_ == nil) {
        [ShowMsg showErrorEpos:EPOS2_ERR_PARAM method:@"initiWithPrinterSeries"];
        return NO;
    }

    [printer_ setReceiveEventDelegate:self];

    return YES;
}

- (BOOL)createQrCodeData
{
    int result = EPOS2_SUCCESS;

    if (printer_ == nil) {
        return NO;
    }

    NSString *printText = @"";
    // Device Name
    printText = [NSString stringWithFormat:@"Device:%@", _buttonPrinter.titleLabel.text];
    result = [printer_ addText:printText];
    if (EPOS2_SUCCESS != result) {
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }

    result = [printer_ addFeedLine:1];
    if (EPOS2_SUCCESS != result) {
        [ShowMsg showErrorEpos:result method:@"addFeedLine"];
        return NO;
    }

    // Interface
    printText = [NSString stringWithFormat:@"Interface:%@", _textInterface.text];
    result = [printer_ addText:printText];
    if (EPOS2_SUCCESS != result) {
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }

    result = [printer_ addFeedLine:1];
    if (EPOS2_SUCCESS != result) {
        [ShowMsg showErrorEpos:result method:@"addFeedLine"];
        return NO;
    }

    // Mac Address
    printText = [NSString stringWithFormat:@"Address:%@", _textAddress.text];
    result = [printer_ addText:printText];
    if (EPOS2_SUCCESS != result) {
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }

    result = [printer_ addFeedLine:2];
    if (EPOS2_SUCCESS != result) {
        [ShowMsg showErrorEpos:result method:@"addFeedLine"];
        return NO;
    }

    // createQR
    EposEasySelect *easySelect = [[EposEasySelect alloc] init];
    NSString *qrCodeText = [easySelect createQR:_buttonPrinter.titleLabel.text
                                     DeviceType:eposEasySelectDeviceType_
                                     MacAddress:_textAddress.text];

    if (!qrCodeText) {
        [ShowMsg show:@"Error createQR"];
        return NO;
    }

    // Add QR CODE
    result = [printer_ addTextAlign:EPOS2_ALIGN_CENTER];
    if (EPOS2_SUCCESS != result) {
        [ShowMsg showErrorEpos:result method:@"addTextAlign"];
        return NO;
    }

    result = [printer_ addSymbol:qrCodeText
                            type:EPOS2_SYMBOL_QRCODE_MODEL_2
                           level:EPOS2_LEVEL_L
                           width:5  // Specifies the QR code width
                          height:5  // Ignored by QR code
                            size:0];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addSymbol"];
        return NO;
    }

    result = [printer_ addFeedLine:1];
    if (EPOS2_SUCCESS != result) {
        [ShowMsg showErrorEpos:result method:@"addFeedLine"];
        return NO;
    }

    result = [printer_ addCut:EPOS2_CUT_FEED];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addCut"];
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
    [self dispPrinterWarnings:status];

    if (![self isPrintable:status]) {
        [ShowMsg show:[self makeErrorMessage:status]];
        [self disconnectPrinter];
        return NO;
    }

    result = [printer_ sendData:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"sendData"];
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

    result = [printer_ connect:_textTarget.text timeout:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"connect"];
        return NO;
    }

    result = [printer_ beginTransaction];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"beginTransaction"];
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
    [ShowMsg showResult:code errMsg:[self makeErrorMessage:status]];

    [self dispPrinterWarnings:status];
    [self updateButtonState:YES];

    [self performSelectorInBackground:@selector(disconnectPrinter) withObject:nil];
}

- (void)disconnectPrinter
{
    int result = EPOS2_SUCCESS;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    if (printer_ == nil) {
        return;
    }

    result = [printer_ endTransaction];
    if (result != EPOS2_SUCCESS) {
        [dict setObject:[NSNumber numberWithInt:result] forKey:KEY_RESULT];
        [dict setObject:@"endTransaction" forKey:KEY_METHOD];
        [self performSelectorOnMainThread:@selector(showEposErrorFromThread:) withObject:dict waitUntilDone:NO];
    }

    result = [printer_ disconnect];
    if (result != EPOS2_SUCCESS) {
        dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[NSNumber numberWithInt:result] forKey:KEY_RESULT];
        [dict setObject:@"disconnect" forKey:KEY_METHOD];

        [self performSelectorOnMainThread:@selector(showEposErrorFromThread:) withObject:dict waitUntilDone:NO];
    }
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
#pragma mark - Error & Warnings
//----------------------------------------------------------------------------//

- (void)showEposErrorFromThread:(NSDictionary *)dict
{
    int result = EPOS2_SUCCESS;
    NSString *method = @"";
    result = [[dict valueForKey:KEY_RESULT] intValue];
    method = [dict valueForKey:KEY_METHOD];
    [ShowMsg showErrorEpos:result method:method];
}

- (void)dispPrinterWarnings:(Epos2PrinterStatusInfo *)status
{
    NSMutableString *warningMsg = [[NSMutableString alloc] init];

    if (status == nil) {
        return;
    }

    _textWarnings.text = @"";

    if (status.paper == EPOS2_PAPER_NEAR_END) {
        [warningMsg appendString:NSLocalizedString(@"warn_receipt_near_end", @"")];
    }

    if (status.batteryLevel == EPOS2_BATTERY_LEVEL_1) {
        [warningMsg appendString:NSLocalizedString(@"warn_battery_near_end", @"")];
    }

    _textWarnings.text = warningMsg;
}

- (NSString *)makeErrorMessage:(Epos2PrinterStatusInfo *)status
{
    NSMutableString *errMsg = [[NSMutableString alloc] initWithString:@""];

    if (status.getOnline == EPOS2_FALSE) {
        [errMsg appendString:NSLocalizedString(@"err_offline", @"")];
    }
    if (status.getConnection == EPOS2_FALSE) {
        [errMsg appendString:NSLocalizedString(@"err_no_response", @"")];
    }
    if (status.getCoverOpen == EPOS2_TRUE) {
        [errMsg appendString:NSLocalizedString(@"err_cover_open", @"")];
    }
    if (status.getPaper == EPOS2_PAPER_EMPTY) {
        [errMsg appendString:NSLocalizedString(@"err_receipt_end", @"")];
    }
    if (status.getPaperFeed == EPOS2_TRUE || status.getPanelSwitch == EPOS2_SWITCH_ON) {
        [errMsg appendString:NSLocalizedString(@"err_paper_feed", @"")];
    }
    if (status.getErrorStatus == EPOS2_MECHANICAL_ERR || status.getErrorStatus == EPOS2_AUTOCUTTER_ERR) {
        [errMsg appendString:NSLocalizedString(@"err_autocutter", @"")];
        [errMsg appendString:NSLocalizedString(@"err_need_recover", @"")];
    }
    if (status.getErrorStatus == EPOS2_UNRECOVER_ERR) {
        [errMsg appendString:NSLocalizedString(@"err_unrecover", @"")];
    }

    if (status.getErrorStatus == EPOS2_AUTORECOVER_ERR) {
        if (status.getAutoRecoverError == EPOS2_HEAD_OVERHEAT) {
            [errMsg appendString:NSLocalizedString(@"err_overheat", @"")];
            [errMsg appendString:NSLocalizedString(@"err_head", @"")];
        }
        if (status.getAutoRecoverError == EPOS2_MOTOR_OVERHEAT) {
            [errMsg appendString:NSLocalizedString(@"err_overheat", @"")];
            [errMsg appendString:NSLocalizedString(@"err_motor", @"")];
        }
        if (status.getAutoRecoverError == EPOS2_BATTERY_OVERHEAT) {
            [errMsg appendString:NSLocalizedString(@"err_overheat", @"")];
            [errMsg appendString:NSLocalizedString(@"err_battery", @"")];
        }
        if (status.getAutoRecoverError == EPOS2_WRONG_PAPER) {
            [errMsg appendString:NSLocalizedString(@"err_wrong_paper", @"")];
        }
    }
    if (status.getBatteryLevel == EPOS2_BATTERY_LEVEL_0) {
        [errMsg appendString:NSLocalizedString(@"err_battery_real_end", @"")];
    }

    return errMsg;
}

@end
