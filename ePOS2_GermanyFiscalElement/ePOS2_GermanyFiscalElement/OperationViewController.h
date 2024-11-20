#import "ePOS2.h"

#import <UIKit/UIKit.h>
#import "GermanyFiscalElementViewController.h"
#import "EPOS2SDKManager.h"
#import "EposPurchaseItemList.h"

@interface OperationViewController : GermanyFiscalElementViewController<SDKDelegate>
{
    BOOL completeStartTransaction_;
    NSOperationQueue *queueForSDK;
    NSOperationQueue *queueTimer;
    dispatch_semaphore_t gfeSemaphore;
    dispatch_semaphore_t prnSemaphore;
    dispatch_semaphore_t dspSemaphore;
    dispatch_semaphore_t timerSemaphore;

    EPOS2SDKManager* ePOS2SDKManager;
    EposPurchaseItemList* itemList_;

    NSString* challenge_;
    NSInteger transactionNumber_;
    NSString* signature_;
    NSString* startDateTime_;
    NSString* endDateTime_;

    NSLock* startTransactionLock_;
    NSLock* timerLock_;
}
@property (weak, nonatomic) IBOutlet UITextView *textOperation;
@property (weak, nonatomic) IBOutlet UIButton *buttonOpenStore;
@property (weak, nonatomic) IBOutlet UIButton *buttonCloseStore;
@property (weak, nonatomic) IBOutlet UIButton *buttonItem1;
@property (weak, nonatomic) IBOutlet UIButton *buttonItem2;
@property (weak, nonatomic) IBOutlet UIButton *buttonItem3;
@property (weak, nonatomic) IBOutlet UIButton *buttonItem4;
@property (weak, nonatomic) IBOutlet UIButton *buttonItem5;
@property (weak, nonatomic) IBOutlet UIButton *buttonItem6;
@property (weak, nonatomic) IBOutlet UIButton *buttonItem7;
@property (weak, nonatomic) IBOutlet UIButton *buttonItem8;
@property (weak, nonatomic) IBOutlet UIButton *buttonItem9;
@property (weak, nonatomic) IBOutlet UIButton *buttonItem10;
@property (weak, nonatomic) IBOutlet UIButton *buttonCheck;

@end

