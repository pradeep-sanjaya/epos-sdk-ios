#import "ePOS2.h"

#import <UIKit/UIKit.h>
#import "CashChangerViewController.h"
#import "PickerTableView.h"

@interface CollectViewController : CashChangerViewController<SelectPickerTableDelegate>
{
    int collectType_;
    PickerTableView *collectTypeList_;
}
@property (weak, nonatomic) IBOutlet UIButton *buttonClear;
@property (weak, nonatomic) IBOutlet UIButton *buttonCollectType;
@end
