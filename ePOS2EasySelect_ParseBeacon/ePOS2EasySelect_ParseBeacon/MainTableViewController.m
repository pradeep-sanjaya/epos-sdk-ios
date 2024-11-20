#import "BeaconCustomCell.h"
#import "BeaconPrinterInfo.h"
#import "IndicatorView.h"
#import "MainTableViewController.h"
#import "ShowMsg.h"
#import "Utility.h"

#import "ePOSEasySelect.h"
#import "ePOS2.h"

static NSString *const UUID = @"fac1ba2f-61a2-4d83-9a8c-60087c232569";
static NSString *const identifier = @"com.xxx.ePOS2EasySelect_ParseBeacon";

static NSString *const beaconCellIdentifier = @"BeaconCustomCell";

typedef NS_ENUM(NSInteger, DemoAppError) { DemoAppErrorPrint = 0 };

@interface MainTableViewController ()<Epos2PtrReceiveDelegate> {
    EposEasySelectInfo  *easySelectInfo_;
    IndicatorView       *indicatorView_;
    NSString            *lastPrintingTarget_;
    
    Epos2Printer        *printer_;
}

@property (strong, nonatomic) CLLocationManager *manager;
@property (strong, nonatomic) CLBeaconRegion *region;
@property (strong, nonatomic) NSArray *printerList;
@property (weak, nonatomic) IBOutlet UITextView *textWarnings;

@end

@implementation MainTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        easySelectInfo_ = nil;
        indicatorView_ = nil;
        lastPrintingTarget_ = @"";
        
        printer_ = nil;
        
        self.manager = nil;
        self.region = nil;
        self.printerList = nil;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"ePOS2EasySelect ParseBeacon";
    self.printerList = nil;
    [self setWarningText:@""];
    [self initializeMonitoring];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.region) {
        [self.manager startRangingBeaconsInRegion:self.region];  // start monitoring
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.region) {
        [self.manager stopRangingBeaconsInRegion:self.region];  // stop monitoring
    }
}

- (void)initializeMonitoring
{
    // Create CLLocationManager
    self.manager = [[CLLocationManager alloc] init];
    self.manager.delegate = self;
    
    if ([self.manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.manager requestWhenInUseAuthorization];
    }
    
    // Create parameter
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:UUID];
    self.region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:identifier];
    
    self.region.notifyOnEntry = NO;
    self.region.notifyOnExit = NO;
    self.region.notifyEntryStateOnDisplay = NO;
    
}

//----------------------------------------------------------------------------//
#pragma mark - CLLocationManagerDelegate
//----------------------------------------------------------------------------//
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if ((status == kCLAuthorizationStatusDenied) || (status == kCLAuthorizationStatusNotDetermined) ) {
        if ([self.manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.manager requestWhenInUseAuthorization];
        }
    }else if ((status == kCLAuthorizationStatusAuthorizedWhenInUse) || (status == kCLAuthorizationStatusAuthorizedAlways)){
        if (self.region) {
            [self.manager startRangingBeaconsInRegion:self.region];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region
{

    NSMutableArray *tmpPrinterList = [NSMutableArray array];
    
    // Parse & set printer Information
    for (CLBeacon *beacon in beacons) {
        
        @autoreleasepool {
            
            if (CLProximityUnknown == beacon.proximity) {
                BeaconPrinterInfo *printerInfo = [self getReliabilityBeaconPrinterInfo:beacon];
                if (!printerInfo) {
                    continue;
                }
                printerInfo.reliable = NO;
                [tmpPrinterList addObject:printerInfo];
            }
            else {
                EposEasySelect *easySelect = [[EposEasySelect alloc] init];
                EposEasySelectInfo *eposEasySelectInfo = [easySelect parseBeacon:beacon];
                if (eposEasySelectInfo) {
                    BeaconPrinterInfo *printerInfo = [[BeaconPrinterInfo alloc] init];
                    printerInfo.tag = [beacon.minor intValue];
                    printerInfo.beacon = beacon;
                    printerInfo.easyselectInfo = eposEasySelectInfo;
                    printerInfo.reliable = YES;
                 
                    [tmpPrinterList addObject:printerInfo];
                }
            }
        }
    }
    
    // sort by RSSI
    self.printerList = [self sortBeaconPrinterInfoList:tmpPrinterList];
    
    
    [self.tableView reloadData];
}


#pragma mark - Beacon Printer List Utility Function
- (NSArray *)sortBeaconPrinterInfoList:(NSArray *)printerList
{
    return [printerList sortedArrayUsingComparator:^(BeaconPrinterInfo *obj1, BeaconPrinterInfo *obj2) {
        
        NSInteger rssi1 = obj1.beacon.rssi;
        NSInteger rssi2 = obj2.beacon.rssi;
        
        if (rssi1 > rssi2) {
            return NSOrderedAscending;
        }
        else if (rssi1 == rssi2) {
            return NSOrderedSame;
        }
        else {
            return NSOrderedDescending;
        }
    }];
}


- (BeaconPrinterInfo *)getReliabilityBeaconPrinterInfo:(CLBeacon *)currentBeacon
{
    for (BeaconPrinterInfo *printerInfo in self.printerList) {
        if (printerInfo.reliable &&                                // reliability
            [printerInfo.beacon.proximityUUID isEqual:currentBeacon.proximityUUID] &&  // same UUID
            [printerInfo.beacon.major isEqual:currentBeacon.major] &&                  // same major
            [printerInfo.beacon.minor isEqual:currentBeacon.minor])                    // same mminor
            
        {
            return printerInfo;
        }
    }
    
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self.printerList count] == 0) {
        [self setWarningText:@""];
    }
    
    return [self.printerList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 84;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BeaconCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:beaconCellIdentifier];
    
    if (!cell) {
        cell =
        [[BeaconCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:beaconCellIdentifier];
    }
    
    BeaconPrinterInfo *printerInfo = self.printerList[indexPath.row];
    BOOL select = NO;
    if (indexPath.row == 0) {
        select = YES;
        if (![lastPrintingTarget_ isEqualToString:printerInfo.easyselectInfo.target]) {
            [self setWarningText:@""];
        }
    }
    
    [cell setPrinterInfomation:printerInfo selected:select];
    return cell;
}

//----------------------------------------------------------------------------//
#pragma mark - indicator control
//----------------------------------------------------------------------------//
- (void)showIndicator
{
    indicatorView_ = [[IndicatorView alloc] init];
    [indicatorView_ show:[[UIApplication sharedApplication] keyWindow]];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
}

- (void)hideIndicator
{
    [indicatorView_ hide];
    indicatorView_ = nil;
}

//----------------------------------------------------------------------------//
#pragma mark - Printing Sequence
//----------------------------------------------------------------------------//
- (IBAction)onTapPrintButton:(id)sender
{
    BeaconPrinterInfo *printerInfo = self.printerList[0];
    
    UIButton *printButton = sender;
    if ([printButton tag] == [printerInfo tag]) {
        [self showIndicator];
        
        // set target printer information
        easySelectInfo_ = printerInfo.easyselectInfo;
        lastPrintingTarget_ = easySelectInfo_.target;
        
        if (![self runPrintSequence]) {
            [self hideIndicator];
        }
    }
    else {
        // beacon list already changed
    }
    
    return;
}

- (BOOL)runPrintSequence
{
    if (!easySelectInfo_) {
        return NO;
    }
    if ([easySelectInfo_.target length] == 0) {
        return NO;
    }
    
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
    NSString *address = [NSString stringWithFormat:@"Network Address:%@", easySelectInfo_.target];
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
    
    // Create target string
    NSString *targetText = [Utility convertEasySelectInfoToTargetString:easySelectInfo_];
    if ([targetText isEqualToString:@""]) {
        return NO;
    }
    
    result = [printer_ connect:targetText timeout:EPOS2_PARAM_DEFAULT];
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
    [self hideIndicator];
    
    [ShowMsg showResult:code errMsg:[self makeErrorMessage:status]];
    
    [self dispPrinterWarnings:status];
    
    [self performSelectorInBackground:@selector(disconnectPrinter) withObject:nil];
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
    
    easySelectInfo_ = nil;
    printer_ = nil;
}

//----------------------------------------------------------------------------//
#pragma mark - Error Message Method
//----------------------------------------------------------------------------//

- (void)dispPrinterWarnings:(Epos2PrinterStatusInfo *)status
{
    NSMutableString *warningMsg = [[NSMutableString alloc] init];
    
    if (status == nil) {
        [self setWarningText:@""];
        return;
    }
    
    if (status.paper == EPOS2_PAPER_NEAR_END) {
        [warningMsg appendString:NSLocalizedString(@"warn_receipt_near_end", @"")];
    }
    
    if (status.batteryLevel == EPOS2_BATTERY_LEVEL_1) {
        [warningMsg appendString:NSLocalizedString(@"warn_battery_near_end", @"")];
    }
    
    [self setWarningText:warningMsg];
}

- (void) setWarningText:(NSString *)msg
{
    if (0 == [msg length]) {
        _textWarnings.text = @"";
        _textWarnings.hidden = YES;
    }else {
        _textWarnings.text = msg;
        _textWarnings.hidden = NO;
    }
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
