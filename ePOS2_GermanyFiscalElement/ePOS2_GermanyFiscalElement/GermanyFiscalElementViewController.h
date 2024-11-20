#import "ePOS2.h"
#import "IndicatorView.h"
#import "EPOS2SDKManager.h"

#import <UIKit/UIKit.h>

@interface GermanyFiscalElementViewController : UIViewController <Epos2GermanyFiscalElementReceiveDelegate, Epos2PtrReceiveDelegate, Epos2DispReceiveDelegate, Epos2ScanDelegate, UITabBarControllerDelegate>
{
    int printerSeries_;
    NSString* targetGfe_;
    NSString* targetPrn_;
    NSString* targetDsp_;
    NSString* targetScn_;
    NSString* clientId_;

    BOOL enableDisplay_;
    BOOL enableScanner_;

    IndicatorView *indicator;
}

- (void)beginProcess;
- (void)endProcess;

- (BOOL)waitCallbackEvent:(EPOS2SDKManager*)ePOS2SDKManager semaphore:(dispatch_semaphore_t)semaphore method:(NSString*)method timeout:(int)timeout;

- (BOOL)operateGetChallenge:(EPOS2SDKManager*)ePOS2SDKManager userId:(NSString*)userId;
- (BOOL)operateAuthenticateUserForAdmin:(EPOS2SDKManager*)ePOS2SDKManager hash:(NSString*)hash;
- (BOOL)operateLogOutForAdmin:(EPOS2SDKManager*)ePOS2SDKManager;
- (BOOL)operateAuthenticateUserForTimeAdmin:(EPOS2SDKManager*)ePOS2SDKManager hash:(NSString*)hash;
- (BOOL)operateLogOutForTimeAdmin:(EPOS2SDKManager*)ePOS2SDKManager;

- (NSString*)convertBase64String:(NSString*)dataString;
- (NSString*)calculateHash:(NSString*)input;
- (NSDictionary*)parseJson:(NSString*)targetJson;
- (NSString*)getJsonString:(NSDictionary*)json key:(NSString*)key;
- (NSDictionary*)getJsonOutputInfo:(NSDictionary*)json;
- (void)scrollText:(UITextView*)text;

@end
