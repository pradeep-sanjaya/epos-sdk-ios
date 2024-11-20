#import "ePOS2.h"

#import <UIKit/UIKit.h>
#import "CATViewController.h"
#import "PickerTableView.h"

@interface AuthorizeViewController : CATViewController<SelectPickerTableDelegate>
{
    int service_;
    int authorize_;
    PickerTableView *serviceList_;
    PickerTableView *authorizeList_;
    
    UIBackgroundTaskIdentifier bgTask;
}

@property (weak, nonatomic) IBOutlet UIButton *buttonService;
@property (weak, nonatomic) IBOutlet UITextField *textTotalAmount;
@property (weak, nonatomic) IBOutlet UITextField *textAmount;
@property (weak, nonatomic) IBOutlet UITextField *textTax;
@property (weak, nonatomic) IBOutlet UIButton *buttonAuthorize;
@property (weak, nonatomic) IBOutlet UITextField *textAsi;
@property (weak, nonatomic) IBOutlet UIButton *textCheckConnection;
@property (weak, nonatomic) IBOutlet UIButton *buttonScanCode;
@property (weak, nonatomic) IBOutlet UITextField *textDailyLogType;


@end
