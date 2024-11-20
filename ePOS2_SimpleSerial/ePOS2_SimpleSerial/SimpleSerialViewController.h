#import <UIKit/UIKit.h>
#import "ePOS2.h"

@interface SimpleSerialViewController : UIViewController
{
    Epos2SimpleSerial *simpleSerial_;
    BOOL isConnect_;

    UIBackgroundTaskIdentifier bgTask;
}
@property(strong, nonatomic) IBOutlet UIView *itemView;
@property(weak, nonatomic) IBOutlet UITextField *textTarget;
@property(weak, nonatomic) IBOutlet UIButton *buttonConnect;
@property(weak, nonatomic) IBOutlet UIButton *buttonDisconnect;
@property(weak, nonatomic) IBOutlet UIButton *buttonSendCommand;
@property(weak, nonatomic) IBOutlet UITextView *textSendCommand;
@property(weak, nonatomic) IBOutlet UIButton *buttonClear;
@property(weak, nonatomic) IBOutlet UITextView *textSimpleSerial;
@end
