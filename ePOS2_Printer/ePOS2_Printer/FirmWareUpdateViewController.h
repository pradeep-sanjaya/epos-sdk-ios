#ifndef FirmWareUpdateViewController_h
#define FirmWareUpdateViewController_h

#import <UIKit/UIKit.h>
#import "PickerTableView.h"
#import "ePOS2.h"
#import "PrinterInfo.h"
#import "UIViewController+Extension.h"

@interface FirmWareUpdateViewController : UIViewController<SelectPickerTableDelegate, Epos2FirmwareListDownloadDelegate, Epos2FirmwareInformationDelegate, Epos2FirmwareUpdateDelegate>
{
    Epos2Printer *printer_;
    PrinterInfo *printerInfo_;

    PickerTableView *firmwareList_;
    NSMutableArray<Epos2FirmwareInfo *> *firmwareInfoList_;
    Epos2FirmwareInfo *targetFirmwareInfo_;
}

@property(weak, nonatomic) IBOutlet UINavigationItem *navigationItem;

@property (weak, nonatomic) IBOutlet UILabel *labelGetPrinterFirmware;
@property(weak, nonatomic) IBOutlet UIButton *buttonGetPrinterFirmware;

@property(weak, nonatomic) IBOutlet UITextField *textTargetPrinterModel;
@property (weak, nonatomic) IBOutlet UITextField *textTargetOption;

@property(weak, nonatomic) IBOutlet UIButton *buttonDownloadFirmwareList;
@property (weak, nonatomic) IBOutlet UIButton *buttonFirmwareList;

@property (weak, nonatomic) IBOutlet UITextField *textPassword;

@property (weak, nonatomic) IBOutlet UIButton *buttonUpdateFirmware;

@property(weak, nonatomic) IBOutlet UIView *viewWatingUpdate;
@property(weak, nonatomic) IBOutlet UILabel *labelWatingMessage;
@property(weak, nonatomic) IBOutlet UILabel *labelWaitingProgress;
@property (weak, nonatomic) IBOutlet UITextView *noteMessage;

@end
#endif /* FirmWareUpdateViewController_h */
