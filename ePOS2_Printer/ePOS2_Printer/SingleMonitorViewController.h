#import <UIKit/UIKit.h>
#import "PrinterInfo.h"
#import "ePOS2.h"
#import "UIViewController+Extension.h"


@interface SingleMonitorViewController : UIViewController
{
    Epos2Printer *printer_;
    
    PrinterInfo *printerInfo_;
    Boolean isMonitoring_;
}

@property (weak, nonatomic) IBOutlet UITextView *textStatus;
@property (weak, nonatomic) IBOutlet UIButton *buttonStartMonitor;
@property (weak, nonatomic) IBOutlet UIButton *buttonStopMonitor;

@end

