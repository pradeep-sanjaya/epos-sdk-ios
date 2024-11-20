#import <UIKit/UIKit.h>
#import "PrinterInfo.h"
#import "UIViewController+Extension.h"
#import "ePOS2.h"


@interface PrinterSettingExViewController : UIViewController
{
    Epos2Printer *printer_;
    
    PrinterInfo *printerInfo_;
    BOOL updatePassword_;
}

@property (weak, nonatomic) IBOutlet UIButton *buttonGetPrinterSettingEx;
@property (weak, nonatomic) IBOutlet UIButton *buttonSetPrinterSettingEx;
@property (weak, nonatomic) IBOutlet UITextField *textPassword;
@property (weak, nonatomic) IBOutlet UITextView *textJson;

@end
