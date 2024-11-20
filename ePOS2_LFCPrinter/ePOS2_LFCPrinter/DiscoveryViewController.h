#import <UIKit/UIKit.h>
#import "ePOS2.h"

@protocol SelectPrinterDelegate<NSObject>
- (void)onSelectPrinter:(NSString *)target;
@end

@interface DiscoveryViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    Epos2FilterOption *filteroption_;
    NSMutableArray *printerList_;
}
@property(weak, nonatomic) IBOutlet UIButton *buttonRestart;
@property(weak, nonatomic) IBOutlet UITableView *printerView_;
@property(weak, nonatomic)id<SelectPrinterDelegate> delegate;
@end
