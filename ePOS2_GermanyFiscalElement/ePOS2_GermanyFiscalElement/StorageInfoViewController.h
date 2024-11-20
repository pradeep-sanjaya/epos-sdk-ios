#import "ePOS2.h"

#import <UIKit/UIKit.h>
#import "GermanyFiscalElementViewController.h"
#import "EPOS2SDKManager.h"

@interface StorageInfoViewController : GermanyFiscalElementViewController<SDKDelegate>
{
    NSOperationQueue *queueForSDK;
    EPOS2SDKManager* ePOS2SDKManager;
    dispatch_semaphore_t gfeSemaphore;
}

@property (weak, nonatomic) IBOutlet UIButton *buttonGetStorageInfo;
@property (weak, nonatomic) IBOutlet UITextView *textGetStorageInfo;

@end
