//
//  SettingViewController.m
//  ePOS2_Composite
//
//

#import "SettingViewController.h"
#import "AppDelegate.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    printerList_ = [[PickerTableView alloc] init];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:NSLocalizedString(@"printerseries_t88", @"")];
    [items addObject:NSLocalizedString(@"printerseries_t70", @"")];
    [printerList_ setItemList:items];
    [_buttonPrinter setTitle:[printerList_ getItem:0] forState:UIControlStateNormal];
    printerList_.delegate = self;
    
    [self setDoneToolbar];
    
    _switchDisplay.on = NO;
    _switchScanner.on = NO;
    _switchCashChanger.on = NO;
    [_switchDisplay addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [_switchScanner addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [_switchCashChanger addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_switchDisplay];
    [self.view addSubview:_switchScanner];
    [self.view addSubview:_switchCashChanger];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *appDelegate =(AppDelegate*) [[UIApplication sharedApplication] delegate];
    _textTargetPrinter.text = appDelegate.targetPrinter;
    _textTargetDisplay.text = appDelegate.targetDisplay;
    _textTargetScanner.text = appDelegate.targetScanner;
    _textTargetCashChanger.text = appDelegate.targetCashChanger;
    _switchDisplay.on = appDelegate.enableDisplay;
    _switchScanner.on = appDelegate.enableScanner;
    _switchCashChanger.on = appDelegate.enableCashChanger;
    
    int position = 0;
    switch ((int)appDelegate.printerSeries) {
        case EPOS2_TM_T88:
            position = 0;
            break;
        case EPOS2_TM_T70:
            position = 1;
            break;
        default:
            break;
    }
    [_buttonPrinter setTitle:[printerList_ getItem:position] forState:UIControlStateNormal];
}

- (void)setDoneToolbar
{
    UIToolbar *doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    
    [doneToolbar sizeToFit];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneKeyboard:)];
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects:space, doneButton, nil];
    [doneToolbar setItems:items animated:YES];
    _textTargetPrinter.inputAccessoryView = doneToolbar;
    _textTargetDisplay.inputAccessoryView = doneToolbar;
    _textTargetScanner.inputAccessoryView = doneToolbar;
    _textTargetCashChanger.inputAccessoryView = doneToolbar;
}

- (void)doneKeyboard:(id)sender
{
    [_textTargetPrinter resignFirstResponder];
    [_textTargetDisplay resignFirstResponder];
    [_textTargetScanner resignFirstResponder];
    [_textTargetCashChanger resignFirstResponder];
    
    //update appdelegate
    AppDelegate *appDelegate =(AppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.targetPrinter = _textTargetPrinter.text;
    appDelegate.targetDisplay = _textTargetDisplay.text;
    appDelegate.targetScanner = _textTargetScanner.text;
    appDelegate.targetCashChanger = _textTargetCashChanger.text;
}

- (IBAction)eventButtonDidPush:(id)sender {
    switch (((UIView *)sender).tag) {
        case 1:
            [printerList_ show];
            break;
        default:
            break;
    }
}

- (void)onSelectPickerItem:(NSInteger)position obj:(id)obj
{
    AppDelegate *appDelegate =(AppDelegate*) [[UIApplication sharedApplication] delegate];
    if (obj == printerList_) {
        [_buttonPrinter setTitle:[printerList_ getItem:position] forState:UIControlStateNormal];
        switch ((int)printerList_.selectIndex) {
            case 0:
                appDelegate.printerSeries = EPOS2_TM_T88;
                break;
            case 1:
                appDelegate.printerSeries = EPOS2_TM_T70;
                break;
            default:
                break;
        }
    }
}

- (void) switchChanged:(UISwitch*)switchParts
{
    AppDelegate *appDelegate =(AppDelegate*) [[UIApplication sharedApplication] delegate];
    if(_switchDisplay.on) {
        appDelegate.enableDisplay = YES;
    } else {
        appDelegate.enableDisplay = NO;
    }
    
    if(_switchScanner.on) {
        appDelegate.enableScanner = YES;
    } else {
        appDelegate.enableScanner = NO;
    }
    
    if(_switchCashChanger.on) {
        appDelegate.enableCashChanger = YES;
    } else {
        appDelegate.enableCashChanger = NO;
    }
    
}


@end
