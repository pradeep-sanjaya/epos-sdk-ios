#import "ePOS2.h"

#import <UIKit/UIKit.h>
#import "CashChangerViewController.h"

@interface CommandViewController : CashChangerViewController
@property (weak, nonatomic) IBOutlet UIButton *buttonClear;
@property (weak, nonatomic) IBOutlet UITextField *textCommandData;
@property (weak, nonatomic) IBOutlet UITextField *textDirectIOCommand;
@property (weak, nonatomic) IBOutlet UITextField *textDirectIOData;
@property (weak, nonatomic) IBOutlet UITextField *textDirectIOString;
@end
