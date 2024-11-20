#import <UIKit/UIKit.h>
#import "ePOS2.h"

@interface CommBoxViewController : UIViewController
{
    Epos2CommBox *commBox_;
    BOOL isConnect_;

    UIBackgroundTaskIdentifier bgTask;
}
@property(strong, nonatomic) IBOutlet UIView *itemView;
@property(weak, nonatomic) IBOutlet UITextField *textTarget;
@property (weak, nonatomic) IBOutlet UITextField *textMyID;
@property(weak, nonatomic) IBOutlet UIButton *buttonConnect;
@property(weak, nonatomic) IBOutlet UIButton *buttonDisconnect;
@property (weak, nonatomic) IBOutlet UITextField *textTargetID;
@property(weak, nonatomic) IBOutlet UIButton *buttonSendData;
@property(weak, nonatomic) IBOutlet UITextView *textMessage;
@property(weak, nonatomic) IBOutlet UIButton *buttonClear;
@property(weak, nonatomic) IBOutlet UITextView *textCommBox;
@end
