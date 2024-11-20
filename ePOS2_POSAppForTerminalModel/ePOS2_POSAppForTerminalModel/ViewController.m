//
//  ViewController.m
//  ePOS2_Composite
//
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()
@property (weak, nonatomic) AppDelegate *appDelegate;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if(_appDelegate.targetPrinter == nil || _appDelegate.targetDisplay == nil || _appDelegate.targetScanner == nil || _appDelegate.targetCashChanger == nil) {
        _appDelegate.printerSeries = EPOS2_TM_T88;
        _appDelegate.targetPrinter = NSLocalizedString(@"default_target_printer", nil);
        _appDelegate.targetDisplay = NSLocalizedString(@"default_target_display", nil);
        _appDelegate.targetScanner = NSLocalizedString(@"default_target_scanner", nil);
        _appDelegate.targetCashChanger = NSLocalizedString(@"default_target_cashchanger", nil);
        _appDelegate.enableDisplay = NO;
        _appDelegate.enableScanner = NO;
        _appDelegate.enableCashChanger = NO;
    }
    [Epos2Log setLogSettings:EPOS2_PERIOD_PERMANENT output:EPOS2_OUTPUT_STORAGE ipAddress:nil port:0 logSize:50 logLevel:EPOS2_LOGLEVEL_LOW];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

@end
