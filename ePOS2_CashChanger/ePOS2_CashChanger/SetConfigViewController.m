#import "SetConfigViewController.h"
#import "ShowMsg.h"

@interface SetConfigViewController()<Epos2CChangerConfigChangeDelegate>
@end

@implementation SetConfigViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        cchanger_ = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    countModeList_ = [[PickerTableView alloc] init];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:NSLocalizedString(@"manual_input", @"")];
    [items addObject:NSLocalizedString(@"auto_count", @"")];
    
    [countModeList_ setItemList:items];
    [_buttonCountMode setTitle:[countModeList_ getItem:0] forState:UIControlStateNormal];
    countModeList_.delegate = self;
    
    countMode_ = EPOS2_COUNT_MODE_MANUAL_INPUT;

    _textCoins.keyboardType = UIKeyboardTypeNumberPad;
    _textBills.keyboardType = UIKeyboardTypeNumberPad;

    [self setDoneToolbar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setEventDelegate];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self releaseEventDelegate];
}

- (void)setEventDelegate
{
    [super setEventDelegate];
    
    if(cchanger_) {
        [cchanger_ setConfigChangeEventDelegate:self];
    }
}

- (void)releaseEventDelegate
{
    [super releaseEventDelegate];
    
    if(cchanger_) {
        [cchanger_ setConfigChangeEventDelegate:nil];
    }
}

- (void)setDoneToolbar
{
    UIToolbar *doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    
    [doneToolbar sizeToFit];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneCashChanger:)];
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects:space, doneButton, nil];
    [doneToolbar setItems:items animated:YES];
    _textCoins.inputAccessoryView = doneToolbar;
    _textBills.inputAccessoryView = doneToolbar;
}

- (void)doneCashChanger:(id)sender
{
    [_textCoins resignFirstResponder];
    [_textBills resignFirstResponder];
}

- (IBAction)eventButtonDidPush:(id)sender {
    [countModeList_ show];
}

- (IBAction)onSetCountMode:(id)sender {
    int result = EPOS2_SUCCESS;
    
    if(cchanger_ == nil) {
        return;
    }
    
    [cchanger_ setConfigCountMode:countMode_];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"setConfigCountMode"];
        return;
    }
}

- (IBAction)onSetLeftCash:(id)sender {
    int result = EPOS2_SUCCESS;
    long coins = [_textCoins.text intValue];
    long bills = [_textBills.text intValue];
    
    if(cchanger_ == nil) {
        return;
    }
    
    [cchanger_ setConfigLeftCash:coins bills:bills];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"setConfigLeftCash"];
        return;
    }
}

- (void) onCChangerConfigChange:(Epos2CashChanger *)cchangerObj code:(int)code
{
    [ShowMsg showResult:code];
}

- (IBAction)clearCashChanger:(id)sender
{
    self.textCashChanger.text = @"";
}

- (void)onSelectPickerItem:(NSInteger)position obj:(id)obj
{
    if (obj == countModeList_) {
        [_buttonCountMode setTitle:[countModeList_ getItem:position] forState:UIControlStateNormal];
        if(countModeList_.selectIndex == 0) {
            countMode_ = EPOS2_COUNT_MODE_MANUAL_INPUT;
        } else if(countModeList_.selectIndex == 1) {
            countMode_ = EPOS2_COUNT_MODE_AUTO_COUNT;
        } else {
            /* do nothing. */
        }
    }
}
@end
