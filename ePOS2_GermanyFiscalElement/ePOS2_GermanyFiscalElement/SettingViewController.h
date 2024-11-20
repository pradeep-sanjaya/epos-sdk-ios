#import <UIKit/UIKit.h>

#import "GermanyFiscalElementViewController.h"
#import "EPOS2SDKManager.h"
#import "PickerTableView.h"

@interface SettingViewController : GermanyFiscalElementViewController<SelectPickerTableDelegate, SDKDelegate>
{
    PickerTableView *printerList_;
    NSOperationQueue *queueForSDK;
    EPOS2SDKManager* ePOS2SDKManager;
    dispatch_semaphore_t gfeSemaphore;

    NSString* challenge_;
    NSString* tseInitializationState_;
}
@property (weak, nonatomic) IBOutlet UIButton *buttonDiscovery;
@property (weak, nonatomic) IBOutlet UIButton *buttonPrinter;
@property (weak, nonatomic) IBOutlet UISwitch *switchDisplay;
@property (weak, nonatomic) IBOutlet UISwitch *switchScanner;
@property (weak, nonatomic) IBOutlet UITextField *textTargetGfe;
@property (weak, nonatomic) IBOutlet UITextField *textTargetPrinter;
@property (weak, nonatomic) IBOutlet UITextField *textTargetDisplay;
@property (weak, nonatomic) IBOutlet UITextField *textTargetScanner;
@property (weak, nonatomic) IBOutlet UITextField *textClientId;
@property (weak, nonatomic) IBOutlet UIButton *buttonSetup;
@property (weak, nonatomic) IBOutlet UITextView *textSetup;


@end

