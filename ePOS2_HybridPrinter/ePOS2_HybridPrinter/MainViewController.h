#import <UIKit/UIKit.h>
#import "PickerTableView.h"
#import "DiscoveryViewController.h"
#import "ePOS2.h"

@interface MainViewController : UIViewController<SelectPrinterDelegate, SelectPickerTableDelegate>
{
    Epos2HybridPrinter *hybridPrinter_;
    NSString* connectTarget_;
    int lang_;
    int hybridPrinterlang_;
    PickerTableView *langList_;
}
@property(weak, nonatomic) IBOutlet UITextField *textTarget;
@property(weak, nonatomic) IBOutlet UIButton *buttonDiscovery;
@property(weak, nonatomic) IBOutlet UIButton *buttonLang;
@property(weak, nonatomic) IBOutlet UIButton *buttonOnePassControl;
@property(weak, nonatomic) IBOutlet UIButton *buttonValidationControl;
@end
