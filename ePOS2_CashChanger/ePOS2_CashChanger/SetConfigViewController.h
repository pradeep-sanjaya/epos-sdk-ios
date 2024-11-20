#import "ePOS2.h"

#import <UIKit/UIKit.h>
#import "CashChangerViewController.h"
#import "PickerTableView.h"

@interface SetConfigViewController : CashChangerViewController<SelectPickerTableDelegate>
{
    int countMode_;
    PickerTableView *countModeList_;
}
@property (weak, nonatomic) IBOutlet UITextField *textCoins;
@property (weak, nonatomic) IBOutlet UITextField *textBills;
@property (weak, nonatomic) IBOutlet UIButton *buttonClear;
@property (weak, nonatomic) IBOutlet UIButton *buttonCountMode;
@end
