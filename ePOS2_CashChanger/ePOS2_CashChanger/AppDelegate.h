//
//  AppDelegate.h
//  ePOS2_CashChanger
//

#import <UIKit/UIKit.h>
#import "ePOS2.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) Epos2CashChanger *cchanger;
@property (assign, nonatomic) BOOL isConnect;
@end
