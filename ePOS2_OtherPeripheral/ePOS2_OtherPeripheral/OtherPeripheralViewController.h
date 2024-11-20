#import "ePOS2.h"

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface OtherPeripheralViewController : UIViewController
{
    Epos2OtherPeripheral *other_;
    BOOL isConnect_;

    UIBackgroundTaskIdentifier bgTask;
}

@property(weak, nonatomic) IBOutlet UITextField *textTarget;
@property(weak, nonatomic) IBOutlet UIButton *buttonConnect;
@property(weak, nonatomic) IBOutlet UIButton *buttonDisconnect;
@property(weak, nonatomic) IBOutlet UIButton *buttonClear;
@property(weak, nonatomic) IBOutlet UITextView *textOtherPeripheral;
@property (weak, nonatomic) IBOutlet UITextField *textMethodName;
@property (weak, nonatomic) IBOutlet UITextView *textSendCommand;
@end
