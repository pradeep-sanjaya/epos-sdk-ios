#import <Foundation/Foundation.h>
#import "SingleMonitorViewController.h"
#import "ShowMsg.h"


#define KEY_RESULT                  @"Result"
#define KEY_METHOD                  @"Method"
#define DISCONNECT_INTERVAL                  0.5



@interface SingleMonitorViewController() <Epos2PtrStatusChangeDelegate>
@end


@implementation SingleMonitorViewController

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
    _buttonStartMonitor.enabled = YES;
    _buttonStopMonitor.enabled = NO;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:animated];
    
    [self initializeObject];
    _textStatus.text = @"";
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    if(isMonitoring_){
        if([self stopMonitorPrinter]){
            isMonitoring_ = false;
        }
        [self disconnectPrinter];
    }
    
    [self finalizeObject];
    
    [super viewWillDisappear:animated];
    
}
- (IBAction)eventButtonDidPush:(id)sender {
    
    switch (((UIView *)sender).tag) {
        case 0:
        {
            [self showIndicator:NSLocalizedString(@"wait", @"")];
            [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
                if(![self connectPrinter]){
                    [self hideIndicator];
                    return;
                }
                if(![self startMonitorPrinter]){
                    [self disconnectPrinter];
                    [self hideIndicator];
                    return;
                }
                [self hideIndicator];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        _buttonStartMonitor.enabled = NO;
                        _buttonStopMonitor.enabled = YES;
                }];
                isMonitoring_ = true;
            }];
        }
            break;
        case 1:
        {
            [self showIndicator:NSLocalizedString(@"wait", @"")];
            [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
                if(![self stopMonitorPrinter]){
                    [self hideIndicator];
                    return;
                }
                [self disconnectPrinter];
                [self hideIndicator];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        _buttonStartMonitor.enabled = YES;
                        _buttonStopMonitor.enabled = NO;
                }];
                isMonitoring_ = false;
            }];
        }
            break;
        default:
            break;
    }
}

- (void)onPtrStatusChange:(Epos2Printer *)printerObj eventType:(int)eventType
{
    NSString *stringEvent  = [self makeStatusMessage:eventType];
    if(stringEvent != nil){
    
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_textStatus setText:[_textStatus.text stringByAppendingString:stringEvent]];
        }];
    }
}


- (BOOL)initializeObject
{
    printer_ = [[Epos2Printer alloc] initWithPrinterSeries:printerInfo_.printerSeries lang:printerInfo_.lang];

    if (printer_ == nil) {
        [ShowMsg showErrorEpos:EPOS2_ERR_PARAM method:@"initiWithPrinterSeries"];
        return NO;
    }

    [printer_ setStatusChangeEventDelegate:self];

    return YES;
}

- (void)finalizeObject
{
    if (printer_ == nil) {
        return;
    }

    [printer_ setStatusChangeEventDelegate:nil];

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
-(BOOL)startMonitorPrinter
{
    int result = EPOS2_SUCCESS;
    
    //Note: This API must be used from background thread only
    result = [printer_ startMonitor];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"startMonitor"];
        return NO;
    }
    
    return YES;
}
-(BOOL)stopMonitorPrinter
{
    int result = EPOS2_SUCCESS;
    
    result = [printer_ stopMonitor];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"stopMonitor"];
        return NO;
    }
    
    return YES;
}

- (NSString *)makeStatusMessage:(int)status
{
    
    NSMutableString *stringStatus = [[NSMutableString alloc] initWithString:@""];
    if(stringStatus == nil){
        return nil;
    }
    
    switch (status) {
        case EPOS2_EVENT_ONLINE:
            [stringStatus appendString:@"ONLINE"];
            break;
        case EPOS2_EVENT_OFFLINE:
            [stringStatus appendString:@"OFFLINE"];
            break;
        case EPOS2_EVENT_POWER_OFF:
            [stringStatus appendString:@"POWER_OFF"];
            break;
        case EPOS2_EVENT_COVER_CLOSE:
            [stringStatus appendString:@"COVER_CLOSE"];
            break;
        case EPOS2_EVENT_COVER_OPEN:
            [stringStatus appendString:@"COVER_OPEN"];
            break;
        case EPOS2_EVENT_PAPER_OK:
            [stringStatus appendString:@"PAPER_OK"];
            break;
        case EPOS2_EVENT_PAPER_NEAR_END:
            [stringStatus appendString:@"PAPER_NEAR_END"];
            break;
        case EPOS2_EVENT_PAPER_EMPTY:
            [stringStatus appendString:@"PAPER_EMPTY"];
            break;
        case EPOS2_EVENT_DRAWER_HIGH:
            //This status depends on the drawer setting.
            [stringStatus appendString:@"DRAWER_HIGH(Drawer close)"];
            break;
        case EPOS2_EVENT_DRAWER_LOW:
            //This status depends on the drawer setting.
            [stringStatus appendString:@"DRAWER_LOW(Drawer open)"];
            break;
        case EPOS2_EVENT_BATTERY_ENOUGH:
            [stringStatus appendString:@"BATTERY_ENOUGH"];
            break;
        case EPOS2_EVENT_BATTERY_EMPTY:
            [stringStatus appendString:@"BATTERY_EMPTY"];
            break;
        case EPOS2_EVENT_REMOVAL_WAIT_PAPER:
            [stringStatus appendString:@"WAITING_FOR_PAPER_REMOVAL"];
            break;
        case EPOS2_EVENT_REMOVAL_WAIT_NONE:
            [stringStatus appendString:@"NOT_WAITING_FOR_PAPER_REMOVAL"];
            break;
        case EPOS2_EVENT_REMOVAL_DETECT_PAPER:
            [stringStatus appendString:@"REMOVAL_DETECT_PAPER"];
            break;
        case EPOS2_EVENT_REMOVAL_DETECT_PAPER_NONE:
            [stringStatus appendString:@"REMOVAL_DETECT_PAPER_NONE"];
            break;
        case EPOS2_EVENT_REMOVAL_DETECT_UNKOWN:
            [stringStatus appendString:@"REMOVAL_DETECT_UNKOWN"];
            break;
        case EPOS2_EVENT_AUTO_RECOVER_ERROR:
            [stringStatus appendString:@"AUTO_RECOVER_ERROR"];
            break;
        case EPOS2_EVENT_AUTO_RECOVER_OK:
            [stringStatus appendString:@"AUTO_RECOVER_OK"];
            break;
        case EPOS2_EVENT_UNRECOVERABLE_ERROR:
            [stringStatus appendString:@"UNRECOVERABLE_ERROR"];
            break;
        default:
            break;
    }
    
    [stringStatus appendString:@"\n"];
    return stringStatus;
}


@end
