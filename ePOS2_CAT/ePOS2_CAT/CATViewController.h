#import "ePOS2.h"
#import "ShowMsg.h"

#import <UIKit/UIKit.h>

@interface CATViewController : UIViewController< Epos2CATStatusUpdateDelegate, Epos2ConnectionDelegate, UITabBarControllerDelegate>
{
    Epos2CAT *cat_;
    BOOL isConnect_;
}

@property (weak, nonatomic) IBOutlet UITextView *textCAT;
- (BOOL)initializeObject;
- (void)finalizeObject;
- (void)setEventDelegate;
- (void)releaseEventDelegate;
- (void)scrollText;
- (NSString *) getPaymentConditionText:(int)paymentCondition;
- (NSString *) getCatServiceText:(int)service;

@end
