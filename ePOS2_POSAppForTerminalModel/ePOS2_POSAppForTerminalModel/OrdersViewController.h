//
//  OrdersViewController.h
//  ePOS2_Composite
//

#import <UIKit/UIKit.h>

#import "ViewController.h"
#import "IndicatorView.h"
#import "EPOS2SDKManager.h"
#import "EposPurchaseItemList.h"
#import "ChangeViewController.h"

@interface OrdersViewController : ViewController<SDKDelegate,modalViewDelegate>{
    IndicatorView *indicator;
    EposPurchaseItemList* itemList_;
    EPOS2SDKManager *ePOS2SDKManager;
    NSOperationQueue *queueForSDK;
    
    NSString *targetPrinter_;
    NSString *targetDisplay_;
    NSString *targetScanner_;
    NSString *targetCashChanger_;
    int printerSeries_;
    BOOL enableDisplay_;
    BOOL enableScanner_;
    BOOL enableCashChanger_;
}

@property (weak, nonatomic) IBOutlet UITextView *textApiLog;
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
@property (weak, nonatomic) IBOutlet UITextField *textTotal;

- (void)scrollText:(UITextView *)text;

@end
