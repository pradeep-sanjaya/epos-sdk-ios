
#import <UIKit/UIKit.h>
#import "PrinterInfo.h"
#import "ePOS2.h"


@interface MultipleMonitorViewController : UIViewController
{
    Epos2Printer *printer_;
    
    PrinterInfo *printerInfo_;
    Boolean isMonitoring_;//　Exclusive control is necessary
    NSOperationQueue *queueForMonitor_;
    
}
@property (weak, nonatomic) IBOutlet UIButton *buttonStartGetstatus;
@property (weak, nonatomic) IBOutlet UIButton *buttonStopGetstatus;

@property (weak, nonatomic) IBOutlet UITextView *textStatus;

@end
