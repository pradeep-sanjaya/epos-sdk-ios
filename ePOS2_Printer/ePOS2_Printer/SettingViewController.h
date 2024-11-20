#ifndef SettingViewController_h
#define SettingViewController_h

#import <UIKit/UIKit.h>
#import "PickerTableView.h"
#import "DiscoveryViewController.h"
#import "ePOS2.h"
#import "PrinterInfo.h"
#import "UIViewController+Extension.h"

@interface SettingViewController : UIViewController<SelectPickerTableDelegate, Epos2MaintenanceCounterDelegate, Epos2PrinterSettingDelegate>
{
    Epos2Printer *printer_;
    int printerSeries_;
    int lang_;
    PickerTableView *printerList_;
    PickerTableView *langList_;
    
    PickerTableView *printSpeedList_;
    PickerTableView *printDensityList_;
    PickerTableView *paperWidthList_;
    
    int printSpeed;
    int printDensity;
    int paperWidth;
    
    PrinterInfo *printerInfo_;
}

@property(weak, nonatomic) IBOutlet UILabel *labelAutoCutter;
@property(weak, nonatomic) IBOutlet UILabel *labelPaperFeed;
@property(weak, nonatomic) IBOutlet UIButton *buttonPrintSpeed;
@property(weak, nonatomic) IBOutlet UIButton *buttonPrintDensity;
@property(weak, nonatomic) IBOutlet UIButton *buttonPaperWidth;
@property (weak, nonatomic) IBOutlet UIButton *buttonGetMaintenanceCut;
@property (weak, nonatomic) IBOutlet UIButton *buttonResetMaintenanceCut;
@property (weak, nonatomic) IBOutlet UIButton *buttonGetMaintenanceFeed;
@property (weak, nonatomic) IBOutlet UIButton *buttonResetMaintenanceFeed;
@property (weak, nonatomic) IBOutlet UIButton *buttonGetSpeed;
@property (weak, nonatomic) IBOutlet UIButton *buttonSetSpeed;
@property (weak, nonatomic) IBOutlet UIButton *buttonGetDensity;
@property (weak, nonatomic) IBOutlet UIButton *buttonSetDensity;
@property (weak, nonatomic) IBOutlet UIButton *buttonGetWidth;
@property (weak, nonatomic) IBOutlet UIButton *buttonSetWidth;


@property(weak, nonatomic) IBOutlet UIView *viewWatingRestart;
@property(weak, nonatomic) IBOutlet UILabel *labelWatingRestart;
@property(weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorWatingRestart;

@end

#endif /* SettingViewController_h */
