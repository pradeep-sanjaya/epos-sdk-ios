#import <Foundation/Foundation.h>
#import "SettingViewController.h"
#import "SettingViewController+Utility.h"
#import "ShowMsg.h"
#import <mach/mach.h>

#define KEY_RESULT                  @"Result"
#define KEY_METHOD                  @"Method"
#define DISCONNECT_INTERVAL                  0.5
#define RESTART_INTERVAL 60

@interface SettingViewController() <SelectPickerTableDelegate, Epos2MaintenanceCounterDelegate, Epos2PrinterSettingDelegate>
@end

@implementation SettingViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        printer_ = nil;
        printerInfo_ = [PrinterInfo sharedPrinterInfo];
        
        printerSeries_ = printerInfo_.printerSeries;
        lang_ = printerInfo_.lang;
        
        // Set default Parameter
        printSpeed = EPOS2_PRINTER_SETTING_PRINTSPEED_1;
        printDensity = EPOS2_PRINTER_SETTING_PRINTDENSITY_DIP;
        paperWidth = EPOS2_PRINTER_SETTING_PAPERWIDTH_58_0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set default setting.
    [_buttonPrintSpeed setTitle:[self convertPrintSpeedEnum2String:printSpeed] forState:UIControlStateNormal];
    [_buttonPrintDensity setTitle:[self convertPrintDensityEnum2String:printDensity] forState:UIControlStateNormal];
    [_buttonPaperWidth setTitle:[self convertPaperWidthEnum2String:paperWidth] forState:UIControlStateNormal];
    
    // Set default count
    _labelPaperFeed.text = @"0";
    _labelAutoCutter.text = @"0";
    
    // Initialize restart message view
    [self hideIndicator];
    
    // Initialize utils
    [self initPickerTable];
    
    [self updateButtonState:NO];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    //check POS terminal model connection
    NSRange range = [printerInfo_.target rangeOfString:@"["];
    if (range.location != NSNotFound) {
        // Back connection setting view due to POS terminal model is not supported.
        [ShowMsg showErrorEpos:EPOS2_ERR_PARAM method:@"Setting API do not support POS terminal model"];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if( [self initializeObject] == NO ){
        // Back connection setting view when fail to create instance.
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [self showIndicator:NSLocalizedString(@"wait", @"")];
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        if([self connectPrinter]){
            [self updateButtonState:YES];
        }
        [self hideIndicator];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self showIndicator:NSLocalizedString(@"wait", @"")];
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        [self disconnectPrinter];
        [self finalizeObject];
        [self hideIndicator];
    }];
}

- (void)updateButtonState:(BOOL)state
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _buttonGetMaintenanceCut.enabled = state;
        _buttonResetMaintenanceCut.enabled = state;
        _buttonGetMaintenanceFeed.enabled = state;
        _buttonResetMaintenanceFeed.enabled = state;
        _buttonGetSpeed.enabled = state;
        _buttonSetSpeed.enabled = state;
        _buttonGetDensity.enabled = state;
        _buttonSetDensity.enabled = state;
        _buttonGetWidth.enabled = state;
        _buttonSetWidth.enabled = state;
    }];
}



// Picker to select setting
- (void)initPickerTable {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    printSpeedList_ = [[PickerTableView alloc] init];
    [items addObject:NSLocalizedString(@"printspeed_1", @"")];
    [items addObject:NSLocalizedString(@"printspeed_2", @"")];
    [items addObject:NSLocalizedString(@"printspeed_3", @"")];
    [items addObject:NSLocalizedString(@"printspeed_4", @"")];
    [items addObject:NSLocalizedString(@"printspeed_5", @"")];
    [items addObject:NSLocalizedString(@"printspeed_6", @"")];
    [items addObject:NSLocalizedString(@"printspeed_7", @"")];
    [items addObject:NSLocalizedString(@"printspeed_8", @"")];
    [items addObject:NSLocalizedString(@"printspeed_9", @"")];
    [items addObject:NSLocalizedString(@"printspeed_10", @"")];
    [items addObject:NSLocalizedString(@"printspeed_11", @"")];
    [items addObject:NSLocalizedString(@"printspeed_12", @"")];
    [items addObject:NSLocalizedString(@"printspeed_13", @"")];
    [items addObject:NSLocalizedString(@"printspeed_14", @"")];
    [items addObject:NSLocalizedString(@"printspeed_15", @"")];
    [items addObject:NSLocalizedString(@"printspeed_16", @"")];
    [items addObject:NSLocalizedString(@"printspeed_17", @"")];
    [printSpeedList_ setItemList:items];
    printSpeedList_.delegate = self;
    
    items = [[NSMutableArray alloc] init];
    printDensityList_ = [[PickerTableView alloc] init];
    [items addObject:NSLocalizedString(@"printdensity_DIP", @"")];
    [items addObject:NSLocalizedString(@"printdensity_70", @"")];
    [items addObject:NSLocalizedString(@"printdensity_75", @"")];
    [items addObject:NSLocalizedString(@"printdensity_80", @"")];
    [items addObject:NSLocalizedString(@"printdensity_85", @"")];
    [items addObject:NSLocalizedString(@"printdensity_90", @"")];
    [items addObject:NSLocalizedString(@"printdensity_95", @"")];
    [items addObject:NSLocalizedString(@"printdensity_100", @"")];
    [items addObject:NSLocalizedString(@"printdensity_105", @"")];
    [items addObject:NSLocalizedString(@"printdensity_110", @"")];
    [items addObject:NSLocalizedString(@"printdensity_115", @"")];
    [items addObject:NSLocalizedString(@"printdensity_120", @"")];
    [items addObject:NSLocalizedString(@"printdensity_125", @"")];
    [items addObject:NSLocalizedString(@"printdensity_130", @"")];
    [printDensityList_ setItemList:items];
    printDensityList_.delegate = self;
    
    items = [[NSMutableArray alloc] init];
    paperWidthList_ = [[PickerTableView alloc] init];
    [items addObject:NSLocalizedString(@"paperwidth_58", @"")];
    [items addObject:NSLocalizedString(@"paperwidth_60", @"")];
    [items addObject:NSLocalizedString(@"paperwidth_70", @"")];
    [items addObject:NSLocalizedString(@"paperwidth_76", @"")];
    [items addObject:NSLocalizedString(@"paperwidth_80", @"")];
    [paperWidthList_ setItemList:items];
    paperWidthList_.delegate = self;
}

- (void)onSelectPickerItem:(NSInteger)position obj:(id)obj
{
    if (obj == printSpeedList_) {
        NSString *speedStr = [printSpeedList_ getItem:position];
        [_buttonPrintSpeed setTitle:speedStr forState:UIControlStateNormal];
        printSpeed = [self convertPrintSpeedString2Enum:speedStr];
    }
    if (obj == printDensityList_) {
        NSString *densityStr = [printDensityList_ getItem:position];
        [_buttonPrintDensity setTitle:densityStr forState:UIControlStateNormal];
        printDensity = [self convertPrintDeinsityString2Enum:densityStr];
    }
    if (obj == paperWidthList_) {
        NSString *widthStr = [paperWidthList_ getItem:position];
        [_buttonPaperWidth setTitle:widthStr forState:UIControlStateNormal];
        paperWidth = [self convertPaperWidthString2Enum:widthStr];
    }
}


// Maintenance Couter
- (IBAction)getAutoCutterCount:(id)sender {
    int result = EPOS2_SUCCESS;
    
    result = [printer_ getMaintenanceCounter:EPOS2_PARAM_DEFAULT type:EPOS2_MAINTENANCE_COUNTER_AUTOCUTTER delegate:self];
    if(result != EPOS2_SUCCESS){
        [ShowMsg showErrorEpos:result method:@"getMaintenanceCounter"];
    }
}
- (IBAction)getPaperFeedRow:(id)sender {
    int result = EPOS2_SUCCESS;
    
    result = [printer_ getMaintenanceCounter:EPOS2_PARAM_DEFAULT type:EPOS2_MAINTENANCE_COUNTER_PAPERFEED delegate:self];
    if(result != EPOS2_SUCCESS){
        [ShowMsg showErrorEpos:result method:@"getMaintenanceCounter"];
    }
}

- (void)onGetMaintenanceCounter:(int)code type:(int)type value:(int)value {
    if(code != EPOS2_CODE_SUCCESS){
        [ShowMsg showErrorEposCode:code method:@"getMaintenanceCounter"];
        return;
    }
    
    [self changeMaintenanceCounterLabel:type value:value];
}
- (void)changeMaintenanceCounterLabel:(int)type value:(int)value {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        switch (type) {
            case EPOS2_MAINTENANCE_COUNTER_AUTOCUTTER:
                _labelAutoCutter.text = [NSString stringWithFormat:@"%d", value];
                [self.view setNeedsDisplay];
                break;
            case EPOS2_MAINTENANCE_COUNTER_PAPERFEED:
                _labelPaperFeed.text = [NSString stringWithFormat:@"%d", value];
                [self.view setNeedsDisplay];
                break;
            default:
                break;
        }
    }];
}

- (IBAction)resetAutoCutterCount:(id)sender {
    int result = EPOS2_SUCCESS;
    
    result = [printer_ resetMaintenanceCounter:EPOS2_PARAM_DEFAULT type:EPOS2_MAINTENANCE_COUNTER_AUTOCUTTER delegate:self];
    if(result != EPOS2_SUCCESS){
        [ShowMsg showErrorEpos:result method:@"resetMaintenanceCounter"];
    }
}
- (IBAction)resetPaperFeedRow:(id)sender {
    int result = EPOS2_SUCCESS;
    
    result = [printer_ resetMaintenanceCounter:EPOS2_PARAM_DEFAULT type:EPOS2_MAINTENANCE_COUNTER_PAPERFEED delegate:self];
    if(result != EPOS2_SUCCESS){
        [ShowMsg showErrorEpos:result method:@"resetMaintenanceCounter"];
    }
}

- (void)onResetMaintenanceCounter:(int)code type:(int)type {
    if(code != EPOS2_CODE_SUCCESS){
        [ShowMsg showErrorEposCode:code method:@"resetMaintenanceCounter"];
        return;
    }
    
    // When reset success, get current count to confirmation.
    switch (type) {
        case EPOS2_MAINTENANCE_COUNTER_AUTOCUTTER:
            [self getAutoCutterCount:nil];
            break;
        case EPOS2_MAINTENANCE_COUNTER_PAPERFEED:
            [self getPaperFeedRow:nil];
            break;
        default:
            break;
    }
}


// Printer Setting
- (IBAction)getPrintSpeed:(id)sender {
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        int result = EPOS2_SUCCESS;
    
        //Note: This API must be used from background thread only
        result = [printer_ getPrinterSetting:EPOS2_PARAM_DEFAULT type:EPOS2_PRINTER_SETTING_PRINTSPEED delegate:self];
        if(result != EPOS2_SUCCESS){
            [ShowMsg showErrorEpos:result method:@"getPrinterSetting"];
        }
    }];
}
- (IBAction)getPrintDensity:(id)sender {
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        int result = EPOS2_SUCCESS;
    
        //Note: This API must be used from background thread only
        result = [printer_ getPrinterSetting:EPOS2_PARAM_DEFAULT type:EPOS2_PRINTER_SETTING_PRINTDENSITY delegate:self];
        if(result != EPOS2_SUCCESS){
            [ShowMsg showErrorEpos:result method:@"getPrinterSetting"];
        }
    }];
}
- (IBAction)getPaperWidth:(id)sender {
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        int result = EPOS2_SUCCESS;
    
        //Note: This API must be used from background thread only
        result = [printer_ getPrinterSetting:EPOS2_PARAM_DEFAULT type:EPOS2_PRINTER_SETTING_PAPERWIDTH delegate:self];
        if(result != EPOS2_SUCCESS){
            [ShowMsg showErrorEpos:result method:@"getPrinterSetting"];
        }
    }];
}

- (void)onGetPrinterSetting:(int)code type:(int)type value:(int)value {
    if(code != EPOS2_CODE_SUCCESS){
        [ShowMsg showErrorEposCode:code method:@"getPrinterSetting"];
        return;
    }
    
    [self changePrinterSettingLabel:type value:value];
}
- (void)changePrinterSettingLabel:(int)type value:(int)value {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        switch (type) {
            case EPOS2_PRINTER_SETTING_PRINTSPEED:
                printSpeed = value;
                [_buttonPrintSpeed setTitle:[self convertPrintSpeedEnum2String:value] forState:UIControlStateNormal];
                [self.view setNeedsDisplay];
                break;
            case EPOS2_PRINTER_SETTING_PRINTDENSITY:
                printDensity = value;
                [_buttonPrintDensity setTitle:[self convertPrintDensityEnum2String:value] forState:UIControlStateNormal];
                [self.view setNeedsDisplay];
                break;
            case EPOS2_PRINTER_SETTING_PAPERWIDTH:
                paperWidth = value;
                [_buttonPaperWidth setTitle:[self convertPaperWidthEnum2String:value] forState:UIControlStateNormal];
                [self.view setNeedsDisplay];
                break;
            default:
                break;
        }
    }];
}

- (IBAction)setPrintSpeed:(id)sender {
    int result = EPOS2_SUCCESS;
    
    NSMutableDictionary *settingList = [NSMutableDictionary dictionary];
    [settingList setObject:[NSNumber numberWithInt:printSpeed] forKey:[NSNumber numberWithInt:EPOS2_PRINTER_SETTING_PRINTSPEED]];
    result = [printer_ setPrinterSetting:EPOS2_PARAM_DEFAULT setttingList:settingList delegate:self];
    if(result != EPOS2_SUCCESS){
        [ShowMsg showErrorEpos:result method:@"setPrinterSetting"];
        return;
    }
    
    // Show wating restart message. onSetPrinterSetting stop this message.
    [self showIndicator:NSLocalizedString(@"restart_msg", @"")];
}

- (IBAction)setPrintDensity:(id)sender {
    int result = EPOS2_SUCCESS;
    
    NSMutableDictionary *settingList = [NSMutableDictionary dictionary];
    [settingList setObject:[NSNumber numberWithInt:printDensity] forKey:[NSNumber numberWithInt:EPOS2_PRINTER_SETTING_PRINTDENSITY]];
    
    result = [printer_ setPrinterSetting:EPOS2_PARAM_DEFAULT setttingList:settingList delegate:self];
    if(result != EPOS2_SUCCESS){
        [ShowMsg showErrorEpos:result method:@"setPrinterSetting"];
        return;
    }
    
    // Show wating restart message. onSetPrinterSetting stop this message.
    [self showIndicator:NSLocalizedString(@"restart_msg", @"")];
    
}

- (IBAction)setPaperWidth:(id)sender {
    int result = EPOS2_SUCCESS;
    
    NSMutableDictionary *settingList = [NSMutableDictionary dictionary];
    [settingList setObject:[NSNumber numberWithInt:paperWidth] forKey:[NSNumber numberWithInt:EPOS2_PRINTER_SETTING_PAPERWIDTH]];
    
    result = [printer_ setPrinterSetting:EPOS2_PARAM_DEFAULT setttingList:settingList delegate:self];
    if(result != EPOS2_SUCCESS){
        [ShowMsg showErrorEpos:result method:@"setPrinterSetting"];
        return;
    }
    
    // Show wating restart message. onSetPrinterSetting stop this message.
    [self showIndicator:NSLocalizedString(@"restart_msg", @"")];
}

- (void)onSetPrinterSetting:(int)code {
    if(code != EPOS2_CODE_SUCCESS){
        [self hideIndicator];
        [ShowMsg showErrorEposCode:code method:@"setPrinterSetting"];
        return;
    }
    
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        [self reconnectPrinter];
    }];

}

- (void)reconnectPrinter {
    // Reconect printer with 3 sec interval until 120 sec done.
    int ret = [self reconnect:120 interval:3];
    // Hide wating restart message
    [self hideIndicator];
    // If error, back connection setting view to confirm connection setting.
    if(ret == NO){
        [ShowMsg showErrorEposCode:EPOS2_CODE_ERR_CONNECT method:@"setPrinterSetting"];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        return;
    }
    
    [ShowMsg show:NSLocalizedString(@"settings_msg", @"")];
}

- (BOOL)reconnect:(int)maxWaitTimeSec interval:(int)interval {
    int result = EPOS2_SUCCESS;
    uint64_t startTime, elapsedTime, elapsedTimeMillSec;
    static mach_timebase_info_data_t timeBaseInfo;
    
    startTime = mach_absolute_time();
    
    //Note: This API must be used from background thread only
    result = [printer_ disconnect];

    // Sleep RESTART_INTERVAL sec due to some printer do not available immediately after power on. see your printer's spec sheet.
    sleep(RESTART_INTERVAL);
    do {
        //Note: This API must be used from background thread only
        result = [printer_ connect:printerInfo_.target timeout:interval * 1000];

        elapsedTime = mach_absolute_time() - startTime;
        if(timeBaseInfo.denom == 0) {
            (void)mach_timebase_info(&timeBaseInfo);
        }
        elapsedTimeMillSec = (elapsedTime * timeBaseInfo.numer / timeBaseInfo.denom) / 1000000;
        if (elapsedTimeMillSec > maxWaitTimeSec * 1000) {
            return NO;
        }
        [NSThread sleepForTimeInterval:0.05];
    } while (result != EPOS2_SUCCESS);

    return YES;
}

// Picker control
- (IBAction)showPrintSpeedPicker:(id)sender {
    [printSpeedList_ show];
}
- (IBAction)showPrintDensityPicker:(id)sender {
    [printDensityList_ show];
}
- (IBAction)showPaperWidthPicker:(id)sender {
    [paperWidthList_ show];
}


// Printer control
- (BOOL)initializeObject
{
    printer_ = [[Epos2Printer alloc] initWithPrinterSeries:printerInfo_.printerSeries lang:printerInfo_.lang];
    if (printer_ == nil) {
        [ShowMsg showErrorEpos:EPOS2_ERR_PARAM method:@"initiWithPrinterSeries"];
        return NO;
    }
    
    return YES;
}

- (void)finalizeObject
{
    if (printer_ == nil) {
        return;
    }
    
    [printer_ clearCommandBuffer];
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
}

@end
