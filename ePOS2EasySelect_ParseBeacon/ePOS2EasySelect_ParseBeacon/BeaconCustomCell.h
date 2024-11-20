#import "RSSIBarView.h"
#import "BeaconPrinterInfo.h"

@interface BeaconCustomCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton* printButton;
@property (weak, nonatomic) IBOutlet UILabel* printerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel* ipAdderssLabel;
@property (weak, nonatomic) IBOutlet UILabel* rssiLabel;
@property (weak, nonatomic) IBOutlet RSSIBarView* rssiBar;


- (void)setPrinterInfomation:(BeaconPrinterInfo*)printerName
                    selected:(BOOL)selected;

@end
