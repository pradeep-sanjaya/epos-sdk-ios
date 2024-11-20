#import "ePOS2.h"

#import <UIKit/UIKit.h>
#import "CATViewController.h"

@interface ConnectViewController : CATViewController
@property (weak, nonatomic) IBOutlet UITextField *textTarget;
@property (weak, nonatomic) IBOutlet UIButton *buttonConnect;
@property (weak, nonatomic) IBOutlet UISwitch *switchTraining;
@property (weak, nonatomic) IBOutlet UITextField *textSetTimeout;
@end
