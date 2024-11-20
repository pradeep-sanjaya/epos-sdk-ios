//
//  AppDelegate.h
//  ePOS2_Composite
//
//

#import <UIKit/UIKit.h>
#import "EPOS2SDKManager.h"
#import "EposPurchaseItemList.h"
#import "OrdersViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (copy, nonatomic) NSString *targetPrinter;
@property (copy, nonatomic) NSString *targetDisplay;
@property (copy, nonatomic) NSString *targetScanner;
@property (copy, nonatomic) NSString *targetCashChanger;
@property (strong, nonatomic) EPOS2SDKManager *ePOS2SDKManager;
@property (strong, nonatomic) EposPurchaseItemList *eposPurchaseItemList;
@property (strong, nonatomic) OrdersViewController *ordersViewController;
@property (assign, nonatomic) int printerSeries;
@property (assign, nonatomic) long total;
@property (assign, nonatomic) long deposit;
@property (assign, nonatomic) long change;
@property (assign, nonatomic) BOOL enableDisplay;
@property (assign, nonatomic) BOOL enableScanner;
@property (assign, nonatomic) BOOL enableCashChanger;

@end

