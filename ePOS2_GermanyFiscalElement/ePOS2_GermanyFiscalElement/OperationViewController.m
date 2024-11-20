#import "OperationViewController.h"

@interface OperationViewController ()
@property (nonatomic, strong) NSTimer* posTimer;
@end

@implementation OperationViewController

static const int64_t registrationLimitTime = 30.0;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self buttunItemInit];

    startTransactionLock_ = [[NSLock alloc] init];
    timerLock_ = [[NSLock alloc] init];
    gfeSemaphore = dispatch_semaphore_create(0);
    prnSemaphore = dispatch_semaphore_create(0);
    dspSemaphore = dispatch_semaphore_create(0);
    timerSemaphore = dispatch_semaphore_create(0);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self buttunItemInit];
    _textOperation.text = @"";
    itemList_ = [[EposPurchaseItemList alloc] init];
    completeStartTransaction_ = NO;

    ePOS2SDKManager = [[EPOS2SDKManager alloc] init];
    ePOS2SDKManager.delegate = self;

    queueForSDK = [[NSOperationQueue alloc] init];
    queueForSDK.maxConcurrentOperationCount = 1;

    queueTimer = nil;

    [queueForSDK addOperationWithBlock:^{
        [ePOS2SDKManager initializeGfeObject];
        [ePOS2SDKManager initializePrinterObject:printerSeries_];
        [ePOS2SDKManager initializeDisplayObject];
        [ePOS2SDKManager initializeScannerObject];
    }];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self buttunItemInit];
    _textOperation.text = @"";
    [queueForSDK addOperationWithBlock:^{
        ePOS2SDKManager.delegate = nil;
        [self finalizeAllDevices];

        challenge_ = nil;
    }];

    itemList_ = nil;
}

- (void)buttunItemInit
{
    _buttonOpenStore.enabled = YES;
    _buttonCloseStore.enabled = NO;
    _buttonCheck.enabled = NO;
    [self buttonItemEnable:NO];
}

- (void)buttonItemEnable:(BOOL)enable
{
    if(enable) {
        _buttonItem1.enabled = YES;
        _buttonItem2.enabled = YES;
        _buttonItem3.enabled = YES;
        _buttonItem4.enabled = YES;
        _buttonItem5.enabled = YES;
        _buttonItem6.enabled = YES;
        _buttonItem7.enabled = YES;
        _buttonItem8.enabled = YES;
        _buttonItem9.enabled = YES;
        _buttonItem10.enabled = YES;
    } else {
        _buttonItem1.enabled = NO;
        _buttonItem2.enabled = NO;
        _buttonItem3.enabled = NO;
        _buttonItem4.enabled = NO;
        _buttonItem5.enabled = NO;
        _buttonItem6.enabled = NO;
        _buttonItem7.enabled = NO;
        _buttonItem8.enabled = NO;
        _buttonItem9.enabled = NO;
        _buttonItem10.enabled = NO;
    }
}

// Please be sure todo it once at the time of accounting.
- (BOOL)enqueueStartTransaction
{
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        [startTransactionLock_ lock];
        if(!completeStartTransaction_) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self beginProcess];
            }];
            [queueForSDK addOperationWithBlock:^{
                [self operateStartTransaction];
                [startTransactionLock_ unlock];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self endProcess];
                }];
            }];
        }else{
            [startTransactionLock_ unlock];
        }
    }];

    return YES;
}

- (BOOL)startTimeMeasurement
{
    if(completeStartTransaction_) {
        if([timerLock_ tryLock]) {
            queueTimer = [[NSOperationQueue alloc] init];
            queueTimer.maxConcurrentOperationCount = 1;
            [queueTimer addOperationWithBlock:^{
                dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, (NSEC_PER_SEC * registrationLimitTime));
                dispatch_semaphore_wait(timerSemaphore, timeout);
                [queueForSDK addOperationWithBlock:^{
                    [self operateUpdateTransaction];
                    [timerLock_ unlock];

                    queueTimer = nil;
                }];
            }];
        }
    }
    return YES;
}

- (void) finalizeAllDevices
{
    [ePOS2SDKManager finalizeGfeObject];
    [ePOS2SDKManager finalizePrinterObject];
    if(enableScanner_){
        [ePOS2SDKManager finalizeScannerObject];
    }
    if(enableDisplay_){
        [ePOS2SDKManager finalizeDisplayObject];
    }
}

- (BOOL) disconnectAllDevices
{
    BOOL result = YES;

    if([ePOS2SDKManager disconnectGermanyFiscalElement] == NO) {
        result = NO;
    }

    if([ePOS2SDKManager disconnectPrinter] == NO){
        result = NO;
    };
    if(enableScanner_){
        if([ePOS2SDKManager disconnectBarcodeScanner] == NO){
            result = NO;
        };
    }
    if(enableDisplay_){
        if([ePOS2SDKManager disconnectLineDisplay] == NO){
            result = NO;
        };
    }


    return result;
}

- (BOOL)operateUpdateTime
{
    NSString* jsonFunc_tmp = NSLocalizedString(@"operate_func_updateTime", nil);
    NSString* userId = clientId_;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    NSString* newDateTime = [dateFormatter stringFromDate:[NSDate date]];

    NSString* jsonFunc_updateTime = [NSString stringWithFormat:jsonFunc_tmp, userId, newDateTime];

    BOOL result = [ePOS2SDKManager operateGermanyFiscalElement:jsonFunc_updateTime timeout:EPOS2_PARAM_DEFAULT];
    if(result == YES) {
        result = [super waitCallbackEvent:ePOS2SDKManager semaphore:gfeSemaphore method:NSStringFromSelector(_cmd) timeout:EPOS2_PARAM_DEFAULT];
    }

    return result;
}

- (BOOL)operateAuthenticateUserForTimeAdmin
{
    // GetChallenge
    BOOL result = [self operateGetChallenge:ePOS2SDKManager userId:clientId_];
    if(result == YES) {
        result = [super waitCallbackEvent:ePOS2SDKManager semaphore:gfeSemaphore method:NSStringFromSelector(_cmd) timeout:EPOS2_PARAM_DEFAULT];
    }

    if(challenge_ == nil) {
        return NO;
    }
    // Hash calculationTime
    NSString* secretKey = NSLocalizedString(@"secretKey", nil);
    NSString* input = [challenge_ stringByAppendingString:secretKey];
    NSString* hash= [self calculateHash:input];

    result = [self operateAuthenticateUserForTimeAdmin:ePOS2SDKManager hash:hash];
    if(result == YES) {
        result = [super waitCallbackEvent:ePOS2SDKManager semaphore:gfeSemaphore method:NSStringFromSelector(_cmd) timeout:EPOS2_PARAM_DEFAULT];
    }

    return result;
}

- (BOOL)operateLogOutForTimeAdmin
{
    BOOL result = [self operateLogOutForTimeAdmin:ePOS2SDKManager];
    if(result == YES) {
        result = [super waitCallbackEvent:ePOS2SDKManager semaphore:gfeSemaphore method:NSStringFromSelector(_cmd) timeout:EPOS2_PARAM_DEFAULT];
    }

    return result;
}

- (BOOL)operateStartTransaction
{
    NSString* jsonFunc_tmp= NSLocalizedString(@"operate_func_startTransaction", nil);
    NSString* processData = [self convertBase64String:[itemList_ createTransactionData]];
    NSString* processDataType = NSLocalizedString(@"processTypeStart", nil);

    NSString* jsonFunc_startTransaction = [NSString stringWithFormat:jsonFunc_tmp, clientId_, processData ,processDataType];

    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd-MM-yyyy-HH:mm:ss";
    startDateTime_ = [dateFormatter stringFromDate:[NSDate date]];

    BOOL result = [ePOS2SDKManager operateGermanyFiscalElement:jsonFunc_startTransaction timeout:EPOS2_PARAM_DEFAULT];
    if(result == YES) {
        result = [super waitCallbackEvent:ePOS2SDKManager semaphore:gfeSemaphore method:NSStringFromSelector(_cmd) timeout:EPOS2_PARAM_DEFAULT];
        completeStartTransaction_ = YES;
    }

    return result;
}

- (BOOL)operateUpdateTransaction
{
    NSString* jsonFunc_tmp= NSLocalizedString(@"operate_func_updateTransaction", nil);
    NSString* processData = [self convertBase64String:[itemList_ createTransactionData]];
    NSString* processDataType = NSLocalizedString(@"processTypeUpdate", nil);

    NSString* jsonFunc_updateTransaction = [NSString stringWithFormat:jsonFunc_tmp, clientId_, transactionNumber_, processData ,processDataType];
    BOOL result = [ePOS2SDKManager operateGermanyFiscalElement:jsonFunc_updateTransaction timeout:EPOS2_PARAM_DEFAULT];
    if(result == YES) {
        result = [super waitCallbackEvent:ePOS2SDKManager semaphore:gfeSemaphore method:NSStringFromSelector(_cmd) timeout:EPOS2_PARAM_DEFAULT];
    }

    return result;
}

- (BOOL)operateFinishTransaction
{
    NSString* jsonFunc_tmp= NSLocalizedString(@"operate_func_finishTransaction", nil);
    NSString* tmpProcessData = [itemList_ createTransactionData];
    tmpProcessData = [tmpProcessData stringByAppendingString:@"[TOTAL,"];
    tmpProcessData = [tmpProcessData stringByAppendingString:[itemList_ createTotalAmountData]];
    tmpProcessData = [tmpProcessData stringByAppendingString:@"]"];
    tmpProcessData = [tmpProcessData stringByAppendingString:@"[PAYMENT,"];
    tmpProcessData = [tmpProcessData stringByAppendingString:[itemList_ createTotalAmountData]];
    tmpProcessData = [tmpProcessData stringByAppendingString:@"]"];
    NSString* processData = [self convertBase64String:tmpProcessData];
    NSString* processDataType = NSLocalizedString(@"processTypeFinish", nil);

    NSString* jsonFunc_finishTransaction = [NSString stringWithFormat:jsonFunc_tmp, clientId_, transactionNumber_, processData, processDataType];

    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd-MM-yyyy-HH:mm:ss";
    endDateTime_ = [dateFormatter stringFromDate:[NSDate date]];

    BOOL result = [ePOS2SDKManager operateGermanyFiscalElement:jsonFunc_finishTransaction timeout:EPOS2_PARAM_DEFAULT];
    if(result == YES) {
        result = [super waitCallbackEvent:ePOS2SDKManager semaphore:gfeSemaphore method:NSStringFromSelector(_cmd) timeout:EPOS2_PARAM_DEFAULT];
    }

    return result;
}

- (BOOL)createReceiptData
{
    if(signature_ == nil || startDateTime_ == nil || endDateTime_ == nil) {
        return NO;
    }
    NSMutableString* receiptData = [[NSMutableString alloc] init];
    if(receiptData != nil) {
        // Prefix
        [ePOS2SDKManager addTextAlignPrinter:EPOS2_ALIGN_CENTER];
        [ePOS2SDKManager addImagePrinter];
        [ePOS2SDKManager addFeedLinePrinter:1];

        [receiptData appendString:@"THE STORE 123 (555) 555 – 5555\n"];
        [receiptData appendString:@"STORE DIRECTOR – John Smith\n"];
        [receiptData appendString:@"\n"];
        [receiptData appendString:@"7/01/07 16:58 6153 05 0191 134\n"];
        [receiptData appendString:@"ST# 21 OP# 001 TE# 01 TR# 747\n"];
        [receiptData appendString:@"------------------------------\n"];
        [ePOS2SDKManager addTextPrinter:receiptData];
        [receiptData setString:@""];

        // Receipt Data
        [ePOS2SDKManager addTextAlignPrinter:EPOS2_ALIGN_LEFT];
        [receiptData appendString:[itemList_ createReceiptData]];
        [ePOS2SDKManager addTextPrinter:receiptData];
        [receiptData setString:@""];

        [ePOS2SDKManager addTextAlignPrinter:EPOS2_ALIGN_CENTER];
        [receiptData appendString:@"------------------------------\n"];
        [ePOS2SDKManager addTextPrinter:receiptData];
        [receiptData setString:@""];

        // Suffix
        [ePOS2SDKManager addTextSizePrinter:2 height:2];
        [receiptData appendString:@"TOTAL         €"];
        [receiptData appendString:[itemList_ createTotalAmountData]];
        [receiptData appendString:@"\n"];
        [ePOS2SDKManager addTextPrinter:receiptData];
        [receiptData setString:@""];

        [ePOS2SDKManager addTextAlignPrinter:EPOS2_ALIGN_LEFT];
        [ePOS2SDKManager addTextSizePrinter:1 height:1];
        [ePOS2SDKManager addFeedLinePrinter:1];
        [receiptData appendString:@"       CASH                       €"];
        [receiptData appendString:[itemList_ createTotalAmountData]];
        [receiptData appendString:@"\n"];
        [receiptData appendString:@"       CHANGE                     €0\n"];
        [ePOS2SDKManager addTextPrinter:receiptData];
        [receiptData setString:@""];

        [ePOS2SDKManager addTextAlignPrinter:EPOS2_ALIGN_CENTER];
        [receiptData appendString:@"------------------------------\n"];
        [receiptData appendString:@"Purchased item total number\n"];
        [receiptData appendString:@"Sign Up and Save !\n"];
        [receiptData appendString:@"With Preferred Saving Card\n"];
        [receiptData appendString:@"------------------------------\n"];
        [ePOS2SDKManager addTextPrinter:receiptData];
        [receiptData setString:@""];

        [ePOS2SDKManager addTextAlignPrinter:EPOS2_ALIGN_LEFT];
        [receiptData appendString:@"TransactionNumber:"];
        [receiptData appendString:[NSString stringWithFormat:@"%d\n", (int)transactionNumber_]];
        [receiptData appendString:@"Signature:\n"];
        [receiptData appendString:signature_];
        [receiptData appendString:@"TSE SerialNumber:\n"];
        [receiptData appendString:@"    DemoSerialNumberDemoSerialNumber\n"];
        [receiptData appendString:@"StartDate:"];
        [receiptData appendString:startDateTime_];
        [receiptData appendString:@"\n"];
        [receiptData appendString:@"EndDate  :"];
        [receiptData appendString:endDateTime_];
        [ePOS2SDKManager addTextPrinter:receiptData];
        [receiptData setString:@""];

        [ePOS2SDKManager addFeedLinePrinter:2];
        [ePOS2SDKManager addTextAlignPrinter:EPOS2_ALIGN_CENTER];
        [ePOS2SDKManager addBarcodePrinter];
        [ePOS2SDKManager addCutPrinter];
    }

    return YES;
}

- (BOOL)printReceipt
{

    BOOL result = NO;
    result = [ePOS2SDKManager sendDataPrinter];
    if(result == YES){
        result = [super waitCallbackEvent:ePOS2SDKManager semaphore:prnSemaphore method:NSStringFromSelector(_cmd) timeout:EPOS2_PARAM_DEFAULT];
        [ePOS2SDKManager clearCommandBufferPrinter];
    }

    return result;
}

- (IBAction)eventButtonDidPush:(id)sender
{
    if(itemList_ == nil) {
        return;
    }

    NSString* itemCode = nil;
    switch (((UIView *)sender).tag) {
        case 0:
            // OpenStore
            [self openStore];
            break;
        case 1:
            // CloseStore
            [self closeStore];
            break;
        case 2:
            // Pullover
            itemCode = NSLocalizedString(@"item1Code", nil);
            break;
        case 3:
            // Jeans
            itemCode = NSLocalizedString(@"item2Code", nil);
            break;
        case 4:
            // T-shirt
            itemCode = NSLocalizedString(@"item3Code", nil);
            break;
        case 5:
            // Parka
            itemCode = NSLocalizedString(@"item4Code", nil);
            break;
        case 6:
            // Sox
            itemCode = NSLocalizedString(@"item5Code", nil);
            break;
        case 7:
            // Jacket
            itemCode = NSLocalizedString(@"item6Code", nil);
            break;
        case 8:
            // Camisole
            itemCode = NSLocalizedString(@"item7Code", nil);
            break;
        case 9:
            // Skirt
            itemCode = NSLocalizedString(@"item8Code", nil);
            break;
        case 10:
            // Cut & Sewn
            itemCode = NSLocalizedString(@"item9Code", nil);
            break;
        case 11:
            // Leggings
            itemCode = NSLocalizedString(@"item10Code", nil);
            break;
        case 12:
            // Check
            [self check];
            break;
        default:
            break;
    }

    if(itemCode != nil) {
        [self enqueueStartTransaction];
        [self startTimeMeasurement];
        [itemList_ incrementItemCount:itemCode];
        _buttonCheck.enabled = YES;
        _buttonCloseStore.enabled = NO;

        if(enableDisplay_) {
            [queueForSDK addOperationWithBlock:^{
                BOOL result = [ePOS2SDKManager indicateDisplay:[itemList_ createItemData:itemCode]];
                if(result == YES) {
                    result = [super waitCallbackEvent:ePOS2SDKManager semaphore:dspSemaphore method:NSStringFromSelector(_cmd) timeout:EPOS2_PARAM_DEFAULT];
                }
            }];
        }
    }
}

- (void) openStore
{
    [queueForSDK addOperationWithBlock:^{

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self beginProcess];
        }];

        BOOL result = [ePOS2SDKManager connectPrinter:targetPrn_];
        if(result == YES) {
            result = [ePOS2SDKManager connectGermanyFiscalElement:targetGfe_];
        }

        if(result == YES) {
            result = [self operateAuthenticateUserForTimeAdmin];
            if(result == YES) {
                result = [self operateUpdateTime];
            }
        }

        if(enableScanner_ && result == YES) {
            result = [ePOS2SDKManager connectBarcodeScanner:targetScn_];
        }

        if(enableDisplay_ && result == YES) {
            result = [ePOS2SDKManager connectLineDisplay:targetDsp_];
        }

        if(result == YES){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _buttonOpenStore.enabled = NO;
                _buttonCloseStore.enabled = YES;
                _buttonCheck.enabled = NO;
                if(!enableScanner_) {
                    [self buttonItemEnable:YES];
                }
            }];
        }else{
            [self disconnectAllDevices];
        }

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self endProcess];
        }];
    }];

}

- (void) closeStore
{
    [queueForSDK addOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self beginProcess];
        }];

        [itemList_ clearItemCount];

        [self operateLogOutForTimeAdmin];

        [self disconnectAllDevices];

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            _buttonOpenStore.enabled = YES;
            _buttonCloseStore.enabled = NO;
            _buttonCheck.enabled = NO;
            if(!enableScanner_) {
                [self buttonItemEnable:NO];
            }
        }];

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self endProcess];
        }];
    }];

}

- (void) check
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self beginProcess];
    }];

    if(queueTimer != nil) {
        dispatch_semaphore_signal(timerSemaphore);
        [queueTimer waitUntilAllOperationsAreFinished];
    }

    [queueForSDK addOperationWithBlock:^{
        BOOL result = YES;
        if(enableDisplay_) {
            NSString* displayData = @"";

            displayData = [displayData stringByAppendingString:@"TOTAL      €"];
            displayData = [displayData stringByAppendingString:[itemList_ createTotalAmountData]];
            result = [ePOS2SDKManager indicateDisplay:displayData];
            if(result == YES) {
                result = [super waitCallbackEvent:ePOS2SDKManager semaphore:dspSemaphore method:NSStringFromSelector(_cmd) timeout:EPOS2_PARAM_DEFAULT];
            }
        }


        // Payment...
        if(result == YES) {
            result = [self operateFinishTransaction];
        }

        // Print Receipt
        if(result == YES) {
            if([self createReceiptData]) {
                result = [self printReceipt];
            }
        }

        if(result == YES) {
            completeStartTransaction_ = NO;
            [itemList_ clearItemCount];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                _buttonCheck.enabled = NO;
                _buttonCloseStore.enabled = YES;
            }];
        }

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self endProcess];
        }];
    }];
}

- (void)onGfeReceiveEPOS2SDKManager:(EPOS2SDKManager*)EPOS2SDKManager code:(int)code data:(NSString *)data
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _textOperation.text = [_textOperation.text stringByAppendingString:[NSString stringWithFormat:@"onGfeReceive:\n"]];
        _textOperation.text = [_textOperation.text stringByAppendingString:[NSString stringWithFormat:@"  code:%@\n", [ePOS2SDKManager getEposResultText:code]]];
        _textOperation.text = [_textOperation.text stringByAppendingString:[NSString stringWithFormat:@"  data:%@\n", data]];
        [self scrollText:_textOperation];
    }];

    NSDictionary* json = [self parseJson:data];
    NSString* result = [self getJsonString:json key:@"result"];
    if([result isEqualToString:@"EXECUTION_OK"]) {
        NSString* function = [self getJsonString:json key:@"function"];

        if([function isEqualToString:@"GetChallenge"]) {
            NSString* challeng = [self getJsonString:[self getJsonOutputInfo:json] key:@"challenge"];
            challenge_ = [NSString stringWithString:challeng];
        }

        if([function isEqualToString:@"StartTransaction"]) {
            NSString* transactionNumber = [self getJsonString:[self getJsonOutputInfo:json] key:@"transactionNumber"];
            if(transactionNumber != nil) {
                transactionNumber_ = [transactionNumber integerValue];
            }
        }

        if([function isEqualToString:@"FinishTransaction"]) {
            NSString* signature = [self getJsonString:[self getJsonOutputInfo:json] key:@"signature"];
            if(signature != nil) {
                signature_ = [NSString stringWithString:signature];
            }
        }
    }

    dispatch_semaphore_signal(gfeSemaphore);
}

- (void)onPtrReceiveEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager code:(int)code status:(Epos2PrinterStatusInfo *)status printJobId:(NSString *)printJobId
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _textOperation.text = [_textOperation.text stringByAppendingString:[NSString stringWithFormat:@"onPtrReceive:\n"]];
        _textOperation.text = [_textOperation.text stringByAppendingString:[NSString stringWithFormat:@"  code:%@\n", [ePOS2SDKManager getEposResultText:code]]];
        [self scrollText:_textOperation];
    }];

    if(prnSemaphore != nil) {
        dispatch_semaphore_signal(prnSemaphore);
    }
}

- (void)onDispReceiveEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager code:(int)code;
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _textOperation.text = [_textOperation.text stringByAppendingString:[NSString stringWithFormat:@"onDispReceive:\n"]];
        _textOperation.text = [_textOperation.text stringByAppendingString:[NSString stringWithFormat:@"  code:%@\n", [ePOS2SDKManager getEposResultText:code]]];
        [self scrollText:_textOperation];
    }];
    if(dspSemaphore != nil) {
        dispatch_semaphore_signal(dspSemaphore);
    }
}

- (void)onScanDataEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager scanData:(NSString *)scanData
{
    if(scanData == nil) {
        return;
    }
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _textOperation.text = [_textOperation.text stringByAppendingString:[NSString stringWithFormat:@"onScanData:\n"]];
        _textOperation.text = [_textOperation.text stringByAppendingString:[NSString stringWithFormat:@"  data:%@\n", scanData]];
        [self scrollText:_textOperation];
    }];

    // register Item count;
    [self enqueueStartTransaction];
    [self startTimeMeasurement];
    [itemList_ incrementItemCount:scanData];
    _buttonCheck.enabled = YES;
    _buttonCloseStore.enabled = NO;

    if(enableDisplay_) {
        [queueForSDK addOperationWithBlock:^{
            BOOL result = [ePOS2SDKManager indicateDisplay:[itemList_ createItemData:scanData]];
            if(result == YES) {
                result = [super waitCallbackEvent:ePOS2SDKManager semaphore:dspSemaphore method:NSStringFromSelector(_cmd) timeout:EPOS2_PARAM_DEFAULT];
            }
        }];
    }
}

- (void)onLogEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager apiLog:(NSString *)apiLog
{
    if(apiLog !=nil){
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            _textOperation.text = [_textOperation.text stringByAppendingString:apiLog];
        }];
    }
}


@end
