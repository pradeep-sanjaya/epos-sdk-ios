#import <UIKit/UIKit.h>
#import "ePOS2.h"

@interface DMD70ViewController : UIViewController
{
    Epos2LineDisplay *lineDisplay_;
    BOOL _bIsWorkingSlideshow;
    BOOL _bIsLandscape;
    NSString *target_;
}

@property(weak, nonatomic) IBOutlet UIView *itemView;
@property(weak, nonatomic) IBOutlet UITextField *textTarget;
@property(weak, nonatomic) IBOutlet UIButton *buttonLandscape;
@property(weak, nonatomic) IBOutlet UIButton *buttonPortrait;
@property(weak, nonatomic) IBOutlet UIButton *buttonRegisterImg;
@property(weak, nonatomic) IBOutlet UIButton *buttonOrder;
@property(weak, nonatomic) IBOutlet UIButton *buttonCheck;
@property(weak, nonatomic) IBOutlet UIButton *buttonStart;
@property(weak, nonatomic) IBOutlet UIButton *buttonStop;
@end
