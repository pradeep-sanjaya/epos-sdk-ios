#import "AuditingViewController.h"

@interface AuditingViewController ()

@end

@implementation AuditingViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    gfeSemaphore = dispatch_semaphore_create(0);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _textOutput.text = @"";

    ePOS2SDKManager = [[EPOS2SDKManager alloc] init];
    ePOS2SDKManager.delegate = self;

    queueForSDK = [[NSOperationQueue alloc] init];
    queueForSDK.maxConcurrentOperationCount = 1;

    [queueForSDK addOperationWithBlock:^{
        [ePOS2SDKManager initializeGfeObject];
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _textOutput.text = @"";
    
    [queueForSDK addOperationWithBlock:^{
        ePOS2SDKManager.delegate = nil;
        [ePOS2SDKManager finalizeGfeObject];

        challenge_ = nil;
    }];
}


- (IBAction)onOutput:(id)sender
{
    [queueForSDK addOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self beginProcess];
        }];

        BOOL result = [ePOS2SDKManager connectGermanyFiscalElement:targetGfe_];
        if(result == YES) {
            isAllExportData_ = NO;

            result = [self operateAuthenticateUserForAdmin];
            if(result == YES) {
                result = [self operateUpdateTime];
                if(result == YES) {
                    result = [self operateArchiveExport];
                    if(result == YES) {
                        [self operateGetExportData];

                        [self operateFinalizeExport];
                    }
                }

                [self operateLogOutForAdmin];
            }

            if(result == YES) {
                [self operateGetLogMessageCertificate];
            }

            [ePOS2SDKManager disconnectGermanyFiscalElement];
        }

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self endProcess];
        }];
    }];

}

- (BOOL)operateAuthenticateUserForAdmin
{
    // GetChallenge
    BOOL result = [self operateGetChallenge:ePOS2SDKManager userId:NSLocalizedString(@"administrator", nil)];
    if(result == YES) {
        result = [super waitCallbackEvent:ePOS2SDKManager semaphore:gfeSemaphore method:NSStringFromSelector(_cmd) timeout:EPOS2_PARAM_DEFAULT];
    }

    if(challenge_ == nil) {
        return NO;
    }
    // Hash calculation
    NSString* secretKey = NSLocalizedString(@"secretKey", nil);
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

- (BOOL)operateUpdateTime
{
    NSString* jsonFunc_tmp = NSLocalizedString(@"operate_func_updateTime", nil);
    NSString* userId = NSLocalizedString(@"administrator", nil);
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

- (BOOL)operateArchiveExport
{
    NSString* jsonFunc_tmp= NSLocalizedString(@"operate_func_archiveExport", nil);
    NSString* userId = NSLocalizedString(@"administrator", nil);

    NSString* jsonFunc_archiveExport = [NSString stringWithFormat:jsonFunc_tmp, userId];
    BOOL result = [ePOS2SDKManager operateGermanyFiscalElement:jsonFunc_archiveExport timeout:EPOS2_PARAM_DEFAULT];
    if(result == YES) {
        result = [super waitCallbackEvent:ePOS2SDKManager semaphore:gfeSemaphore method:NSStringFromSelector(_cmd) timeout:EPOS2_PARAM_DEFAULT];
    }

    return result;
}

- (BOOL)operateGetExportData
{
    NSString* jsonFunc_tmp= NSLocalizedString(@"operate_func_getExportData", nil);
    NSString* userId = NSLocalizedString(@"administrator", nil);

    NSString* jsonFunc_getExportData = [NSString stringWithFormat:jsonFunc_tmp, userId];
    BOOL result = YES;
    while (!isAllExportData_) {
        result = [ePOS2SDKManager operateGermanyFiscalElement:jsonFunc_getExportData timeout:EPOS2_PARAM_DEFAULT];
        if(result == YES) {
            result = [super waitCallbackEvent:ePOS2SDKManager semaphore:gfeSemaphore method:NSStringFromSelector(_cmd) timeout:EPOS2_PARAM_DEFAULT];
        }
    }

    return result;
}

- (BOOL)operateFinalizeExport
{
    NSString* jsonFunc_tmp= NSLocalizedString(@"operate_func_finalizeExport", nil);
    NSString* userId = NSLocalizedString(@"administrator", nil);

    NSString* jsonFunc_finalizeExport = [NSString stringWithFormat:jsonFunc_tmp, userId];

    BOOL result = [ePOS2SDKManager operateGermanyFiscalElement:jsonFunc_finalizeExport timeout:EPOS2_PARAM_DEFAULT];
    if(result == YES) {
        result = [super waitCallbackEvent:ePOS2SDKManager semaphore:gfeSemaphore method:NSStringFromSelector(_cmd) timeout:EPOS2_PARAM_DEFAULT];
    }

    return result;
}

- (BOOL)operateGetLogMessageCertificate
{
    NSString* jsonFunc_getLogMessageCertificate = NSLocalizedString(@"operate_func_getLogMessageCertificate", nil);
    BOOL result = [ePOS2SDKManager operateGermanyFiscalElement:jsonFunc_getLogMessageCertificate timeout:EPOS2_PARAM_DEFAULT];
    if(result == YES) {
        result = [super waitCallbackEvent:ePOS2SDKManager semaphore:gfeSemaphore method:NSStringFromSelector(_cmd) timeout:EPOS2_PARAM_DEFAULT];
    }

    return YES;
}

- (void)onGfeReceiveEPOS2SDKManager:(EPOS2SDKManager*)EPOS2SDKManager code:(int)code data:(NSString *)data
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _textOutput.text = [_textOutput.text stringByAppendingString:[NSString stringWithFormat:@"OnGfeReceive:\n"]];
        _textOutput.text = [_textOutput.text stringByAppendingString:[NSString stringWithFormat:@"  code:%@\n", [ePOS2SDKManager getEposResultText:code]]];
        _textOutput.text = [_textOutput.text stringByAppendingString:[NSString stringWithFormat:@"  data:%@\n", data]];
        [self scrollText:_textOutput];
    }];

    NSDictionary* json = [self parseJson:data];
    NSString* result = [self getJsonString:json key:@"result"];
    if([result isEqualToString:@"EXECUTION_OK"]) {
        NSString* function = [self getJsonString:json key:@"function"];

        if([function isEqualToString:@"GetChallenge"]) {
            NSString* challeng = [self getJsonString:[self getJsonOutputInfo:json] key:@"challenge"];
            challenge_ = [NSString stringWithString:challeng];
        }

        if([function isEqualToString:@"GetExportData"]) {
            NSString* exportStatus = [self getJsonString:[self getJsonOutputInfo:json] key:@"exportStatus"];
            if([exportStatus isEqualToString:@"EXPORT_COMPLETE"]) {
                isAllExportData_ = YES;
            }
        }
   }

    dispatch_semaphore_signal(gfeSemaphore);
}

- (void)onLogEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager apiLog:(NSString *)apiLog
{
    if(apiLog !=nil){
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            _textOutput.text = [_textOutput.text stringByAppendingString:apiLog];
        }];
    }
}
@end
