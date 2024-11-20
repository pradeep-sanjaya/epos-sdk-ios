#import "StorageInfoViewController.h"
#import "AppDelegate.h"

@interface StorageInfoViewController ()
@end

@implementation StorageInfoViewController

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

    _textGetStorageInfo.text = @"";
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

    _textGetStorageInfo.text = @"";
    [queueForSDK addOperationWithBlock:^{
        ePOS2SDKManager.delegate = nil;
        [ePOS2SDKManager finalizeGfeObject];
    }];
}

- (IBAction)onGetStorageInfo:(id)sender
{
    [queueForSDK addOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self beginProcess];
        }];

        if([ePOS2SDKManager connectGermanyFiscalElement:targetGfe_]) {
            NSString* jsonFunc_getStorageInfo = NSLocalizedString(@"operate_func_getStorageInfo", nil);
            if([ePOS2SDKManager operateGermanyFiscalElement:jsonFunc_getStorageInfo timeout:EPOS2_PARAM_DEFAULT]) {
                [super waitCallbackEvent:ePOS2SDKManager semaphore:gfeSemaphore method:NSStringFromSelector(_cmd) timeout:EPOS2_PARAM_DEFAULT];
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
        _textGetStorageInfo.text = [_textGetStorageInfo.text stringByAppendingString:[NSString stringWithFormat:@"onGfeReceive:\n"]];
        _textGetStorageInfo.text = [_textGetStorageInfo.text stringByAppendingString:[NSString stringWithFormat:@"  code:%d\n", code]];
        _textGetStorageInfo.text = [_textGetStorageInfo.text stringByAppendingString:[NSString stringWithFormat:@"  data:%@\n", data]];
        [self scrollText:_textGetStorageInfo];
    }];

    dispatch_semaphore_signal(gfeSemaphore);
}

- (void)onLogEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager apiLog:(NSString *)apiLog
{
    if(apiLog !=nil){
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            _textGetStorageInfo.text = [_textGetStorageInfo.text stringByAppendingString:apiLog];
        }];
    }
}

@end
