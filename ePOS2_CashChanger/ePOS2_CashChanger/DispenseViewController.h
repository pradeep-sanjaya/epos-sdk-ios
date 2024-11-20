#import "ePOS2.h"

#import <UIKit/UIKit.h>
#import "CashChangerViewController.h"

@interface DispenseViewController : CashChangerViewController

@property (weak, nonatomic) IBOutlet UIButton *buttonClear;
@property (weak, nonatomic) IBOutlet UITextField *textCash;
@property (weak, nonatomic) IBOutlet UITextField *textJpy1;
@property (weak, nonatomic) IBOutlet UITextField *textJpy5;
@property (weak, nonatomic) IBOutlet UITextField *textJpy10;
@property (weak, nonatomic) IBOutlet UITextField *textJpy50;
@property (weak, nonatomic) IBOutlet UITextField *textJpy100;
@property (weak, nonatomic) IBOutlet UITextField *textJpy500;
@property (weak, nonatomic) IBOutlet UITextField *textJpy1000;
@property (weak, nonatomic) IBOutlet UITextField *textJpy2000;
@property (weak, nonatomic) IBOutlet UITextField *textJpy5000;
@property (weak, nonatomic) IBOutlet UITextField *textJpy10000;

@end
