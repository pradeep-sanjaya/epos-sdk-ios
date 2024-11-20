#import <UIKit/UIKit.h>
#import "PickerTableView.h"
#import "ePOS2.h"

@interface ValidationViewController : UIViewController
{
}
@property(weak, nonatomic) Epos2HybridPrinter* hybridPrinter_;
@property(weak, nonatomic) NSString* connectTarget_;
@property(weak, nonatomic) IBOutlet UIButton *buttonValidation;
@property(weak, nonatomic) IBOutlet UITextView *textWarnings;
@end
