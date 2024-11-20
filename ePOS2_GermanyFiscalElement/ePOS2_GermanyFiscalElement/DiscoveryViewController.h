#import "ePOS2.h"
#import <UIKit/UIKit.h>
#import "GermanyFiscalElementViewController.h"
#import "EPOS2SDKManager.h"

@interface DiscoveryViewController : GermanyFiscalElementViewController<UITableViewDataSource, UITableViewDelegate, SDKDelegate>
{
    Epos2FilterOption *filteroption_;
    NSMutableArray *printerList_;
    EPOS2SDKManager *ePOS2SDKManager;
}
@property (weak, nonatomic) IBOutlet UIButton *buttonRestart;
@property (weak, nonatomic) IBOutlet UITableView *printerView_;

@end
