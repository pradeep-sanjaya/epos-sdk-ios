#import <CommonCrypto/CommonDigest.h>
#import "GermanyFiscalElementViewController.h"
#import "AppDelegate.h"

@interface GermanyFiscalElementViewController ()
@property (weak, nonatomic) AppDelegate *appDelegate;
@end

@implementation GermanyFiscalElementViewController
static const int64_t responseLimitTimeDefault = 10.0;

- (void)viewDidLoad
{
    [super viewDidLoad];

    _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if(_appDelegate.targetGfe == nil || _appDelegate.targetPrn == nil || _appDelegate.targetDsp == nil || _appDelegate.targetScn == nil) {
        _appDelegate.printerSeries = EPOS2_TM_M30;
        _appDelegate.targetGfe = NSLocalizedString(@"default_target", nil);
        _appDelegate.targetPrn = NSLocalizedString(@"default_target", nil);
        _appDelegate.targetDsp = NSLocalizedString(@"default_target", nil);
        _appDelegate.targetScn = NSLocalizedString(@"default_target", nil);
        _appDelegate.clientId = NSLocalizedString(@"clientId", nil);
        _appDelegate.enableDisplay = NO;
        _appDelegate.enableScanner = NO;
    }

    [Epos2Log setLogSettings:EPOS2_PERIOD_PERMANENT output:EPOS2_OUTPUT_STORAGE ipAddress:@"" port:0 logSize:50 logLevel:EPOS2_LOGLEVEL_LOW];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    printerSeries_ = _appDelegate.printerSeries;
    targetGfe_ = _appDelegate.targetGfe;
    targetPrn_ = _appDelegate.targetPrn;
    targetDsp_ = _appDelegate.targetDsp;
    targetScn_ = _appDelegate.targetScn;
    clientId_ = _appDelegate.clientId;
    enableDisplay_ = _appDelegate.enableDisplay;
    enableScanner_ = _appDelegate.enableScanner;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    printerSeries_ = _appDelegate.printerSeries;
    targetGfe_ = _appDelegate.targetGfe;
    targetPrn_ = _appDelegate.targetPrn;
    targetDsp_ = _appDelegate.targetDsp;
    targetScn_ = _appDelegate.targetScn;
    clientId_ = _appDelegate.clientId;
    enableDisplay_ = _appDelegate.enableDisplay;
    enableScanner_ = _appDelegate.enableScanner;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _appDelegate.printerSeries = printerSeries_;
    _appDelegate.targetGfe = targetGfe_;
    _appDelegate.targetPrn = targetPrn_;
    _appDelegate.targetDsp = targetDsp_;
    _appDelegate.targetScn = targetScn_;
    _appDelegate.clientId = clientId_;
    _appDelegate.enableDisplay = enableDisplay_;
    _appDelegate.enableScanner = enableScanner_;
}

//Indicator
- (void)beginProcess
{
    if (nil != indicator) {
        indicator = nil;
    }
    indicator = [[IndicatorView alloc] init];
    [indicator show:[[UIApplication sharedApplication] keyWindow]];
}

- (void)endProcess
{
    if (nil == indicator) {
        return;
    }
    [indicator hide];
    indicator = nil;
}

- (BOOL)waitCallbackEvent:(EPOS2SDKManager*)ePOS2SDKManager semaphore:(dispatch_semaphore_t)semaphore method:(NSString*)method timeout:(int)timeout
{
    if(ePOS2SDKManager == nil || semaphore == nil || method == nil) {
        return NO;
    }

    int64_t responseTimeout;
    if(timeout == EPOS2_PARAM_DEFAULT) {
        responseTimeout = responseLimitTimeDefault;
    } else {
        responseTimeout = timeout;
    }

    BOOL result = YES;
    dispatch_time_t dispatch_Timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * responseTimeout);
    if(dispatch_semaphore_wait(semaphore, dispatch_Timeout) != 0){
        result = NO;
        [ePOS2SDKManager showError:NSLocalizedString(@"error_msg", nil) method:method];
    }

    return result;
}

- (BOOL)operateGetChallenge:(EPOS2SDKManager*)ePOS2SDKManager userId:(NSString*)userId;
{
    NSString* jsonFunc_tmp= NSLocalizedString(@"operate_func_getChallenge", nil);

    NSString* jsonFunc_getChallenge = [NSString stringWithFormat:jsonFunc_tmp, userId];
    BOOL result = [ePOS2SDKManager operateGermanyFiscalElement:jsonFunc_getChallenge timeout:EPOS2_PARAM_DEFAULT];

    return result;
}

- (BOOL)operateAuthenticateUserForAdmin:(EPOS2SDKManager*)ePOS2SDKManager hash:(NSString*)hash
{
    NSString* jsonFunc_tmp= NSLocalizedString(@"operate_func_authenticateUserForAdmin", nil);
    NSString* userId = NSLocalizedString(@"administrator", nil);
    NSString* pin = NSLocalizedString(@"adminPin", nil);

    NSString* jsonFunc_authenticateUserForAdmin = [NSString stringWithFormat:jsonFunc_tmp, userId, pin, hash];
    BOOL result = [ePOS2SDKManager operateGermanyFiscalElement:jsonFunc_authenticateUserForAdmin timeout:EPOS2_PARAM_DEFAULT];

    return result;
}

- (BOOL)operateLogOutForAdmin:(EPOS2SDKManager*)ePOS2SDKManager
{
    NSString* jsonFunc_tmp= NSLocalizedString(@"operate_func_logOutForAdmin", nil);
    NSString* userId = NSLocalizedString(@"administrator", nil);

    NSString* jsonFunc_logOutForAdmin = [NSString stringWithFormat:jsonFunc_tmp, userId];
    BOOL result = [ePOS2SDKManager operateGermanyFiscalElement:jsonFunc_logOutForAdmin timeout:EPOS2_PARAM_DEFAULT];

    return result;
}

- (BOOL)operateAuthenticateUserForTimeAdmin:(EPOS2SDKManager*)ePOS2SDKManager hash:(NSString*)hash
{
    NSString* jsonFunc_tmp= NSLocalizedString(@"operate_func_authenticateUserForTimeAdmin", nil);
    NSString* pin = NSLocalizedString(@"timeAdminPin", nil);

    NSString* jsonFunc_authenticateUserForTimeAdmin = [NSString stringWithFormat:jsonFunc_tmp, clientId_, pin ,hash];
    BOOL result = [ePOS2SDKManager operateGermanyFiscalElement:jsonFunc_authenticateUserForTimeAdmin timeout:EPOS2_PARAM_DEFAULT];

    return result;
}

- (BOOL)operateLogOutForTimeAdmin:(EPOS2SDKManager*)ePOS2SDKManager
{
    NSString* jsonFunc_tmp= NSLocalizedString(@"operate_func_logOutForTimeAdmin", nil);

    NSString* jsonFunc_logOutForTimeAdmin = [NSString stringWithFormat:jsonFunc_tmp, clientId_];
    BOOL result = [ePOS2SDKManager operateGermanyFiscalElement:jsonFunc_logOutForTimeAdmin timeout:EPOS2_PARAM_DEFAULT];

    return result;
}


// Other Controll
- (NSString*)convertBase64String:(NSString*)dataString
{
    if(dataString == nil) {
        return nil;
    }

    NSData* data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSString* base64EncodedString = [data base64EncodedStringWithOptions:0];

    return base64EncodedString;
}

- (NSString*)calculateHash:(NSString*)input
{
    if(input == nil) {
        return nil;
    }

    NSData* sha256 = nil;
    const char* inputStr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData* data = [NSData dataWithBytes:inputStr length:input.length];
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    NSString* hashString;

    if(CC_SHA256([data bytes], (unsigned int)[data length], hash)) {
        sha256 = [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];
        hashString = [sha256 base64EncodedStringWithOptions:0];
    }

    return hashString;
}

- (NSDictionary*)parseJson:(NSString*)targetJson
{
    if(targetJson == nil) {
        return nil;
    }

    NSData *jsonData = [targetJson dataUsingEncoding:NSUTF8StringEncoding];
    if(jsonData == nil) {
        return nil;
    }

    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    return json;
}

- (NSString*)getJsonString:(NSDictionary*)json key:(NSString*)key
{
    if(json == nil || key == nil)
    {
        return nil;
    }

    return [json objectForKey:key];
}

- (NSDictionary*)getJsonOutputInfo:(NSDictionary *)json
{
    if(json == nil)
    {
        return nil;
    }
    return [json objectForKey:@"output"];
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

- (void)onGfeReceive:(Epos2GermanyFiscalElement *)fiscalObj code:(int)code data:(NSString *)data
{
    ;   /* do nothing. */
}

- (void)onPtrReceive:(Epos2Printer *)printerObj code:(int)code status:(Epos2PrinterStatusInfo *)status printJobId:(NSString *)printJobId
{
    ;   /* do nothing. */
}

- (void)onDispReceive:(Epos2LineDisplay *)displayObj code:(int)code
{
    ;   /* do nothing. */
}

- (void)onScanData:(Epos2BarcodeScanner *)scannerObj scanData:(NSString *)scanData
{
    ;   /* do nothing. */
}

@end
