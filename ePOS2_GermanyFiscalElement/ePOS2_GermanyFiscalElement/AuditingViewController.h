#import "ePOS2.h"

#import <UIKit/UIKit.h>
#import "GermanyFiscalElementViewController.h"
#import "EPOS2SDKManager.h"

@interface AuditingViewController : GermanyFiscalElementViewController<SDKDelegate>
{
    NSOperationQueue *queueForSDK;
    EPOS2SDKManager* ePOS2SDKManager;
    dispatch_semaphore_t gfeSemaphore;

    NSString* challenge_;
    BOOL isAllExportData_;
}

@property (weak, nonatomic) IBOutlet UIButton *buttonOutput;
@property (weak, nonatomic) IBOutlet UITextView *textOutput;

@end
