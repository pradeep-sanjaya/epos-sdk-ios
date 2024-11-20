//
//  ChangeViewController.h
//  ePOS2_POSAppForTerminalModel
//
//

#import <UIKit/UIKit.h>
#import "EPOS2SDKManager.h"
#import "EposPurchaseItemList.h"
#import "IndicatorView.h"

@protocol modalViewDelegate <NSObject>
@optional
- (void)modalViewWillClose;
@end

@interface ChangeViewController : UIViewController<SDKDelegate>{
    IndicatorView *indicator;
    EPOS2SDKManager *ePOS2SDKManager;
    EposPurchaseItemList* itemList_;
    NSOperationQueue *queueForSDK;
    
    long total;
    long deposit;
    long change;
    
    BOOL enableDisplay;
    BOOL enableCashChanger;
}

@property (nonatomic, weak) id<modalViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *textChange;
@property (weak, nonatomic) IBOutlet UITextField *textMessage;
@end
