//
//  EPOS2SDKmanager.m
//  ePOS2_POSAppForTerminalModel
//

#import "ePOS2.h"
#import "EPOS2SDKManager.h"

#define DISPLAY_LINE_MAX    20

@implementation EPOS2SDKManager

- (id)init{
    if((self = [super init]))
    {
        apiLog = @"";
    }
    return self;
}

#pragma mark - Discovery
-(BOOL)startDiscovery:(Epos2FilterOption *)filteroption
{
    //Note:If you call "start" API, please call "stop" API.
    //After calling "start" API, you should not call any API in ePOS-SDK until you call "stop" API.
    
    int result = [Epos2Discovery start:filteroption delegate:self];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    if(result != EPOS2_SUCCESS){
        return NO;
    }

    return YES;
}

-(BOOL)stopDiscovery
{
    int result;
    result = [Epos2Discovery stop];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    if(result != EPOS2_SUCCESS){
        return NO;
    }
    
    return YES;
}

- (void) onDiscovery:(Epos2DeviceInfo *)deviceInfo
{
    //Note: TM terminal model can not use target without square bracket. TM terminal model is TM-DT series or TM-i series.
    if([deviceInfo.target rangeOfString:@"["].location != NSNotFound)
    {
        if ([self.delegate respondsToSelector:@selector(onDiscoveryEPOS2SDKManager:deviceInfo:)]){
            [self.delegate onDiscoveryEPOS2SDKManager:self deviceInfo:deviceInfo];
        }
    }
}

#pragma mark - Printer

- (BOOL)initializePrinterObject:(int)printerSeries_
{
    if(printer_ != nil) {
        [self finalizePrinterObject];
    }
    printer_ = [[Epos2Printer alloc] initWithPrinterSeries:printerSeries_ lang:EPOS2_MODEL_ANK];
    if (printer_ == nil) {
    [self showErrorEpos:EPOS2_ERR_MEMORY method:NSStringFromSelector(_cmd)];
        return NO;
    }
    
    [printer_ setReceiveEventDelegate:self];
    [printer_ setConnectionEventDelegate:self];
    
    return YES;
}

- (void)finalizePrinterObject
{
    if (printer_ == nil) {
        return;
    }
    
    [printer_ setReceiveEventDelegate:nil];
    [printer_ setConnectionEventDelegate:nil];
    
    printer_ = nil;
}

- (BOOL)connectPrinter:(NSString *)target
{
    if(printer_ == nil) {
        return NO;
    }
    
    int result = [printer_ connect:target timeout:EPOS2_PARAM_DEFAULT];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    if(result != EPOS2_SUCCESS) {
        return NO;
    }
    
    return YES;
}

- (BOOL)disconnectPrinter
{
    if(printer_ == nil) {
        return NO;
    }
    
    int result = [printer_ disconnect];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    int count = 0;
    
    //Note: Check if the process overlaps with another process in time.
    while(result == EPOS2_ERR_PROCESSING && count < 4) {
        [NSThread sleepForTimeInterval:0.5];
        result = [printer_ disconnect];
        count++;
    }
    if(result != EPOS2_SUCCESS) {
        return NO;
    }
    
    return YES;
}

- (BOOL)sendDataPrinter
{
    if(printer_ == nil) {
        return NO;
    }
    
    int result = [printer_ sendData:EPOS2_PARAM_DEFAULT];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    int count = 0;
    
    //Note: Check if the process overlaps with another process in time.
    while(result == EPOS2_ERR_PROCESSING && count < 50) {
        [NSThread sleepForTimeInterval:0.2];
        result = [printer_ sendData:EPOS2_PARAM_DEFAULT];;
        [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
        count++;
    }
    
    if(result != EPOS2_SUCCESS) {
        return NO;
    }
    return YES;
}

- (void)clearCommandBufferPrinter
{
    int result = [printer_ clearCommandBuffer];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
}

- (BOOL)addFeedLinePrinter:(long)line
{
    if(printer_ == nil) {
        return NO;
    }
    
    int result = [printer_ addFeedLine:line];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    if(result != EPOS2_SUCCESS) {
        return NO;
    }
    
    return YES;
}


- (BOOL)addTextAlignPrinter:(int)align
{
    if(printer_ == nil) {
        return NO;
    }
    
    int result = [printer_ addTextAlign:align];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    if(result != EPOS2_SUCCESS) {
        return NO;
    }
    
    return YES;
}

- (BOOL)addTextSizePrinter:(long)width height:(long)height
{
    if(printer_ == nil) {
        return NO;
    }
    
    int result = [printer_ addTextSize:width height:height];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    if(result != EPOS2_SUCCESS) {
        return NO;
    }
    
    return YES;
}

- (BOOL)addTextPrinter:(NSString*)text
{
    if(printer_ == nil || text == nil) {
        return NO;
    }
    
    int result = [printer_ addText:text];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    if(result != EPOS2_SUCCESS) {
        return NO;
    }
    
    return YES;
}

- (BOOL)addImagePrinter
{
    if(printer_ == nil) {
        return NO;
    }
    
    UIImage *logoData = [UIImage imageNamed:@"store.png"];
    
    int result = [printer_ addImage:logoData x:0 y:0 width:logoData.size.width height:logoData.size.height color:EPOS2_COLOR_1 mode:EPOS2_MODE_MONO halftone:EPOS2_HALFTONE_DITHER brightness:EPOS2_PARAM_DEFAULT compress:EPOS2_COMPRESS_AUTO];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    if(result != EPOS2_SUCCESS) {
        return NO;
    }
    
    return YES;
    
}

- (BOOL)addBarcodePrinter
{
    if(printer_ == nil) {
        return NO;
    }
    
    int result = [printer_ addBarcode:@"01209457" type:EPOS2_BARCODE_CODE39 hri:EPOS2_HRI_BELOW font:EPOS2_FONT_A width:2 height:100];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    if(result != EPOS2_SUCCESS) {
        return NO;
    }
    
    return YES;
}

- (BOOL)addCutPrinter
{
    if(printer_ == nil) {
        return NO;
    }
    
    int result = [printer_ addCut:EPOS2_CUT_FEED];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    if(result != EPOS2_SUCCESS) {

        return NO;
    }
    
    return YES;
}

- (void)onPtrReceive:(Epos2Printer *)printerObj code:(int)code status:(Epos2PrinterStatusInfo *)status printJobId:(NSString *)printJobId
{
    //Note: Don't call connect, disconnect or getStatus API in this on***Receive.
    
    if(printerObj == nil) {
        return;
    }
    [self showCallbackResult:code method:NSStringFromSelector(_cmd)];
    
    if ([self.delegate respondsToSelector:@selector(onPtrReceiveEPOS2SDKManager:code:status:printJobId:)]){
        [self.delegate onPtrReceiveEPOS2SDKManager:self code:code status:status printJobId:printJobId];
    }
    
}

- (BOOL)addPulsePrinter
{
    int result = [printer_ addPulse:EPOS2_PARAM_DEFAULT time:EPOS2_PARAM_DEFAULT];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    if(result != EPOS2_SUCCESS) {
        return NO;
    }
    
    return YES;
}

#pragma mark - LineDisplay

- (BOOL)initializeDisplayObject
{
    if(display_ != nil) {
        [self finalizeDisplayObject];
    }
    display_ = [[Epos2LineDisplay alloc] initWithDisplayModel:EPOS2_DM_D30];
    if (display_ == nil) {
        [self showErrorEpos:EPOS2_ERR_MEMORY method:NSStringFromSelector(_cmd)];
        return NO;
    }
    
    [display_ setReceiveEventDelegate:self];
    
    return YES;
}

- (void)finalizeDisplayObject
{
    if (display_ == nil) {
        return;
    }
    
    [display_ setReceiveEventDelegate:nil];
    
    display_ = nil;
}

- (BOOL)connectLineDisplay:(NSString *)target
{
    if(display_ == nil) {
        return NO;
    }
    
    int result = [display_ connect:target timeout:EPOS2_PARAM_DEFAULT];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    if(result != EPOS2_SUCCESS) {
        return NO;
    }
    
    return YES;
}


- (BOOL)disconnectLineDisplay
{
    if(display_ == nil) {
        return NO;
    }
    
    
    int result = [display_ disconnect];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    int count = 0;
    
    //Note: Check if the process overlaps with another process in time.
    while(result == EPOS2_ERR_PROCESSING && count < 4) {
        [NSThread sleepForTimeInterval:0.5];
        result = [display_ disconnect];
        [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
        count++;
    }
    
    if(result != EPOS2_SUCCESS) {
        return NO;
    }
    
    return YES;
}

- (BOOL)checkConnectionLineDisplay
{
    if(display_ == nil) {
        return NO;
    }
    
    BOOL result = NO;
    Epos2DisplayStatusInfo* statusinfo = [display_ getStatus];
    if(statusinfo != nil) {
        if(statusinfo.connection == EPOS2_TRUE) {
            result = YES;
        } else {
            result = NO;
        }
    }
    
    return result;
}

- (BOOL)sendDataLineDisplay
{
    if(display_ == nil) {
        return NO;
    }
    
    int result = [display_ sendData];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    int count = 0;
    
    //Note: Check if the process overlaps with another process in time.
    while(result == EPOS2_ERR_PROCESSING && count < 50) {
        [NSThread sleepForTimeInterval:0.2];
        result = [display_ sendData];
        [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
        count++;
    }
    if(result != EPOS2_SUCCESS) {
        return NO;
    }
    
    result = [display_ clearCommandBuffer];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    if(result != EPOS2_SUCCESS) {
        return NO;
    }
    
    return YES;
}

- (BOOL)addInitializeLineDisplay
{
    if(display_ == nil) {
        return NO;
    }
    
    int result = [display_ addInitialize];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    if(result != EPOS2_SUCCESS) {
        return NO;
    }
    
    return YES;
}

- (BOOL)addSetCursorPositionLineDisplay:(long)x y:(long)y
{
    if(display_ == nil) {
        return NO;
    }
    
    int result = [display_ addSetCursorPosition:x y:y];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    if (result != EPOS2_SUCCESS) {
        return NO;
    }
    
    return YES;
}

- (BOOL)addTextLineDisplay:(NSString*)data
{
    if(display_ == nil || data == nil) {
        return NO;
    }
    
    int result = [display_ addText:data];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    if(result != EPOS2_SUCCESS) {
        return NO;
    }
    
    return YES;
}
- (NSString *)formatDisplayData:(NSString*)prefix value:(long)value
{
    NSString* displayData = @"";
    NSString* currency = NSLocalizedString(@"currency", nil);
    NSInteger digitValue = [[NSString stringWithFormat:@"%ld",value] length];
    
    NSInteger spaceSize = DISPLAY_LINE_MAX - [prefix length] - [currency length] - digitValue;
    
    //Error
    if(spaceSize < 0){
        displayData = [NSString stringWithFormat:@"%@%ld",currency,value];
        return displayData;
    }
    
    displayData = prefix;
    for(int i = 0; i < spaceSize; i++){
        displayData = [displayData stringByAppendingString:@" "];
    }
    displayData = [displayData stringByAppendingString:[NSString stringWithFormat:@"%@%ld",currency,value]];
    
    return displayData;
}

- (BOOL)indicateDisplay:(NSString *)data
{
    BOOL result = NO;
    if(data == nil) {
        return result;
    }
    
    [self addInitializeLineDisplay];
    [self addSetCursorPositionLineDisplay:1 y:1];
    [self addTextLineDisplay:data];
    result = [self sendDataLineDisplay];
    
    return result;
}

- (void)onDispReceive:(Epos2LineDisplay *)displayObj code:(int)code
{
    //Note: Don't call connect, disconnect or getStatus API in this on***Receive.
    if(displayObj == nil) {
        return;
    }
    
    [self showCallbackResult:code method:NSStringFromSelector(_cmd)];
}


#pragma mark - BarcodeScanner

- (BOOL)initializeScannerObject
{
    if(scanner_ != nil) {
        [self finalizeScannerObject];
    }
    scanner_ = [[Epos2BarcodeScanner alloc] init];
    if (scanner_ == nil) {
        [self showErrorEpos:EPOS2_ERR_MEMORY method:NSStringFromSelector(_cmd)];
        return NO;
    }
    
    [scanner_ setScanEventDelegate:self];
    
    return YES;
}


- (void)finalizeScannerObject
{
    if (scanner_ == nil) {
        return;
    }
    
    [scanner_ setScanEventDelegate:nil];
    
    scanner_ = nil;
}


- (BOOL)connectBarcodeScanner:(NSString *)target
{
    if(scanner_ == nil) {
        return NO;
    }
    
    int result = [scanner_ connect:target timeout:EPOS2_PARAM_DEFAULT];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    if(result != EPOS2_SUCCESS) {
        return NO;
    }

    return YES;
}

- (BOOL)disconnectBarcodeScanner
{
    if(scanner_ == nil) {
        return NO;
    }
    
    int result = [scanner_ disconnect];
    int count = 0;
    //Note: Check if the process overlaps with another process in time.
    while(result == EPOS2_ERR_PROCESSING && count < 4) {
        [NSThread sleepForTimeInterval:0.5];
        result = [scanner_ disconnect];
        count++;
    }
    
    if(result != EPOS2_SUCCESS) {
        [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
        return NO;
    }
    
    return YES;
}

- (void)onScanData:(Epos2BarcodeScanner *)scannerObj scanData:(NSString *)scanData
{
    if(scannerObj == nil || scanData == nil) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(onScanDataEPOS2SDKManager:scanData:)]){
        [self.delegate onScanDataEPOS2SDKManager:self scanData:scanData];
    }
}

#pragma mark - Cashchanger

- (BOOL)initializeCashChangerObject
{
    if(cashChanger_ != nil) {
        [self finalizeCashChangerObject];
    }
    cashChanger_ = [[Epos2CashChanger alloc] init];
    if (cashChanger_ == nil) {
        [self showErrorEpos:EPOS2_ERR_MEMORY method:NSStringFromSelector(_cmd)];
        return NO;
    }
    
    return YES;
}


- (void)finalizeCashChangerObject
{
    if (cashChanger_ == nil) {
        return;
    }
    
    cashChanger_ = nil;
}


- (BOOL)connectCashChanger:(NSString *)target
{
    if(cashChanger_ == nil) {
        return NO;
    }
    
    int result = [cashChanger_ connect:target timeout:EPOS2_PARAM_DEFAULT];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    if(result != EPOS2_SUCCESS) {
        return NO;
    }
    
    [cashChanger_ setDispenseEventDelegate:self];
    [cashChanger_ setDepositEventDelegate:self];
    
    return YES;
}

- (BOOL)disconnectCashChanger
{
    if(cashChanger_ == nil) {
        return NO;
    }
    
    int result = [cashChanger_ disconnect];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    int count = 0;
    
    //Note: Check if the process overlaps with another process in time.
    while(result == EPOS2_ERR_PROCESSING && count < 4) {
        [NSThread sleepForTimeInterval:0.5];
        result = [cashChanger_ disconnect];
        [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
        count++;
    }
    
    if(result != EPOS2_SUCCESS) {
        return NO;
    }
    return YES;
}

- (BOOL)beginDepositCashChanger
{
    BOOL result = NO;
    result = [cashChanger_ beginDeposit];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    if (result != EPOS2_SUCCESS) {
        return NO;
    }
    
    return YES;
}

- (BOOL)pauseDepositCashChanger
{
    BOOL result = NO;
    result = [cashChanger_ pauseDeposit];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    if (result != EPOS2_SUCCESS) {
        return NO;
    }
    return YES;
}

- (BOOL)endDepositCashChanger:(int)config
{
    BOOL result = NO;
    result = [cashChanger_ endDeposit:config];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    if (result != EPOS2_SUCCESS) {
        return NO;
    }
    
    return YES;
}

- (void) onCChangerDeposit:(Epos2CashChanger *)cchangerObj code:(int)code status:(int)status amount:(long)amount data:(NSDictionary *)data
{
    [self showCallbackResultCashChanger:code method:NSStringFromSelector(_cmd)];
    
    if ([self.delegate respondsToSelector:@selector(onCChangerDepositEPOS2SDKManager:code:status:amount:data:)]){
        [self.delegate onCChangerDepositEPOS2SDKManager:self code:code status:status amount:amount data:data];
    }
    
}
- (int) getOposErrorCodeCashChanger{
    int oposCode = 0;
    oposCode = [cashChanger_ getOposErrorCode];
    [self showOposCodeCashChanger:oposCode method:NSStringFromSelector(_cmd)];
    return oposCode;
}

- (BOOL)dispenseChangeCashChanger:(long)cash
{
    BOOL result = NO;
    result = [cashChanger_ dispenseChange:cash];
    [self showErrorEpos:result method:NSStringFromSelector(_cmd)];
    if (result != EPOS2_SUCCESS) {
        return NO;
    }
    
    return YES;
}

- (void) onCChangerDispense:(Epos2CashChanger *)cchangerObj code:(int)code
{
    [self showCallbackResultCashChanger:code method:NSStringFromSelector(_cmd)];
    
    if ([self.delegate respondsToSelector:@selector(onCChangerDispenseEPOS2SDKManager:code:)]){
        [self.delegate onCChangerDispenseEPOS2SDKManager:self code:code];
    }
}

#pragma mark - other

- (void) onConnection:(id)deviceObj eventType:(int)eventType
{
    [self showConnectionEvent:eventType method:NSStringFromSelector(_cmd)];
    
    switch(eventType){
        case EPOS2_EVENT_RECONNECTING:{
            //Note: If RECONNECTING event occur, you should not call connect or disconnect API untill RECONNECT or DISCONNECT event occues.
            if ([self.delegate respondsToSelector:@selector(onReconnectingEPOS2SDKManager)]) {
                [self.delegate onReconnectingEPOS2SDKManager];
            }
            break;
        }
        case EPOS2_EVENT_RECONNECT:{
            if ([self.delegate respondsToSelector:@selector(onReconnectEPOS2SDKManager)]) {
                [self.delegate onReconnectEPOS2SDKManager];
            }
            break;
        }
        case EPOS2_EVENT_DISCONNECT:{
            if ([self.delegate respondsToSelector:@selector(onDisconnectEPOS2SDKManager)]) {
                [self.delegate onDisconnectEPOS2SDKManager];
            }
            break;
        }
        default:
            //not reach
            break;
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
- (NSString *)makeMessage:(int)code
{
    NSString *msg = @"";
    switch (code) {
        case EPOS2_CODE_SUCCESS:
            msg = NSLocalizedString(@"code_success", @"");
            break;
        case EPOS2_CODE_PRINTING:
            msg = NSLocalizedString(@"code_err_printing", @"");
            break;
        case EPOS2_CODE_ERR_AUTORECOVER:
            msg = NSLocalizedString(@"code_err_autorecover", @"");
            break;
        case EPOS2_CODE_ERR_COVER_OPEN:
            msg = NSLocalizedString(@"code_err_cover_open", @"");
            break;
        case EPOS2_CODE_ERR_CUTTER:
            msg = NSLocalizedString(@"code_err_cutter", @"");
            break;
        case EPOS2_CODE_ERR_MECHANICAL:
            msg = NSLocalizedString(@"code_err_mechanical", @"");
            break;
        case EPOS2_CODE_ERR_EMPTY:
            msg = NSLocalizedString(@"code_err_empty", @"");
            break;
        case EPOS2_CODE_ERR_UNRECOVERABLE:
            msg = NSLocalizedString(@"code_err_unrecoveerable", @"");
            break;
        case EPOS2_CODE_ERR_FAILURE:
            msg = NSLocalizedString(@"code_err_failure", @"");
            break;
        case EPOS2_CODE_ERR_NOT_FOUND:
            msg = NSLocalizedString(@"code_err_not_found", @"");
            break;
        case EPOS2_CODE_ERR_SYSTEM:
            msg = NSLocalizedString(@"code_err_system", @"");
            break;
        case EPOS2_CODE_ERR_PORT:
            msg = NSLocalizedString(@"code_err_port", @"");
            break;
        case EPOS2_CODE_ERR_TIMEOUT:
            msg = NSLocalizedString(@"code_err_timeout", @"");
            break;
        case EPOS2_CODE_ERR_JOB_NOT_FOUND:
            msg = NSLocalizedString(@"code_err_job_not_found", @"");
            break;
        case EPOS2_CODE_ERR_SPOOLER:
            msg = NSLocalizedString(@"code_err_spooler", @"");
            break;
        case EPOS2_CODE_ERR_BATTERY_LOW:
            msg = NSLocalizedString(@"code_err_battery_low", @"");
            break;
        case EPOS2_CODE_ERR_TOO_MANY_REQUESTS:
            msg = NSLocalizedString(@"code_err_too_many_request", @"");
            break;
        case EPOS2_CODE_ERR_REQUEST_ENTITY_TOO_LARGE:
            msg = NSLocalizedString(@"code_err_request_entity_too_large", @"");
            break;
        case EPOS2_CODE_ERR_DEVICE_BUSY:
            msg = NSLocalizedString(@"code_err_device_busy", @"");
            break;
        default:
            msg = [NSString stringWithFormat:@"%d", code];
            break;
    }
    return msg;
}

- (void)showErrorEpos:(int)resultCode method:(NSString *)method
{
    NSString *msg = [NSString stringWithFormat:@"%@:%@\n%@:%@\n",
                     NSLocalizedString(@"methoderr_method", @""),
                     method,
                     NSLocalizedString(@"methoderr_errcode", @""),
                     [self getEposErrorText:resultCode]
                     ];
    
    
    if ([self.delegate respondsToSelector:@selector(onLogEPOS2SDKManager:apiLog:)]){
        [self.delegate onLogEPOS2SDKManager:self apiLog:msg];
    }
}

- (void)showCallbackResult:(int)code method:(NSString *)method
{
    NSString *msg = [NSString stringWithFormat:@"%@:%@\n%@:%@\n",
                     NSLocalizedString(@"methoderr_method", @""),
                     method,
                     NSLocalizedString(@"statusmsg_result", @""),
                     [self getEposResultText:code]
                     ];
    

    if ([self.delegate respondsToSelector:@selector(onLogEPOS2SDKManager:apiLog:)]){
        [self.delegate onLogEPOS2SDKManager:self apiLog:msg];
    }
}
- (void)showCallbackResultCashChanger:(int)code method:(NSString *)method
{
    NSString *msg = [NSString stringWithFormat:@"%@:%@\n%@:%@\n",
                     NSLocalizedString(@"methoderr_method", @""),
                     method,
                     NSLocalizedString(@"statusmsg_result", @""),
                     [self getEposResultTextCashChanger:code]
                     ];
    
    
    if ([self.delegate respondsToSelector:@selector(onLogEPOS2SDKManager:apiLog:)]){
        [self.delegate onLogEPOS2SDKManager:self apiLog:msg];
    }
}

- (void)showOposCodeCashChanger:(int)oposCode method:(NSString *)method
{
    NSString *msg = [NSString stringWithFormat:@"%@:%@\n%@:%d\n",
                     NSLocalizedString(@"methoderr_method", @""),
                     method,
                     NSLocalizedString(@"opos_code", @""),
                     oposCode];
    
    
    if ([self.delegate respondsToSelector:@selector(onLogEPOS2SDKManager:apiLog:)]){
        [self.delegate onLogEPOS2SDKManager:self apiLog:msg];
    }
}
- (void)showConnectionEvent:(int)eventType method:(NSString *)method
{
    NSString *msg = [NSString stringWithFormat:@"%@:%@\n%@:%@\n",
                     NSLocalizedString(@"methoderr_method", @""),
                     method,
                     NSLocalizedString(@"methoderr_eventtype", @""),
                     [self getEposConnectionEventText:eventType]
                     ];
    
    
    if ([self.delegate respondsToSelector:@selector(onLogEPOS2SDKManager:apiLog:)]){
        [self.delegate onLogEPOS2SDKManager:self apiLog:msg];
    }
}



//convert Epos2Printer Error to text
- (NSString *)getEposErrorText:(int)error
{
    NSString *errText = @"";
    switch (error) {
        case EPOS2_SUCCESS:
            errText = @"SUCCESS";
            break;
        case EPOS2_ERR_PARAM:
            errText = @"ERR_PARAM";
            break;
        case EPOS2_ERR_CONNECT:
            errText = @"ERR_CONNECT";
            break;
        case EPOS2_ERR_TIMEOUT:
            errText = @"ERR_TIMEOUT";
            break;
        case EPOS2_ERR_MEMORY:
            errText = @"ERR_MEMORY";
            break;
        case EPOS2_ERR_ILLEGAL:
            errText = @"ERR_ILLEGAL";
            break;
        case EPOS2_ERR_PROCESSING:
            errText = @"ERR_PROCESSING";
            break;
        case EPOS2_ERR_NOT_FOUND:
            errText = @"ERR_NOT_FOUND";
            break;
        case EPOS2_ERR_IN_USE:
            errText = @"ERR_IN_USE";
            break;
        case EPOS2_ERR_TYPE_INVALID:
            errText = @"ERR_TYPE_INVALID";
            break;
        case EPOS2_ERR_DISCONNECT:
            errText = @"ERR_DISCONNECT";
            break;
        case EPOS2_ERR_ALREADY_OPENED:
            errText = @"ERR_ALREADY_OPENED";
            break;
        case EPOS2_ERR_ALREADY_USED:
            errText = @"ERR_ALREADY_USED";
            break;
        case EPOS2_ERR_BOX_COUNT_OVER:
            errText = @"ERR_BOX_COUNT_OVER";
            break;
        case EPOS2_ERR_BOX_CLIENT_OVER:
            errText = @"ERR_BOXT_CLIENT_OVER";
            break;
        case EPOS2_ERR_UNSUPPORTED:
            errText = @"ERR_UNSUPPORTED";
            break;
        case EPOS2_ERR_FAILURE:
            errText = @"ERR_FAILURE";
            break;
        default:
            errText = [NSString stringWithFormat:@"%d", error];
            break;
    }
    return errText;
}

//convert Epos2BluetoothConnection Error to text
- (NSString *)getEposBtErrorText:(int)error
{
    NSString *errText = @"";
    switch (error) {
        case EPOS2_BT_SUCCESS:
            errText = @"SUCCESS";
            break;
        case EPOS2_BT_ERR_PARAM:
            errText = @"ERR_PARAM";
            break;
        case EPOS2_BT_ERR_UNSUPPORTED:
            errText = @"ERR_UNSUPPORTED";
            break;
        case EPOS2_BT_ERR_CANCEL:
            errText = @"ERR_CANCEL";
            break;
        case EPOS2_BT_ERR_ALREADY_CONNECT:
            errText = @"ERR_ALREADY_CONNECT";
            break;
        case EPOS2_BT_ERR_ILLEGAL_DEVICE:
            errText = @"ERR_ILLEGAL_DEVICE";
            break;
        case EPOS2_BT_ERR_FAILURE:
            errText = @"ERR_FAILURE";
            break;
        default:
            errText = [NSString stringWithFormat:@"%d", error];
            break;
    }
    return errText;
}

//convert Epos2 Result code to text
- (NSString *)getEposResultText:(int)resultCode
{
    NSString *result = @"";
    switch (resultCode) {
        case EPOS2_CODE_SUCCESS:
            result = @"SUCCESS";
            break;
        case EPOS2_CODE_PRINTING:
            result = @"PRINTING";
            break;
        case EPOS2_CODE_ERR_AUTORECOVER:
            result = @"ERR_AUTORECOVER";
            break;
        case EPOS2_CODE_ERR_COVER_OPEN:
            result = @"ERR_COVER_OPEN";
            break;
        case EPOS2_CODE_ERR_CUTTER:
            result = @"ERR_CUTTER";
            break;
        case EPOS2_CODE_ERR_MECHANICAL:
            result = @"ERR_MECHANICAL";
            break;
        case EPOS2_CODE_ERR_EMPTY:
            result = @"ERR_EMPTY";
            break;
        case EPOS2_CODE_ERR_UNRECOVERABLE:
            result = @"ERR_UNRECOVERABLE";
            break;
        case EPOS2_CODE_ERR_FAILURE:
            result = @"ERR_FAILURE";
            break;
        case EPOS2_CODE_ERR_NOT_FOUND:
            result = @"ERR_NOT_FOUND";
            break;
        case EPOS2_CODE_ERR_SYSTEM:
            result = @"ERR_SYSTEM";
            break;
        case EPOS2_CODE_ERR_PORT:
            result = @"ERR_PORT";
            break;
        case EPOS2_CODE_ERR_TIMEOUT:
            result = @"ERR_TIMEOUT";
            break;
        case EPOS2_CODE_ERR_JOB_NOT_FOUND:
            result = @"ERR_JOB_NOT_FOUND";
            break;
        case EPOS2_CODE_ERR_SPOOLER:
            result = @"ERR_SPOOLER";
            break;
        case EPOS2_CODE_ERR_BATTERY_LOW:
            result = @"ERR_BATTERY_LOW";
            break;
        case EPOS2_CODE_ERR_TOO_MANY_REQUESTS:
            result = @"ERR_TOO_MANY_REQUESTS";
            break;
        case EPOS2_CODE_ERR_REQUEST_ENTITY_TOO_LARGE:
            result = @"ERR_REQUEST_ENTITY_TOO_LARGE";
            break;
        default:
            result = [NSString stringWithFormat:@"%d", resultCode];
            break;
    }
    
    return result;
}
//convert Epos2CashChanger Result code to text
- (NSString *)getEposResultTextCashChanger:(int)resultCode
{
    NSString *result = @"";
    switch (resultCode) {
        case EPOS2_CCHANGER_CODE_SUCCESS:
            result = @"SUCCESS";
            break;
        case EPOS2_CCHANGER_CODE_BUSY:
            result = @"BUSY";
            break;
        case EPOS2_CCHANGER_CODE_DISCREPANCY:
            result = @"DISCREPANCY";
            break;
        case EPOS2_CCHANGER_CODE_ERR_CASH_IN_TRAY:
            result = @"CASH_IN_TRAY";
            break;
        case EPOS2_CCHANGER_CODE_ERR_SHORTAGE:
            result = @"ERR_SHORTAGE";
            break;
        case EPOS2_CCHANGER_CODE_ERR_REJECT_UNIT:
            result = @"ERR_REJECT_UNIT";
            break;
        case EPOS2_CCHANGER_CODE_ERR_OPOSCODE:
            result = @"ERR_OPOSCODE";
            break;
        case EPOS2_CCHANGER_CODE_ERR_UNSUPPORTED:
            result = @"ERR_UNSUPPORTED";
            break;
        case EPOS2_CCHANGER_CODE_ERR_PARAM:
            result = @"ERR_PARAM";
            break;
        case EPOS2_CCHANGER_CODE_ERR_COMMAND:
            result = @"ERR_COMMAND";
            break;
        case EPOS2_CCHANGER_CODE_ERR_DEVICE:
            result = @"ERR_DEVICE";
            break;
        case EPOS2_CCHANGER_CODE_ERR_SYSTEM:
            result = @"ERR_SYSTEM";
            break;
        case EPOS2_CCHANGER_CODE_ERR_FAILURE:
            result = @"ERR_FAILURE";
            break;
        default:
            result = [NSString stringWithFormat:@"%d", resultCode];
            break;
    }
    return result;
}
- (NSString *)getStatusTextCashChanger:(int)status
{
    NSString *text = @"";
    switch (status) {
        case EPOS2_CCHANGER_STATUS_BUSY:
            text = @"Busy";
            break;
        case EPOS2_CCHANGER_STATUS_PAUSE:
            text = @"Pause";
            break;
        case EPOS2_CCHANGER_STATUS_END:
            text = @"End";
            break;
        case EPOS2_CCHANGER_STATUS_ERR:
            text = @"Error";
            break;
        default:
            text = [NSString stringWithFormat:@"%d", status];
            break;
    }
    return text;
}
- (NSString *)getEposConnectionEventText:(int)resultCode
{
    NSString *text = @"";
    switch (resultCode) {
        case EPOS2_EVENT_RECONNECTING:
            text = @"EVENT_RECONNECTING";
            break;
        case EPOS2_EVENT_RECONNECT:
            text = @"EVENT_RECONNECT";
            break;
        case EPOS2_EVENT_DISCONNECT:
            text = @"EVENT_DISCONNECT";
            break;
        default:
            text = [NSString stringWithFormat:@"%d", resultCode];
            break;
    }
    return text;
}

@end
