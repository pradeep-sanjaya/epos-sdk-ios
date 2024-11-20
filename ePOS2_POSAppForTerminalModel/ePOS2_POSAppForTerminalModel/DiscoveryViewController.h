//
//  DiscoveryViewController.h
//  ePOS2_Composite
//
//
#import <UIKit/UIKit.h>
#import "ePOS2.h"
#import "SettingViewController.h"
#import "EPOS2SDKManager.h"

@interface DiscoveryViewController : SettingViewController<UITableViewDataSource, UITableViewDelegate, SDKDelegate>
{
    Epos2FilterOption *filteroption_;
    EPOS2SDKManager *ePOS2SDKManager;
    NSMutableArray *printerList2_;
}
@property (weak, nonatomic) IBOutlet UITableView *printerView_;
@property (weak, nonatomic) IBOutlet UIButton *buttonRestart;

@end
