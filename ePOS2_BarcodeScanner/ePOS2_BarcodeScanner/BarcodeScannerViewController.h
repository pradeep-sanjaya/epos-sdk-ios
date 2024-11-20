#import <UIKit/UIKit.h>
#import "ePOS2.h"

@interface BarcodeScannerViewController : UIViewController
{
    Epos2BarcodeScanner *barcodeScanner_;
    BOOL isConnect_;

    UIBackgroundTaskIdentifier bgTask;
    NSString *target_;
}
@property(weak, nonatomic) IBOutlet UITextField *textTarget;
@property(weak, nonatomic) IBOutlet UIButton *buttonConnect;
@property(weak, nonatomic) IBOutlet UIButton *buttonDisconnect;

@property(weak, nonatomic) IBOutlet UIButton *buttonClear;
@property(weak, nonatomic) IBOutlet UITextView *textScanner;
@property(strong, nonatomic) IBOutlet UIView *itemView;
@end
