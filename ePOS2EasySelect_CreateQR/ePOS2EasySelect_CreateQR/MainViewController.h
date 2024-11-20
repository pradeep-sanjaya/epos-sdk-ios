#import <UIKit/UIKit.h>
#import "PickerTableView.h"
#import "DiscoveryViewController.h"
#import "ePOS2.h"

@interface MainViewController : UIViewController <SelectPrinterDelegate, SelectPickerTableDelegate> {
    Epos2Printer *printer_;
    int printerSeries_;
    int eposEasySelectDeviceType_;
    PickerTableView *printerList_;
}
@property (weak, nonatomic) IBOutlet UITextField *textTarget;

@property (weak, nonatomic) IBOutlet UILabel *textInterface;
@property (weak, nonatomic) IBOutlet UILabel *textAddress;

@property (weak, nonatomic) IBOutlet UIButton *buttonDiscovery;
@property (weak, nonatomic) IBOutlet UIButton *buttonPrinter;

@property (weak, nonatomic) IBOutlet UIButton *buttonReceipt;

@property (weak, nonatomic) IBOutlet UITextView *textWarnings;
@end
