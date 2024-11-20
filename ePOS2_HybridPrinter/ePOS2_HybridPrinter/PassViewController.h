#import <UIKit/UIKit.h>
#import "ePOS2.h"

@interface PassViewController : UIViewController
{
}
@property(weak, nonatomic) Epos2HybridPrinter* hybridPrinter_;
@property(weak, nonatomic) NSString* connectTarget_;
@property(weak, nonatomic) IBOutlet UIButton *buttonStart;
@property(weak, nonatomic) IBOutlet UITextView *textReadMicr;
@property(weak, nonatomic) IBOutlet UITextView *textWarnings;
@property(weak, nonatomic) IBOutlet UISwitch *switchReadMicr;
@property(weak, nonatomic) IBOutlet UISwitch *switchPrintEndorse;
@property(weak, nonatomic) IBOutlet UISwitch *switchPrintSlip;
@property(weak, nonatomic) IBOutlet UISwitch *switchPrintReceipt;
@end
