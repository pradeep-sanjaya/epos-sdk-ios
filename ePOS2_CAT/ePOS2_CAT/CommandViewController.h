#import "ePOS2.h"

#import <UIKit/UIKit.h>
#import "CATViewController.h"
#import "PickerTableView.h"

@interface CommandViewController : CATViewController<SelectPickerTableDelegate>
{
    int service_;
    PickerTableView *serviceList_;
}

@property (weak, nonatomic) IBOutlet UITextField *textDirectIOCommand;
@property (weak, nonatomic) IBOutlet UITextField *textDirectIOData;
@property (weak, nonatomic) IBOutlet UITextField *textDirectIOString;
@property (weak, nonatomic) IBOutlet UITextField *textDirectIOAsi;
@property (weak, nonatomic) IBOutlet UIButton *buttonService;
@end
