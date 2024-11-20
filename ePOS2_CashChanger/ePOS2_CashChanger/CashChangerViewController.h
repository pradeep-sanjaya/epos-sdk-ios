#import "ePOS2.h"
#import "ShowMsg.h"

#import <UIKit/UIKit.h>

@interface CashChangerViewController : UIViewController< Epos2CChangerStatusChangeDelegate, Epos2CChangerStatusUpdateDelegate, Epos2CChangerDirectIODelegate, Epos2ConnectionDelegate, UITabBarControllerDelegate>
{
    Epos2CashChanger *cchanger_;
    BOOL isConnect_;
}

@property (weak, nonatomic) IBOutlet UITextView *textCashChanger;
- (BOOL)initializeObject;
- (void)finalizeObject;
- (void)setEventDelegate;
- (void)releaseEventDelegate;
- (void)scrollText;

@end
