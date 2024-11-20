#import <UIKit/UIKit.h>
#import "PickerTableView.h"
#import "DiscoveryViewController.h"
#import "PrinterInfo.h"
#import "UIViewController+Extension.h"
#import "ePOS2.h"

@interface MainViewController : UIViewController<SelectPrinterDelegate, SelectPickerTableDelegate>
{
    Epos2Printer *printer_;
    PickerTableView *printerList_;
    PickerTableView *langList_;
    
    PrinterInfo *printerInfo_;
    BOOL drawer_;
}
@property(weak, nonatomic) IBOutlet UITextField *textTarget;
@property(weak, nonatomic) IBOutlet UIButton *buttonDiscovery;
@property(weak, nonatomic) IBOutlet UIButton *buttonPrinter;
@property(weak, nonatomic) IBOutlet UIButton *buttonLang;
@property(weak, nonatomic) IBOutlet UIButton *buttonReceipt;
@property(weak, nonatomic) IBOutlet UIButton *buttonCoupon;
@property (weak, nonatomic) IBOutlet UIButton *buttonMonitoring;
@property (weak, nonatomic) IBOutlet UIButton *buttonSetting;
@property(weak, nonatomic) IBOutlet UITextView *textWarnings;
@property (weak, nonatomic) IBOutlet UISwitch *switchDrawer;

@end
