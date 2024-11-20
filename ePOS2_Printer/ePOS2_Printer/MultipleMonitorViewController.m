#import <Foundation/Foundation.h>
#import "MultipleMonitorViewController.h"
#import "ShowMsg.h"


#define KEY_RESULT                  @"Result"
#define KEY_METHOD                  @"Method"
#define MONITOR_INTERVAL                  3
#define DISCONNECT_INTERVAL                  0.5


@implementation MultipleMonitorViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        printer_ = nil;
        printerInfo_ = [PrinterInfo sharedPrinterInfo];
        isMonitoring_ = false;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    _buttonStartGetstatus.enabled = YES;
    _buttonStopGetstatus.enabled = NO;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    queueForMonitor_ = [[NSOperationQueue alloc] init];
    queueForMonitor_.maxConcurrentOperationCount = 1;
    
    [self initializeObject];
    _textStatus.text = @"";
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    if(isMonitoring_){
        [self stopGetStatus];
    }
    
    [self finalizeObject];
    
    queueForMonitor_ = nil;
    
    [super viewWillDisappear:animated];
    
}

- (IBAction)eventButtonDidPush:(id)sender {
    switch (((UIView *)sender).tag) {
        case 0:
            [self startGetStatus];
            break;
        case 1:
            [self stopGetStatus];
            break;
        default:
            break;
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if(isMonitoring_){
            _buttonStartGetstatus.enabled = NO;
            _buttonStopGetstatus.enabled = YES;
        }else{
            _buttonStartGetstatus.enabled = YES;
            _buttonStopGetstatus.enabled = NO;
        }
    }];
    
}

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
    printer_ = nil;
}
-(BOOL)startGetStatus
{
    if(isMonitoring_){
        return NO;
    }
    
    if (printer_ == nil) {
        return NO;
    }
    
    isMonitoring_= true;
    
    [queueForMonitor_ addOperationWithBlock:^{
        
        int result = EPOS2_SUCCESS;
        Epos2PrinterStatusInfo *info;
        while(isMonitoring_){
            //Note: This API must be used from background thread only
            result = [printer_ connect:printerInfo_.target timeout:EPOS2_PARAM_DEFAULT];
            
            info = [printer_ getStatus];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSString *msg = [self makeStatusMessage:info];
                if(msg != nil){
                    [_textStatus setText:msg];
                }
            }];
            if (result == EPOS2_SUCCESS) {
                //Note: This API must be used from background thread only
                result = [printer_ disconnect];
                int count = 0;
                //Note: Check if the process overlaps with another process in time.
                while(result == EPOS2_ERR_PROCESSING && count < 4) {
                    [NSThread sleepForTimeInterval:DISCONNECT_INTERVAL];
                    result = [printer_ disconnect];
                    count++;
                }
            }
            
            //The short INTERVAL value generates a heavy network load.
            //Please set a appropriate value in accordance with the network situation.
            [NSThread sleepForTimeInterval:MONITOR_INTERVAL];
        }
    }];
    
    return YES;
}
-(BOOL)stopGetStatus
{
    if(!isMonitoring_){
        return NO;
    }
    isMonitoring_= false;
    [queueForMonitor_ waitUntilAllOperationsAreFinished];

    
    return YES;
}

- (NSString *)makeStatusMessage:(Epos2PrinterStatusInfo *)status
{
    NSMutableString *statusMsg = [[NSMutableString alloc] initWithString:@""];
    if((status == nil) || (statusMsg == nil)){
        return nil;
    }
    
    [statusMsg appendString:@"connection:"];
    switch(status.connection){
        case EPOS2_TRUE:
            [statusMsg appendString:@"CONNECT"];
            break;
        case EPOS2_FALSE:
            [statusMsg appendString:@"DISCONNECT"];
            break;
        case EPOS2_UNKNOWN:
            [statusMsg appendString:@"UNKNOWN"];
            break;
        default:
            break;
    }
    [statusMsg appendString:@"\n"];
    
    [statusMsg appendString:@"online:"];
    switch(status.online){
        case EPOS2_TRUE:
            [statusMsg appendString:@"ONLINE"];
            break;
        case EPOS2_FALSE:
            [statusMsg appendString:@"OFFLINE"];
            break;
        case EPOS2_UNKNOWN:
            [statusMsg appendString:@"UNKNOWN"];
            break;
        default:
            break;
    }
    [statusMsg appendString:@"\n"];
    
    [statusMsg appendString:@"coverOpen:"];
    switch(status.coverOpen){
        case EPOS2_TRUE:
            [statusMsg appendString:@"COVER_OPEN"];
            break;
        case EPOS2_FALSE:
            [statusMsg appendString:@"COVER_CLOSE"];
            break;
        case EPOS2_UNKNOWN:
            [statusMsg appendString:@"UNKNOWN"];
            break;
        default:
            break;
    }
    [statusMsg appendString:@"\n"];
    
    [statusMsg appendString:@"paper:"];
    switch(status.paper){
        case EPOS2_PAPER_OK:
            [statusMsg appendString:@"PAPER_OK"];
            break;
        case EPOS2_PAPER_NEAR_END:
            [statusMsg appendString:@"PAPER_NEAR_END"];
            break;
        case EPOS2_PAPER_EMPTY:
            [statusMsg appendString:@"PAPER_EMPTY"];
            break;
        case EPOS2_UNKNOWN:
            [statusMsg appendString:@"UNKNOWN"];
            break;
        default:
            break;
    }
    [statusMsg appendString:@"\n"];
    
    [statusMsg appendString:@"paperFeed:"];
    switch(status.paperFeed){
        case EPOS2_TRUE:
            [statusMsg appendString:@"PAPER_FEED"];
            break;
        case EPOS2_FALSE:
            [statusMsg appendString:@"PAPER_STOP"];
            break;
        case EPOS2_UNKNOWN:
            [statusMsg appendString:@"UNKNOWN"];
            break;
        default:
            break;
    }
    [statusMsg appendString:@"\n"];
    
    [statusMsg appendString:@"panelSwitch:"];
    switch(status.panelSwitch){
        case EPOS2_TRUE:
            [statusMsg appendString:@"SWITCH_ON"];
            break;
        case EPOS2_FALSE:
            [statusMsg appendString:@"SWITCH_OFF"];
            break;
        case EPOS2_UNKNOWN:
            [statusMsg appendString:@"UNKNOWN"];
            break;
        default:
            break;
    }
    [statusMsg appendString:@"\n"];
    
    [statusMsg appendString:@"drawer:"];
    switch(status.drawer){
        case EPOS2_DRAWER_HIGH:
            //This status depends on the drawer setting.
            [statusMsg appendString:@"DRAWER_HIGH(Drawer close)"];
            break;
        case EPOS2_DRAWER_LOW:
            //This status depends on the drawer setting.
            [statusMsg appendString:@"DRAWER_LOW(Drawer open)"];
            break;
        case EPOS2_UNKNOWN:
            [statusMsg appendString:@"UNKNOWN"];
            break;
        default:
            break;
    }
    [statusMsg appendString:@"\n"];
    
    [statusMsg appendString:@"errorStatus:"];
    switch(status.errorStatus){
        case EPOS2_NO_ERR:
            [statusMsg appendString:@"NO_ERR"];
            break;
        case EPOS2_MECHANICAL_ERR:
            [statusMsg appendString:@"MECHANICAL_ERR"];
            break;
        case EPOS2_AUTOCUTTER_ERR:
            [statusMsg appendString:@"AUTOCUTTER_ERR"];
            break;
        case EPOS2_UNRECOVER_ERR:
            [statusMsg appendString:@"UNRECOVER_ERR"];
            break;
        case EPOS2_AUTORECOVER_ERR:
            [statusMsg appendString:@"AUTORECOVER_ERR"];
            break;
        case EPOS2_UNKNOWN:
            [statusMsg appendString:@"UNKNOWN"];
            break;
        default:
            break;
    }
    [statusMsg appendString:@"\n"];
    
    [statusMsg appendString:@"autoRecoverErr:"];
    switch(status.autoRecoverError){
        case EPOS2_HEAD_OVERHEAT:
            [statusMsg appendString:@"HEAD_OVERHEAT"];
            break;
        case EPOS2_MOTOR_OVERHEAT:
            [statusMsg appendString:@"MOTOR_OVERHEAT"];
            break;
        case EPOS2_BATTERY_OVERHEAT:
            [statusMsg appendString:@"BATTERY_OVERHEAT"];
            break;
        case EPOS2_WRONG_PAPER:
            [statusMsg appendString:@"WRONG_PAPER"];
            break;
        case EPOS2_COVER_OPEN:
            [statusMsg appendString:@"COVER_OPEN"];
            break;
        case EPOS2_UNKNOWN:
            [statusMsg appendString:@"UNKNOWN"];
            break;
        default:
            break;
    }
    [statusMsg appendString:@"\n"];
    
    [statusMsg appendString:@"adapter:"];
    switch(status.adapter){
        case EPOS2_TRUE:
            [statusMsg appendString:@"AC ADAPTER CONNECT"];
            break;
        case EPOS2_FALSE:
            [statusMsg appendString:@"AC ADAPTER DISCONNECT"];
            break;
        case EPOS2_UNKNOWN:
            [statusMsg appendString:@"UNKNOWN"];
            break;
        default:
            break;
    }
    [statusMsg appendString:@"\n"];
    
    [statusMsg appendString:@"batteryLevel:"];
    switch(status.batteryLevel){
        case EPOS2_BATTERY_LEVEL_0:
            [statusMsg appendString:@"BATTERY_LEVEL_0"];
            break;
        case EPOS2_BATTERY_LEVEL_1:
            [statusMsg appendString:@"BATTERY_LEVEL_1"];
            break;
        case EPOS2_BATTERY_LEVEL_2:
            [statusMsg appendString:@"BATTERY_LEVEL_2"];
            break;
        case EPOS2_BATTERY_LEVEL_3:
            [statusMsg appendString:@"BATTERY_LEVEL_3"];
            break;
        case EPOS2_BATTERY_LEVEL_4:
            [statusMsg appendString:@"BATTERY_LEVEL_4"];
            break;
        case EPOS2_BATTERY_LEVEL_5:
            [statusMsg appendString:@"BATTERY_LEVEL_5"];
            break;
        case EPOS2_BATTERY_LEVEL_6:
            [statusMsg appendString:@"BATTERY_LEVEL_6"];
            break;
        case EPOS2_UNKNOWN:
            [statusMsg appendString:@"UNKNOWN"];
            break;
        default:
            break;
    }
    [statusMsg appendString:@"\n"];
    
    [statusMsg appendString:@"removalWaiting:"];
    switch(status.removalWaiting){
        case EPOS2_REMOVAL_WAIT_PAPER:
            [statusMsg appendString:@"WAITING_FOR_PAPER_REMOVAL"];
            break;
        case EPOS2_REMOVAL_WAIT_NONE:
            [statusMsg appendString:@"NOT_WAITING_FOR_PAPER_REMOVAL"];
            break;
        case EPOS2_UNKNOWN:
            [statusMsg appendString:@"UNKNOWN"];
            break;
        default:
            break;
    }
    [statusMsg appendString:@"\n"];
    
    [statusMsg appendString:@"paperTakenSensor:"];
    switch(status.paperTakenSensor){
        case EPOS2_REMOVAL_DETECT_PAPER:
            [statusMsg appendString:@"REMOVAL_DETECT_PAPER"];
            break;
        case EPOS2_REMOVAL_DETECT_PAPER_NONE:
            [statusMsg appendString:@"REMOVAL_DETECT_PAPER_NONE"];
            break;
        case EPOS2_REMOVAL_DETECT_UNKNOWN:
            [statusMsg appendString:@"REMOVAL_DETECT_UNKNOWN"];
            break;
        default:
            break;
    }
    [statusMsg appendString:@"\n"];
    
    [statusMsg appendString:@"unrecoverError:"];
    switch(status.unrecoverError){
        case EPOS2_HIGH_VOLTAGE_ERR:
            [statusMsg appendString:@"HIGH_VOLTAGE_ERR"];
            break;
        case EPOS2_LOW_VOLTAGE_ERR:
            [statusMsg appendString:@"LOW_VOLTAGE_ERR"];
            break;
        case EPOS2_UNKNOWN:
            [statusMsg appendString:@"UNKNOWN"];
            break;
        default:
            break;
    }
    [statusMsg appendString:@"\n"];
    
    return statusMsg;
}


@end
