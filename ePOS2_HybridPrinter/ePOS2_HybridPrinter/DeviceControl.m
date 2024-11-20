//
//  DeviceControl.m
//  ePOS2_HybridPrinter
//
#import "DeviceControl.h"
#import "ShowMsg.h"

@implementation DeviceControl

- (id) initWithPrinter:(Epos2HybridPrinter*)hybridPrinter ConnectTarget:(NSString*)connectTarget
{
    self = [super init];
    if (self) {
        connectTarget_ = nil;
        
        hybridPrinter_ = hybridPrinter;
        if(hybridPrinter_ != nil){
            connectTarget_ = connectTarget;
            warningText_ = @"";
            errorCodeOnReceive_ = EPOS2_SUCCESS;
            semaphoreOnReceive_ = [[ESemaphore alloc] init];
            semaphoreOnEjectPaper_ = [[ESemaphore alloc] init];
        }
        firstControlType_ = DEVICE_CONTROL_NONE;
        nextControlType_ = DEVICE_CONTROL_NONE;
    }
    
    return self;
}

- (void) setFirstControlType:(enum DeviceControlType) controlType
{
    firstControlType_ = controlType;
}

- (void) setNextControlType:(enum DeviceControlType) controlType
{
    nextControlType_ = controlType;
}

- (BOOL) checkErrorStatus
{
    warningText_ = @"";
    Epos2HybridPrinterStatusInfo *status = nil;
    
    status = [hybridPrinter_ getStatus];
    warningText_ = [self makeWarningsMessage:status];
    
    if (![self isPrintable:status]) {
        [ShowMsg show:[self makeErrorMessage:status]];
        return NO;
    }
    
    return YES;
}

- (BOOL) startSequence
{
    BOOL result = YES;
    warningText_ = @"";
    
    if (hybridPrinter_ == nil) {
        return NO;
    }
    
    [hybridPrinter_ setStatusChangeEventDelegate:self];
    [hybridPrinter_ setReceiveEventDelegate:self];
    
    if(firstControlType_ != DEVICE_CONTROL_NONE)
    {
        if (![self connectHybridPrinter]) {
            return NO;
        }
    }

    if (![self selectPaperType]) {
        result = NO;
    }

    if(result) {
        if (![self insertPaper]) {
            result = NO;
        }
    }

    if(result) {
        if (![self addData]) {
            result = NO;
        }
    }

    if(result) {
        if (![self sendData]) {
            result = NO;
        }
        [self clearData];
    }

    if(result) {
        if(nextControlType_ == DEVICE_CONTROL_NONE) {
            if (![self ejectPaper]) {
                result = NO;
            }
            [self disconnectHybridPrinter];
        }
        else if(nextControlType_ == DEVICE_CONTROL_RECEIPT) {
            if (![self ejectPaper]) {
                result = NO;
            }
        }
        else{
        }
    }

    if(result == NO) {
        [self disconnectHybridPrinter];
    }

    return result;
}

- (NSString*) getWarningText
{
    return warningText_;
}

- (BOOL) addData
{
    if(hybridPrinter_ == nil){
        return NO;
    }
    
    return YES;
}

- (void) clearData
{
}

- (BOOL) connectHybridPrinter
{
    int result = EPOS2_SUCCESS;

    if (hybridPrinter_ == nil) {
        return NO;
    }

    result = [hybridPrinter_ connect:connectTarget_ timeout:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEposOnMainThread:result method:@"connect"];
        return NO;
    }
    
    if(result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ beginTransaction];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"beginTransaction"];
        }
    }

    if(result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ startMonitor];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"startMonitor"];
        }
    }

    return (result == EPOS2_SUCCESS);
}

- (void) disconnectHybridPrinter
{
    int result = EPOS2_SUCCESS;
    
    if (hybridPrinter_ == nil) {
        return;
    }
    
    result = [hybridPrinter_ endTransaction];
    if (result != EPOS2_SUCCESS) {
    }
    
    result = [hybridPrinter_ stopMonitor];
    if (result != EPOS2_SUCCESS) {
    }
    
    result = [hybridPrinter_ disconnect];
    if (result != EPOS2_SUCCESS) {
    }
}

- (BOOL) isPrintable:(Epos2HybridPrinterStatusInfo *)status
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
        ;//print available
    }
    
    return YES;
}

- (BOOL) selectPaperType
{
    if (hybridPrinter_ == nil) {
        return NO;
    }
    
    return YES;
}

- (BOOL) sendData
{
    if (hybridPrinter_ == nil) {
        return NO;
    }

    return YES;
}

- (BOOL) insertPaper
{
    if(hybridPrinter_ == nil){
        return NO;
    }
    
    if(![self checkErrorStatus]){
        return NO;
    }
    
    return YES;
}

- (BOOL) ejectPaper
{
    if(hybridPrinter_ == nil){
        return NO;
    }
    
    return YES;
}

- (void) onHybdStatusChange:(Epos2HybridPrinter *)hybridPrinterObj eventType:(int)eventType
{
    switch(eventType)
    {
        case EPOS2_EVENT_INSERTION_WAIT_MICR:
            [ShowMsg showOnMainThread:@"Please insert the check"];
            break;
            
        case EPOS2_EVENT_INSERTION_WAIT_SLIP:
        case EPOS2_EVENT_INSERTION_WAIT_VALIDATION:
            [ShowMsg showOnMainThread:@"Please insert the paper"];
            break;
            
        case EPOS2_EVENT_REMOVAL_WAIT_PAPER:
            [ShowMsg showOnMainThread:@"Please remove the paper"];
            break;
            
        case EPOS2_EVENT_REMOVAL_WAIT_NONE:
        case EPOS2_EVENT_SLIP_PAPER_EMPTY:
        case EPOS2_EVENT_POWER_OFF:
            [self signalOnEject];
            break;
            
        default:
            break;
    }
}

- (void) onHybdReceive:(Epos2HybridPrinter *)hybridPrinterObj method:(int)method code:(int)code micrData:(NSString *)micrData status:(Epos2HybridPrinterStatusInfo *)status
{
    if(code != EPOS2_CODE_SUCCESS) {
        [ShowMsg showResultOnMainThread:code errMsg:[self makeErrorMessage:status]];
        errorCodeOnReceive_ = EPOS2_ERR_ILLEGAL;
    }
    else {
        errorCodeOnReceive_ = EPOS2_SUCCESS;
    }
    
    [self signalOnHybdReceive];
}

- (void) waitOnHybdReceiveStart
{
    [semaphoreOnReceive_ startWaiting];
}

- (int) waitOnHybdReceive
{
    errorCodeOnReceive_ = EPOS2_SUCCESS;
    
    [semaphoreOnReceive_ wait];
    
    return errorCodeOnReceive_;
}

- (void) signalOnHybdReceive
{
    [semaphoreOnReceive_ signal];
}

- (void) waitOnEjectStart
{
    [semaphoreOnEjectPaper_ startWaiting];
}

- (void) waitOnEject
{
    [semaphoreOnEjectPaper_ wait];
}

- (void) signalOnEject
{
    [semaphoreOnEjectPaper_ signal];
}

- (NSString *)makeWarningsMessage:(Epos2HybridPrinterStatusInfo *)status
{
    NSMutableString *warningMsg = [[NSMutableString alloc] initWithString:@""];
    
    if (status == nil) {
        return warningMsg;
    }
    
    if (status.paper == EPOS2_PAPER_NEAR_END) {
        [warningMsg appendString:NSLocalizedString(@"warn_receipt_near_end", @"")];
    }
    
    return warningMsg;
}

- (NSString *)makeErrorMessage:(Epos2HybridPrinterStatusInfo *)status
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
    
    return errMsg;
}

@end
