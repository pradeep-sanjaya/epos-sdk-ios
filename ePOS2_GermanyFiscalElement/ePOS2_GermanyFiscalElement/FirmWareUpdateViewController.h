#ifndef FirmWareUpdateViewController_h
#define FirmWareUpdateViewController_h

#import <UIKit/UIKit.h>
#import "PickerTableView.h"
#import "DiscoveryViewController.h"
#import "ePOS2.h"

@interface FirmWareUpdateViewController : GermanyFiscalElementViewController<SelectPickerTableDelegate, SDKDelegate>
{
    NSOperationQueue *queueForSDK;
    EPOS2SDKManager* ePOS2SDKManager;

    PickerTableView *firmwareList_;

    NSMutableArray<Epos2FirmwareInfo *> *firmwareInfoList_;

    NSString* printerModel_;
    Epos2FirmwareInfo *targetFirmwareInfo_;
}
@property (weak, nonatomic) IBOutlet UILabel *labelGetPrinterFirmware;
@property(weak, nonatomic) IBOutlet UIButton *buttonGetPrinterFirmware;

@property (weak, nonatomic) IBOutlet UITextField *textTargetPrinterModel;
@property (weak, nonatomic) IBOutlet UITextField *textTargetOption;


@property(weak, nonatomic) IBOutlet UIButton *buttonDownloadFirmwareList;
@property (weak, nonatomic) IBOutlet UIButton *buttonFirmwareList;

@property (weak, nonatomic) IBOutlet UIButton *buttonUpdateFirmware;
@property (weak, nonatomic) IBOutlet UITextView *textFWUpdate;

@property(weak, nonatomic) IBOutlet UIView *viewWatingUpdate;
@property(weak, nonatomic) IBOutlet UILabel *labelWatingMessage;
@property(weak, nonatomic) IBOutlet UILabel *labelWaitingProgress;
@property (weak, nonatomic) IBOutlet UITextView *noteMessage;

@end
#endif /* FirmWareUpdateViewController_h */
