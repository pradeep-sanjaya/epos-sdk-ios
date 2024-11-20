#import "ePOS2.h"

#import <UIKit/UIKit.h>

@interface KeyboardViewController : UIViewController
{
    Epos2Keyboard *keyboard_;
    BOOL isConnect_;

    UIBackgroundTaskIdentifier bgTask;
}

@property(weak, nonatomic) IBOutlet UITextField *textTarget;
@property(weak, nonatomic) IBOutlet UIButton *buttonConnect;
@property(weak, nonatomic) IBOutlet UIButton *buttonDisconnect;
@property(weak, nonatomic) IBOutlet UIButton *buttonClear;
@property(weak, nonatomic) IBOutlet UITextView *textKeyboard;
@end
