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

@interface MainViewController() <Epos2LFCSendCompleteDelegate>
@end

@implementation MainViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        printer_ = nil;
        
        printerInfo_ = [PrinterInfo sharedPrinterInfo];
        printerInfo_.printerSeries = EPOS2_TM_L100;
        printerInfo_.lang = EPOS2_MODEL_ANK;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    printerList_ = [[PickerTableView alloc] init];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:NSLocalizedString(@"printerseries_l100", @"")];
    [printerList_ setItemList:items];
    printerInfo_.printerSeries = EPOS2_TM_L100;
    [_buttonPrinter setTitle:[printerList_ getItem:0] forState:UIControlStateNormal];
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

    _textLog.text = @"";

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
    _textJobNumber.inputAccessoryView = doneToolbar;
    
}

- (void)doneKeyboard:(id)sender
{
    [_textTarget resignFirstResponder];
    printerInfo_.target = _textTarget.text;
    [_textLog resignFirstResponder];
    [_textJobNumber resignFirstResponder];
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
            int jobNumber = [_textJobNumber.text intValue];
            {
                [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
                    if (![self runPrintLabelSequence:jobNumber]) {
                        [self hideIndicator];
                    }
                    
                }];
            }
            break;
        default:
            break;
    }
}

- (BOOL)runPrintLabelSequence:(int)jobNumber
{
    if (![self createLabelData:jobNumber]) {
        return NO;
    }

    if (![self printData:jobNumber]) {
        return NO;
    }
    
    [self updateJobNumber];

    return YES;
}

- (BOOL)createLabelData:(int)jobNumber
{
    int result = EPOS2_SUCCESS;

    if (printer_ == nil) {
        return NO;
    }
    
    result = [printer_ addTextAlign:EPOS2_ALIGN_CENTER];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addTextAlign"];
        return NO;
    }
    result = [printer_ addTextSize:2 height:2];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addTextSize"];
        return NO;
    }
    result = [printer_ addText:@"THE STORE Delivery\n"];
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
    result = [printer_ addText:@"Order Prepared For\n"];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }
    result = [printer_ addTextSize:2 height:2];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addTextSize"];
        return NO;
    }
    result = [printer_ addText:@"TEST B\n\n"];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }
    
    
    result = [printer_ addTextAlign:EPOS2_ALIGN_LEFT];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addTextAlign"];
        return NO;
    }
    result = [printer_ addTextSize:1 height:1];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addTextSize"];
        return NO;
    }
    result = [printer_ addText:@"Ready for delivery : 2/5/2020 4:21:26 PM\n"];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }
    result = [printer_ addText:[NSString stringWithFormat:@"jobNumber   : %d\n", jobNumber]];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }
    result = [printer_ addText:@"Total Items : 3\n\n"];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }
    
    
    result = [printer_ addText:@"1 THE STORE combo\n"];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }
    result = [printer_ addText:@"    1 OHEIDA 3PK SPRINGF\n"];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }
    result = [printer_ addText:@"    1 CANDYMAKER ASSORT\n"];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }
    result = [printer_ addText:@"    1 REPOSE 4PCPM CHOC\n\n"];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }
    
    
    result = [printer_ addTextAlign:EPOS2_ALIGN_CENTER];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addTextAlign"];
        return NO;
    }
    result = [printer_ addText:@"Questions? Contact THE STORE at\n"];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }
    result = [printer_ addText:@"https://www.*****\n"];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addText"];
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

- (BOOL)printData:(int)jobNumber
{
    int result = EPOS2_SUCCESS;

    if (printer_ == nil) {
        return NO;
    }

    if (![self connectLFCPrinter]) {
        [printer_ clearCommandBuffer];
        return NO;
    }

    result = [printer_ sendLFCData:EPOS2_PARAM_DEFAULT jobNumber:jobNumber];
    if (result != EPOS2_SUCCESS) {
        [printer_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"sendLFCData"];
        
        //Note: This API must be used from background thread only
        [printer_ disconnect];
        return NO;
    }
    
    [printer_ clearCommandBuffer];

    return YES;
}

- (BOOL)initializeObject
{
    printer_ = [[Epos2LFCPrinter alloc] initWithPrinterSeries:printerInfo_.printerSeries lang:printerInfo_.lang];

    if (printer_ == nil) {
        [ShowMsg showErrorEpos:EPOS2_ERR_PARAM method:@"initiWithPrinterSeries"];
        return NO;
    }

    [printer_ setSendCompleteEventDelegate:self];

    return YES;
}

- (void)finalizeObject
{
    if (printer_ == nil) {
        return;
    }

    [printer_ setSendCompleteEventDelegate:nil];

    printer_ = nil;
}

-(BOOL)connectLFCPrinter
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

- (void)disconnectLFCPrinter
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

- (NSString *)makeErrorMessage:(Epos2LFCPrinterStatusInfo *)status
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
    return errMsg;
}

- (void)updateJobNumber{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        int jobNumber = [_textJobNumber.text intValue];
        jobNumber++;
        NSString *str = [NSString stringWithFormat:@"%d", jobNumber];
        _textJobNumber.text = str;
    }];
}

- (void)dispLogs:(NSString *)log{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self->_textLog.text = [self->_textLog.text stringByAppendingString:log];
        [self scrollText:self->_textLog];
    }];
}
- (void)scrollText:(UITextView *)text
{
    NSRange range;
    range = text.selectedRange;
    range.location = text.text.length;
    text.selectedRange = range;
    text.scrollEnabled = YES;
    
    CGFloat scrollY = text.contentSize.height + text.font.pointSize - text.bounds.size.height;
    CGPoint scrollPoint;
    
    if (scrollY < 0) {
        scrollY = 0;
    }
    
    scrollPoint = CGPointMake(0.0, scrollY);
    
    [text setContentOffset:scrollPoint animated:YES];
}


- (void)onSelectPrinter:(NSString *)target
{
    _textTarget.text = target;
     printerInfo_.target = target;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *view = nil;

    if ([segue.identifier isEqualToString:@"DiscoveryView"]) {

        view = (DiscoveryViewController *)[segue destinationViewController];

        ((DiscoveryViewController *)view).delegate = self;
    }
}

- (int)convertPrinterSeriesString2Enum:(NSString *)seriesStr {
    int series = EPOS2_TM_M10;
    
    if([seriesStr compare:NSLocalizedString(@"printerseries_l100", @"")] == NSOrderedSame){
        series = EPOS2_TM_L100;
    }
    return series;
}

- (void)onSelectPickerItem:(NSInteger)position obj:(id)obj
{
    if (obj == printerList_) {
        NSString *seriesStr = [printerList_ getItem:position];
        [_buttonPrinter setTitle:seriesStr forState:UIControlStateNormal];
        printerInfo_.printerSeries = [self convertPrinterSeriesString2Enum:seriesStr];
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

- (void)onSendComplete:(Epos2LFCPrinter *)lfcPrinterObj jobNumber:(long)jobNumber code:(int)code status:(Epos2LFCPrinterStatusInfo *)status
{
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        NSString *stringCode = [ShowMsg getEposResultText:code];
        NSString *stringJobNumber = [NSString stringWithFormat:@"%ld", jobNumber];
        NSString *stringStatus = [self makeErrorMessage:status];
        NSMutableString *msg = [NSMutableString stringWithFormat:@"[onSendComplete]code : %1$@, jobNumber : %2$@, status : %3$@\n",stringCode,stringJobNumber,stringStatus];
        [self dispLogs:msg];
        [self disconnectLFCPrinter];
        [self hideIndicator];
    }];
}

@end
