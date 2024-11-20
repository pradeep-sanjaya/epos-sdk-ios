//
//  AppDelegate.h
//  ePOS2_CAT
//

#import <UIKit/UIKit.h>
#import "ePOS2.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) Epos2CAT *cat;
@property (assign, nonatomic) BOOL isConnect;

@end
