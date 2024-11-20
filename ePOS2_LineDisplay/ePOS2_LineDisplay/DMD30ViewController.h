#import <UIKit/UIKit.h>
#import "ePOS2.h"

@interface DMD30ViewController : UIViewController
{
    Epos2LineDisplay *lineDisplay_;
    NSString *target_;
    NSString *text_;
    
    BOOL isSwitchBlink_;
}

@property(weak, nonatomic) IBOutlet UIView *itemView;
@property(weak, nonatomic) IBOutlet UITextField *textTarget;
@property(weak, nonatomic) IBOutlet UIButton *buttonDisplay;
@property(weak, nonatomic) IBOutlet UISwitch *switchBlink;
@property(weak, nonatomic) IBOutlet UITextField *textData;
@end
