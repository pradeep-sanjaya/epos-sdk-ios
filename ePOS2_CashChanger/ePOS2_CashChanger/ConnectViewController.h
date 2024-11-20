#import "ePOS2.h"

#import <UIKit/UIKit.h>
#import "CashChangerViewController.h"

@interface ConnectViewController : CashChangerViewController
@property (weak, nonatomic) IBOutlet UITextField *textTarget;
@property (weak, nonatomic) IBOutlet UIButton *buttonConnect;
@property (weak, nonatomic) IBOutlet UIButton *buttonDisconnect;
@property (weak, nonatomic) IBOutlet UIButton *buttonClear;
@end
