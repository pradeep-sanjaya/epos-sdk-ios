#import "MainViewController.h"
#import "PrinterInfo.h"
#import "ShowMsg.h"

#define KEY_RESULT                  @"Result"
#define KEY_METHOD                  @"Method"
#define PAGE_AREA_HEIGHT    500
#define PAGE_AREA_WIDTH     500
#define FONT_A_HEIGHT       24
#define FONT_A_WIDTH        12
#define BARCODE_HEIGHT_POS  70
#define BARCODE_WIDTH_POS   110
#define DISCONNECT_INTERVAL                  0.5

@interface MainViewController() <Epos2PtrReceiveDelegate>
@end

@implementation MainViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        printer_ = nil;
        
        printerInfo_ = [PrinterInfo sharedPrinterInfo];
        printerInfo_.printerSeries = EPOS2_TM_M30;
        printerInfo_.lang = EPOS2_MODEL_ANK;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    printerList_ = [[PickerTableView alloc] init];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:NSLocalizedString(@"printerseries_m10", @"")];
    [items addObject:NSLocalizedString(@"printerseries_m30", @"")];
    [items addObject:NSLocalizedString(@"printerseries_p20", @"")];
    [items addObject:NSLocalizedString(@"printerseries_p60", @"")];
    [items addObject:NSLocalizedString(@"printerseries_p60ii", @"")];
    [items addObject:NSLocalizedString(@"printerseries_p80", @"")];
    [items addObject:NSLocalizedString(@"printerseries_t20", @"")];
    [items addObject:NSLocalizedString(@"printerseries_t60", @"")];
    [items addObject:NSLocalizedString(@"printerseries_t70", @"")];
    [items addObject:NSLocalizedString(@"printerseries_t81", @"")];
    [items addObject:NSLocalizedString(@"printerseries_t82", @"")];
    [items addObject:NSLocalizedString(@"printerseries_t83", @"")];
    [items addObject:NSLocalizedString(@"printerseries_t88", @"")];
    [items addObject:NSLocalizedString(@"printerseries_t90", @"")];
    [items addObject:NSLocalizedString(@"printerseries_t90kp", @"")];
    [items addObject:NSLocalizedString(@"printerseries_u220", @"")];
    [items addObject:NSLocalizedString(@"printerseries_u330", @"")];
    [items addObject:NSLocalizedString(@"printerseries_l90", @"")];
    [items addObject:NSLocalizedString(@"printerseries_h6000", @"")];
    [items addObject:NSLocalizedString(@"printerseries_t83iii", @"")];
    [items addObject:NSLocalizedString(@"printerseries_t100", @"")];
    [items addObject:NSLocalizedString(@"printerseries_m30ii", @"")];
    [items addObject:NSLocalizedString(@"printerseries_ts100", @"")];
    [items addObject:NSLocalizedString(@"printerseries_m50", @"")];
    [items addObject:NSLocalizedString(@"printerseries_t88vii", @"")];
    [items addObject:NSLocalizedString(@"printerseries_l90lfc", @"")];
    [items addObject:NSLocalizedString(@"printerseries_l100", @"")];
    [items addObject:NSLocalizedString(@"printerseries_p20ii", @"")];
    [items addObject:NSLocalizedString(@"printerseries_p80ii", @"")];
    [items addObject:NSLocalizedString(@"printerseries_m30iii", @"")];
    [items addObject:NSLocalizedString(@"printerseries_m50ii", @"")];
    [items addObject:NSLocalizedString(@"printerseries_m55", @"")];
    [items addObject:NSLocalizedString(@"printerseries_u220ii", @"")];
    [printerList_ setItemList:items];
    printerInfo_.printerSeries = 1;
    [_buttonPrinter setTitle:[printerList_ getItem:1] forState:UIControlStateNormal];
    printerList_.delegate = self;

    langList_ = [[PickerTableView alloc] init];
    items = [[NSMutableArray alloc] init];
    [items addObject:NSLocalizedString(@"language_ank", @"")];
    [items addObject:NSLocalizedString(@"language_japanese", @"")];
    [items addObject:NSLocalizedString(@"language_chinese", @"")];
    [items addObject:NSLocalizedString(@"language_taiwan", @"")];
    [items addObject:NSLocalizedString(@"language_korean", @"")];
    [items addObject:NSLocalizedString(@"language_thai", @"")];
    [items addObject:NSLocalizedString(@"language_southasia", @"")];

    [langList_ setItemList:items];
    [_buttonLang setTitle:[langList_ getItem:0] forState:UIControlStateNormal];
    langList_.delegate = self;

    _textWarnings.text = @"";

    [self setDoneToolbar];

    int result = [Epos2Log setLogSettings:EPOS2_PERIOD_TEMPORARY output:EPOS2_OUTPUT_STORAGE ipAddress:nil port:0 logSize:50 logLevel:EPOS2_LOGLEVEL_LOW];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"setLogSettings"];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self initializeObject];
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
    printerInfo_.target = _textTarget.text;
}

- (IBAction)eventButtonDidPush:(id)sender
{
    switch (((UIView *)sender).tag) {
        case 1:
            [printerList_ show];
            break;
        case 2:
            [langList_ show];
            break;
        case 3:
            //Sample Receipt
            [self showIndicator:NSLocalizedString(@"wait", @"")];
            drawer_ = _switchDrawer.on;
            _textWarnings.text = @"";
            {
                [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
                    if (![self runPrintReceiptSequence]) {
                        [self hideIndicator];
                        
                    }
                    
                }];
            }
            break;
        case 4:
            //Sample Coupon
            [self showIndicator:NSLocalizedString(@"wait", @"")];
            _textWarnings.text = @"";
            {
                [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
                    if (![self runPrintCouponSequence]) {
                        [self hideIndicator];
                    }
                }];
            }
            break;
        default:
            break;
    }
}

- (BOOL)runPrintReceiptSequence
{
    if (![self createReceiptData]) {
        return NO;
    }

    if (![self printData]) {
        return NO;
    }

    return YES;
}

- (BOOL)runPrintCouponSequence
{

    if (![self createCouponData]) {
        return NO;
    }

    if (![self printData]) {
        return NO;
    }

    return YES;
}

- (BOOL)createReceiptData
{
    int result = EPOS2_SUCCESS;

    const int barcodeWidth = 2;
    const int barcodeHeight = 100;

    if (printer_ == nil) {
        return NO;
    }

    NSMutableString *textData = [[NSMutableString alloc] init];
    UIImage *logoData = [UIImage imageNamed:@"store.png"];

    if (textData == nil || logoData == nil) {
        return NO;
    }
    
    if(drawer_){
        int result = [printer_ addPulse:EPOS2_PARAM_DEFAULT time:EPOS2_PARAM_DEFAULT];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addPulse"];
            return NO;
        }
    }
    

    result = [printer_ addTextAlign:EPOS2_ALIGN_CENTER];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addTextAlign"];
        return NO;
    }

    result = [printer_ addImage:logoData x:0 y:0
              width:logoData.size.width
              height:logoData.size.height
              color:EPOS2_COLOR_1
              mode:EPOS2_MODE_MONO
              halftone:EPOS2_HALFTONE_DITHER
              brightness:EPOS2_PARAM_DEFAULT
              compress:EPOS2_COMPRESS_AUTO];

    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addImage"];
        return NO;
    }

    // Section 1 : Store infomation
    result = [printer_ addFeedLine:1];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addFeedLine"];
        return NO;
    }
    [textData appendString:@"THE STORE 123 (555) 555 – 5555\n"];
    [textData appendString:@"STORE DIRECTOR – John Smith\n"];
    [textData appendString:@"\n"];
    [textData appendString:@"7/01/07 16:58 6153 05 0191 134\n"];
    [textData appendString:@"ST# 21 OP# 001 TE# 01 TR# 747\n"];
    [textData appendString:@"------------------------------\n"];
    result = [printer_ addText:textData];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }
    [textData setString:@""];

    // Section 2 : Purchaced items
    [textData appendString:@"400 OHEIDA 3PK SPRINGF  9.99 R\n"];
    [textData appendString:@"410 3 CUP BLK TEAPOT    9.99 R\n"];
    [textData appendString:@"445 EMERIL GRIDDLE/PAN 17.99 R\n"];
    [textData appendString:@"438 CANDYMAKER ASSORT   4.99 R\n"];
    [textData appendString:@"474 TRIPOD              8.99 R\n"];
    [textData appendString:@"433 BLK LOGO PRNTED ZO  7.99 R\n"];
    [textData appendString:@"458 AQUA MICROTERRY SC  6.99 R\n"];
    [textData appendString:@"493 30L BLK FF DRESS   16.99 R\n"];
    [textData appendString:@"407 LEVITATING DESKTOP  7.99 R\n"];
    [textData appendString:@"441 **Blue Overprint P  2.99 R\n"];
    [textData appendString:@"476 REPOSE 4PCPM CHOC   5.49 R\n"];
    [textData appendString:@"461 WESTGATE BLACK 25  59.99 R\n"];
    [textData appendString:@"------------------------------\n"];

    result = [printer_ addText:textData];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }
    [textData setString:@""];

    // Section 3 : Payment infomation
    [textData appendString:@"SUBTOTAL                160.38\n"];
    [textData appendString:@"TAX                      14.43\n"];
    result = [printer_ addText:textData];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }
    [textData setString:@""];

    result = [printer_ addTextSize:2 height:2];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addTextSize"];
        return NO;
    }

    result = [printer_ addText:@"TOTAL    174.81\n"];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }

    result = [printer_ addTextSize:1 height:1];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addTextSize"];
        return NO;
    }

    result = [printer_ addFeedLine:1];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addFeedLine"];
        return NO;
    }

    [textData appendString:@"CASH                    200.00\n"];
    [textData appendString:@"CHANGE                   25.19\n"];
    [textData appendString:@"------------------------------\n"];
    result = [printer_ addText:textData];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }
    [textData setString:@""];

    // Section 4 : Advertisement
    [textData appendString:@"Purchased item total number\n"];
    [textData appendString:@"Sign Up and Save !\n"];
    [textData appendString:@"With Preferred Saving Card\n"];
    result = [printer_ addText:textData];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }
    [textData setString:@""];

    result = [printer_ addFeedLine:2];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addFeedLine"];
        return NO;
    }

    result = [printer_ addBarcode:@"01209457"
              type:EPOS2_BARCODE_CODE39
              hri:EPOS2_HRI_BELOW
              font:EPOS2_FONT_A
              width:barcodeWidth
              height:barcodeHeight];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addBarcode"];
        return NO;
    }

    result = [printer_ addCut:EPOS2_CUT_FEED];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addCut"];
        return NO;
    }

    return YES;
}

- (BOOL)createCouponData
{
    int result = EPOS2_SUCCESS;

    const int barcodeWidth = 2;
    const int barcodeHeight = 64;

    if (printer_ == nil) {
        return NO;
    }

    UIImage *coffeeData = [UIImage imageNamed:@"coffee.png"];
    UIImage *wmarkData = [UIImage imageNamed:@"wmark.png"];

    if (coffeeData == nil || wmarkData == nil) {
        return NO;
    }

    result = [printer_ addImage:wmarkData x:0 y:0
              width:wmarkData.size.width
              height:wmarkData.size.height
              color:EPOS2_PARAM_DEFAULT
              mode:EPOS2_PARAM_DEFAULT
              halftone:EPOS2_PARAM_DEFAULT
              brightness:EPOS2_PARAM_DEFAULT
              compress:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addImage"];
        return NO;
    }

    result = [printer_ addImage:coffeeData x:0 y:0
              width:coffeeData.size.width
              height:coffeeData.size.height
              color:EPOS2_PARAM_DEFAULT
              mode:EPOS2_PARAM_DEFAULT
              halftone:EPOS2_PARAM_DEFAULT
              brightness:3
              compress:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addImage"];
        return NO;
    }

    result = [printer_ addBarcode:@"01234567890" type:EPOS2_BARCODE_UPC_A hri:EPOS2_PARAM_DEFAULT font: EPOS2_PARAM_DEFAULT width:barcodeWidth height:barcodeHeight];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addBarocde"];
        return NO;
    }

    result = [printer_ addCut:EPOS2_CUT_FEED];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addCut"];
        return NO;
    }

    return YES;
}

- (BOOL)printData
{
    int result = EPOS2_SUCCESS;

    if (printer_ == nil) {
        return NO;
    }

    if (![self connectPrinter]) {
        [printer_ clearCommandBuffer];
        return NO;
    }

    result = [printer_ sendData:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"sendData"];
        
        //Note: This API must be used from background thread only
        [printer_ disconnect];
        return NO;
    }

    return YES;
}

- (BOOL)initializeObject
{
    printer_ = [[Epos2Printer alloc] initWithPrinterSeries:printerInfo_.printerSeries lang:printerInfo_.lang];

    if (printer_ == nil) {
        [ShowMsg showErrorEpos:EPOS2_ERR_PARAM method:@"initiWithPrinterSeries"];
        return NO;
    }

    [printer_ setReceiveEventDelegate:self];

    return YES;
}

- (void)finalizeObject
{
    if (printer_ == nil) {
        return;
    }

    [printer_ setReceiveEventDelegate:nil];

    printer_ = nil;
}

-(BOOL)connectPrinter
{
    int result = EPOS2_SUCCESS;

    if (printer_ == nil) {
        return NO;
    }

    //Note: This API must be used from background thread only
    result = [printer_ connect:printerInfo_.target timeout:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"connect"];
        return NO;
    }

    return YES;
}

- (void)disconnectPrinter
{
    int result = EPOS2_SUCCESS;

    if (printer_ == nil) {
        return;
    }

    //Note: This API must be used from background thread only
    result = [printer_ disconnect];
    int count = 0;
    //Note: Check if the process overlaps with another process in time.
    while(result == EPOS2_ERR_PROCESSING && count < 4) {
        [NSThread sleepForTimeInterval:DISCONNECT_INTERVAL];
        result = [printer_ disconnect];
        count++;
    }
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"disconnect"];
    }

    [printer_ clearCommandBuffer];
}

- (void) onPtrReceive:(Epos2Printer *)printerObj code:(int)code status:(Epos2PrinterStatusInfo *)status printJobId:(NSString *)printJobId
{

    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        [self disconnectPrinter];
        [self hideIndicator];
        [ShowMsg showResult:code errMsg:[self makeErrorMessage:status]];
        [self dispPrinterWarnings:status];
    }];
}

- (void)dispPrinterWarnings:(Epos2PrinterStatusInfo *)status
{
    NSMutableString *warningMsg = [[NSMutableString alloc] init];

    if (status == nil) {
        return;
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _textWarnings.text = @"";
    }];

    if (status.paper == EPOS2_PAPER_NEAR_END) {
        [warningMsg appendString:NSLocalizedString(@"warn_receipt_near_end", @"")];
    }

    if (status.batteryLevel == EPOS2_BATTERY_LEVEL_1) {
        [warningMsg appendString:NSLocalizedString(@"warn_battery_near_end", @"")];
    }
    
    if (status.paperTakenSensor == EPOS2_REMOVAL_DETECT_PAPER) {
        [warningMsg appendString:NSLocalizedString(@"warn_detect_paper", @"")];
    }
    
    if (status.paperTakenSensor == EPOS2_REMOVAL_DETECT_UNKNOWN) {
        [warningMsg appendString:NSLocalizedString(@"warn_detect_unknown", @"")];
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _textWarnings.text = warningMsg;
    }];
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
    if (status.getRemovalWaiting == EPOS2_REMOVAL_WAIT_PAPER) {
        [errMsg appendString:NSLocalizedString(@"err_wait_removal", @"")];
    }
    if (status.getUnrecoverError == EPOS2_HIGH_VOLTAGE_ERR ||
        status.getUnrecoverError == EPOS2_LOW_VOLTAGE_ERR) {
        [errMsg appendString:NSLocalizedString(@"err_voltage", @"")];
    }
    

    return errMsg;
}

- (void)onSelectPrinter:(NSString *)target ip:(NSString *)ip;
{
    _textTarget.text = target;
    printerInfo_.target = target;
    printerInfo_.ip = ip;
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
        printerInfo_.printerSeries = (int)printerList_.selectIndex;
    }
    else if (obj == langList_) {
        [_buttonLang setTitle:[langList_ getItem:position] forState:UIControlStateNormal];
        printerInfo_.lang  = (int)langList_.selectIndex;
    }
    else {
        ; //do nothing
    }

    [self finalizeObject];
    [self initializeObject];
}
@end
