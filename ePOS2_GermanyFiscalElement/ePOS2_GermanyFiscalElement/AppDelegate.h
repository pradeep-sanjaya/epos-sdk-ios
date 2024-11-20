//
//  AppDelegate.h
//  ePOS2_GermanyFiscalElement
//

#import <UIKit/UIKit.h>
#import "ePOS2.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (assign, nonatomic) int printerSeries;
@property (copy, nonatomic) NSString *targetGfe;
@property (copy, nonatomic) NSString *targetPrn;
@property (copy, nonatomic) NSString *targetDsp;
@property (copy, nonatomic) NSString *targetScn;
@property (copy, nonatomic) NSString *clientId;
@property (assign, nonatomic) BOOL enableDisplay;
@property (assign, nonatomic) BOOL enableScanner;
@end

