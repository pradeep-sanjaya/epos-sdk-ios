//
//  SettingViewController.h
//  ePOS2_Composite
//
//
#import <UIKit/UIKit.h>

#import "ViewController.h"
#import "PickerTableView.h"

@interface SettingViewController : ViewController<SelectPickerTableDelegate>
{
    PickerTableView *printerList_;
}
@property (weak, nonatomic) IBOutlet UIButton *buttonDiscovery;
@property (weak, nonatomic) IBOutlet UIButton *buttonPrinter;
@property (weak, nonatomic) IBOutlet UISwitch *switchDisplay;
@property (weak, nonatomic) IBOutlet UISwitch *switchScanner;
@property (weak, nonatomic) IBOutlet UISwitch *switchCashChanger;
@property (weak, nonatomic) IBOutlet UITextField *textTargetPrinter;
@property (weak, nonatomic) IBOutlet UITextField *textTargetDisplay;
@property (weak, nonatomic) IBOutlet UITextField *textTargetScanner;
@property (weak, nonatomic) IBOutlet UITextField *textTargetCashChanger;


@end
