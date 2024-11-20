#import "ePOS2.h"

#import <UIKit/UIKit.h>

@interface MSRViewController : UIViewController
{
    Epos2MSR *msr_;
    BOOL isConnect_;

    UIBackgroundTaskIdentifier bgTask;
}

@property(weak, nonatomic) IBOutlet UITextField *textTarget;
@property(weak, nonatomic) IBOutlet UIButton *buttonConnect;
@property(weak, nonatomic) IBOutlet UIButton *buttonDisconnect;
@property(weak, nonatomic) IBOutlet UIButton *buttonClear;
@property(weak, nonatomic) IBOutlet UITextView *textMSR;
@end
