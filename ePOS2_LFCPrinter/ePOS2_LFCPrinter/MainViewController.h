#import <UIKit/UIKit.h>
#import "PickerTableView.h"
#import "DiscoveryViewController.h"
#import "PrinterInfo.h"
#import "UIViewController+Extension.h"
#import "ePOS2.h"

@interface MainViewController : UIViewController<SelectPrinterDelegate, SelectPickerTableDelegate>
{
    Epos2LFCPrinter *printer_;
    PickerTableView *printerList_;
    PickerTableView *langList_;
    
    PrinterInfo *printerInfo_;
}
@property(weak, nonatomic) IBOutlet UITextField *textTarget;
@property(weak, nonatomic) IBOutlet UIButton *buttonDiscovery;
@property(weak, nonatomic) IBOutlet UIButton *buttonPrinter;
@property(weak, nonatomic) IBOutlet UIButton *buttonLang;

@property (weak, nonatomic) IBOutlet UIButton *buttonLabel;
@property (weak, nonatomic) IBOutlet UITextField *textJobNumber;
@property (weak, nonatomic) IBOutlet UITextView *textLog;

@end
