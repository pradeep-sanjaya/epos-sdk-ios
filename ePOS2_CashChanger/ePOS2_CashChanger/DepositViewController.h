#import "ePOS2.h"

#import <UIKit/UIKit.h>
#import "CashChangerViewController.h"
#import "PickerTableView.h"

@interface DepositViewController : CashChangerViewController<SelectPickerTableDelegate>
{
    int config_;
    PickerTableView *configList_;
}
@property (weak, nonatomic) IBOutlet UIButton *buttonClear;
@property (weak, nonatomic) IBOutlet UIButton *buttonConfig;
@end
