//
//  PayViewController.h
//  ePOS2_POSAppForTerminalModel
//
//

#import <UIKit/UIKit.h>
#import "EPOS2SDKManager.h"
#import "EposPurchaseItemList.h"
#import "IndicatorView.h"

@interface PayViewController : UIViewController<SDKDelegate>{
    IndicatorView *indicator;
    EposPurchaseItemList* itemList_;
    EPOS2SDKManager *ePOS2SDKManager;
    NSOperationQueue *queueForSDK;
    
    BOOL enableDisplay;
    BOOL enableCashChanger;
    
    long total;
    long deposit;
    long change;
    
    long sumDepositCashChanger;
}
@property (weak, nonatomic) IBOutlet UITextField *textTotalPay;
@property (weak, nonatomic) IBOutlet UITextField *textDeposit;
@property (weak, nonatomic) IBOutlet UIButton *buttonDone;
@property (weak, nonatomic) IBOutlet UIButton *buttonCancel;

@end
