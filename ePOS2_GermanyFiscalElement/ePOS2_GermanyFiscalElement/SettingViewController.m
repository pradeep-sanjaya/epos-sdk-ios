#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    targetGfe_ = _textTargetGfe.text;
    targetPrn_ = _textTargetPrinter.text;
    targetDsp_ = _textTargetDisplay.text;
    targetScn_ = _textTargetScanner.text;
    clientId_ = _textClientId.text;
    _textSetup.text = @"";

    printerList_ = [[PickerTableView alloc] init];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:NSLocalizedString(@"printerseries_m30", @"")];
    [items addObject:NSLocalizedString(@"printerseries_t88", @"")];
    [items addObject:NSLocalizedString(@"printerseries_m30ii", @"")];
    [items addObject:NSLocalizedString(@"printerseries_t88vii", @"")];
    [items addObject:NSLocalizedString(@"printerseries_m30iii", @"")];
    [printerList_ setItemList:items];
    [_buttonPrinter setTitle:[printerList_ getItem:0] forState:UIControlStateNormal];
    printerList_.delegate = self;

    [self setDoneToolbar];

    _switchDisplay.on = NO;
    _switchScanner.on = NO;
    enableDisplay_ = NO;
    enableScanner_ = NO;
    [_switchDisplay addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [_switchScanner addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_switchDisplay];
    [self.view addSubview:_switchScanner];

    gfeSemaphore = dispatch_semaphore_create(0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    _textTargetGfe.text = targetGfe_;
    _textTargetPrinter.text = targetPrn_;
    _textTargetDisplay.text = targetDsp_;
    _textTargetScanner.text = targetScn_;
    _textClientId.text = clientId_;
    _textSetup.text = @"";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    ePOS2SDKManager = [[EPOS2SDKManager alloc] init];
    ePOS2SDKManager.delegate = self;

    queueForSDK = [[NSOperationQueue alloc] init];
    queueForSDK.maxConcurrentOperationCount = 1;

    [queueForSDK addOperationWithBlock:^{
        [ePOS2SDKManager initializeGfeObject];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [queueForSDK addOperationWithBlock:^{
        ePOS2SDKManager.delegate = nil;
        [ePOS2SDKManager finalizeGfeObject];

        challenge_ = nil;
        tseInitializationState_ = nil;
    }];
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
    _textTargetGfe.inputAccessoryView = doneToolbar;
    _textTargetPrinter.inputAccessoryView = doneToolbar;
    _textTargetDisplay.inputAccessoryView = doneToolbar;
    _textTargetScanner.inputAccessoryView = doneToolbar;
    _textClientId.inputAccessoryView = doneToolbar;
}

- (void)doneKeyboard:(id)sender
{
    [_textTargetGfe resignFirstResponder];
    [_textTargetPrinter resignFirstResponder];
    [_textTargetDisplay resignFirstResponder];
    [_textTargetScanner resignFirstResponder];
    [_textClientId resignFirstResponder];

    targetGfe_ = _textTargetGfe.text;
    targetPrn_ = _textTargetPrinter.text;
    targetDsp_ = _textTargetDisplay.text;
    targetScn_ = _textTargetScanner.text;
    clientId_ = _textClientId.text;
}

- (IBAction)eventButtonDidPush:(id)sender {
    switch (((UIView *)sender).tag) {
        case 1:
            [printerList_ show];
            break;
        case 2:
            [self setup];
        default:
            break;
    }
}

- (void)onSelectPickerItem:(NSInteger)position obj:(id)obj
{
    if (obj == printerList_) {
        [_buttonPrinter setTitle:[printerList_ getItem:position] forState:UIControlStateNormal];
        switch ((int)printerList_.selectIndex) {
            case 0:
                printerSeries_ = EPOS2_TM_M30;
                break;
            case 1:
                printerSeries_ = EPOS2_TM_T88;
                break;
            case 2:
                printerSeries_ = EPOS2_TM_M30II;
                break;
            case 3:
                printerSeries_ = EPOS2_TM_T88VII;
                break;
            case 4:
                printerSeries_ = EPOS2_TM_M30III;
                break;
            default:
                break;
        }
    }
}

- (void) switchChanged:(UISwitch*)switchParts
{
    if(_switchDisplay.on) {
        enableDisplay_ = YES;
    } else {
        enableDisplay_ = NO;
    }

    if(_switchScanner.on) {
        enableScanner_ = YES;
    } else {
        enableScanner_ = NO;
    }
}

- (BOOL)operateGetStorageInfo
{
    NSString* jsonFunc_getStorageInfo = NSLocalizedString(@"operate_func_getStorageInfo", nil);
    BOOL result = [ePOS2SDKManager operateGermanyFiscalElement:jsonFunc_getStorageInfo timeout:EPOS2_PARAM_DEFAULT];
    if(result == YES) {
        result = [super waitCallbackEvent:ePOS2SDKManager semaphore:gfeSemaphore method:NSStringFromSelector(_cmd) timeout:EPOS2_PARAM_DEFAULT];
    }

    return result;
}


- (BOOL)operateSetUp
{
    NSString* jsonFunc_tmp= NSLocalizedString(@"operate_func_setup", nil);
    NSString* puk = NSLocalizedString(@"puk", nil);
    NSString* adminPin = NSLocalizedString(@"adminPin", nil);
    NSString* timeAdminPin = NSLocalizedString(@"timeAdminPin", nil);

    NSString* jsonFunc_setup = [NSString stringWithFormat:jsonFunc_tmp, puk, adminPin ,timeAdminPin];

    BOOL result = [ePOS2SDKManager operateGermanyFiscalElement:jsonFunc_setup timeout:120000];
    if(result == YES) {
        result = [super waitCallbackEvent:ePOS2SDKManager semaphore:gfeSemaphore method:NSStringFromSelector(_cmd) timeout:120000];
    }

    return result;
}

- (BOOL)operateSetUpForPrinter
{
    NSString* jsonFunc_setupForPrinter = NSLocalizedString(@"operate_func_setupForPrinter", nil);

    BOOL result = [ePOS2SDKManager operateGermanyFiscalElement:jsonFunc_setupForPrinter timeout:EPOS2_PARAM_DEFAULT];
    if(result == YES) {
        result = [super waitCallbackEvent:ePOS2SDKManager semaphore:gfeSemaphore method:NSStringFromSelector(_cmd) timeout:EPOS2_PARAM_DEFAULT];
    }

    return result;
}

- (BOOL)operateAuthenticateUserForAdmin
{
    // GetChallenge
    BOOL result = [self operateGetChallenge:ePOS2SDKManager userId:NSLocalizedString(@"administrator", nil)];
    if(result == YES) {
        result = [super waitCallbackEvent:ePOS2SDKManager semaphore:gfeSemaphore method:NSStringFromSelector(_cmd) timeout:EPOS2_PARAM_DEFAULT];
    }

    // Hash calculation
    if(tseInitializationState_ == nil || challenge_ == nil) {
        return NO;
    }

    NSString* secretKey;
    if([tseInitializationState_ isEqualToString:@"UNINITIALIZED"]) {
        secretKey = NSLocalizedString(@"defaultSecretKey", nil);
    } else if([tseInitializationState_ isEqualToString:@"INITIALIZED"]) {
        secretKey = NSLocalizedString(@"secretKey", nil);
    } else {
        return NO;
    }
    NSString* input = [challenge_ stringByAppendingString:secretKey];
    NSString* hash= [self calculateHash:input];

    result = [self operateAuthenticateUserForAdmin:ePOS2SDKManager hash:hash];
    if(result == YES) {
        result = [super waitCallbackEvent:ePOS2SDKManager semaphore:gfeSemaphore method:NSStringFromSelector(_cmd) timeout:EPOS2_PARAM_DEFAULT];
    }

    return result;
}

- (BOOL)operateLogOutForAdmin
{
    BOOL result = [self operateLogOutForAdmin:ePOS2SDKManager];
    if(result == YES) {
        result = [super waitCallbackEvent:ePOS2SDKManager semaphore:gfeSemaphore method:NSStringFromSelector(_cmd) timeout:EPOS2_PARAM_DEFAULT];
    }

    return result;
}

- (BOOL)operateRegisterSecretKey
{
    NSString* jsonFunc_tmp= NSLocalizedString(@"operate_func_registerSecretKey", nil);
    NSString* userId = NSLocalizedString(@"administrator", nil);
    NSString* secretKey = NSLocalizedString(@"secretKey", nil);
    NSString* jsonFunc_registerSecretKey = [NSString stringWithFormat:jsonFunc_tmp, userId, secretKey];

    BOOL result = [ePOS2SDKManager operateGermanyFiscalElement:jsonFunc_registerSecretKey timeout:EPOS2_PARAM_DEFAULT];
    if(result == YES) {
        result = [super waitCallbackEvent:ePOS2SDKManager semaphore:gfeSemaphore method:NSStringFromSelector(_cmd) timeout:EPOS2_PARAM_DEFAULT];
    }

    return result;
}

- (BOOL)operateRegisterClientId
{
    NSString* jsonFunc_tmp= NSLocalizedString(@"operate_func_registerClient", nil);
    NSString* userId = NSLocalizedString(@"administrator", nil);
    NSString* jsonFunc_registerClientId = [NSString stringWithFormat:jsonFunc_tmp, userId, clientId_];

    BOOL result = [ePOS2SDKManager operateGermanyFiscalElement:jsonFunc_registerClientId timeout:EPOS2_PARAM_DEFAULT];
    if(result == YES) {
        result =  [super waitCallbackEvent:ePOS2SDKManager semaphore:gfeSemaphore method:NSStringFromSelector(_cmd) timeout:EPOS2_PARAM_DEFAULT];
    }

    return result;
}

- (void)setup
{
    [queueForSDK addOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self beginProcess];
        }];

        BOOL result = [ePOS2SDKManager connectGermanyFiscalElement:targetGfe_];
        if(result == YES) {
            result = [self operateGetStorageInfo];
            if(result == YES) {
                result = [self operateSetUp];
                if(result == YES) {
                    result = [self operateAuthenticateUserForAdmin];
                    if(result == YES) {
                        result = [self operateSetUpForPrinter];
                        if(result == YES) {
                            result = [self operateRegisterSecretKey];
                            if(result == YES) {
                                result = [self operateRegisterClientId];
                            }
                        }
                        [self operateLogOutForAdmin];
                    }
                }
            }

            [ePOS2SDKManager disconnectGermanyFiscalElement];
        }

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self endProcess];
        }];
    }];
}

- (void)onGfeReceiveEPOS2SDKManager:(EPOS2SDKManager*)EPOS2SDKManager code:(int)code data:(NSString *)data
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _textSetup.text = [_textSetup.text stringByAppendingString:[NSString stringWithFormat:@"onGfeReceive:\n"]];
        _textSetup.text = [_textSetup.text stringByAppendingString:[NSString stringWithFormat:@"  code:%@\n", [ePOS2SDKManager getEposResultText:code]]];
        _textSetup.text = [_textSetup.text stringByAppendingString:[NSString stringWithFormat:@"  data:%@\n", data]];
        [self scrollText:_textSetup];
    }];

    NSDictionary* json = [self parseJson:data];
    NSString* result = [self getJsonString:json key:@"result"];
    if([result isEqualToString:@"EXECUTION_OK"]) {
        NSString* function = [self getJsonString:json key:@"function"];

        if([function isEqualToString:@"GetStorageInfo"]) {
            NSDictionary* output = [self getJsonOutputInfo:json];
            NSDictionary* tseInformation = [output objectForKey:@"tseInformation"];
            NSString* tseInitializationState = [self getJsonString:tseInformation key:@"tseInitializationState"];
            
            tseInitializationState_ = [NSString stringWithString:tseInitializationState];
        }

        if([function isEqualToString:@"GetChallenge"]) {
            NSString* challeng = [self getJsonString:[self getJsonOutputInfo:json] key:@"challenge"];
            challenge_ = [NSString stringWithString:challeng];
        }
    }

    dispatch_semaphore_signal(gfeSemaphore);
}

- (void)onLogEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager apiLog:(NSString *)apiLog
{
    if(apiLog !=nil){
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            _textSetup.text = [_textSetup.text stringByAppendingString:apiLog];
        }];
    }
}

@end
