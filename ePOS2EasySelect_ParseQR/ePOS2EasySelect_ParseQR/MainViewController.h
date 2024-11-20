#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *targetDeviceNameUILabel;
@property (weak, nonatomic) IBOutlet UILabel *targetInterfaceUILabel;
@property (weak, nonatomic) IBOutlet UILabel *targetMACAddressUILabel;

@property (weak, nonatomic) IBOutlet UIView *qpInfoBackgroundUIView;
@property (weak, nonatomic) IBOutlet UIView *qpPreviewTargetUIView;
@property (weak, nonatomic) IBOutlet UILabel *qpCannotUseVideoUILabel;

@property (weak, nonatomic) IBOutlet UILabel *qpQrCodeScanUILable;
@property (weak, nonatomic) IBOutlet UILabel *connectingUILabel;
@property (weak, nonatomic) IBOutlet UIButton *printUIButton;

- (IBAction)pressPrintUIButton:(id)sender;

@end
