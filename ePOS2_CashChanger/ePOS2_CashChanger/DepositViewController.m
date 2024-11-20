#import "DepositViewController.h"
#import "ShowMsg.h"

@interface DepositViewController()<Epos2CChangerDepositDelegate>
@end

@implementation DepositViewController

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
    
    configList_ = [[PickerTableView alloc] init];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:NSLocalizedString(@"change", @"")];
    [items addObject:NSLocalizedString(@"nochange", @"")];
    [items addObject:NSLocalizedString(@"repay", @"")];
    
    [configList_ setItemList:items];
    [_buttonConfig setTitle:[configList_ getItem:0] forState:UIControlStateNormal];
    configList_.delegate = self;
    
    config_ = EPOS2_DEPOSIT_CHANGE;
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
        [cchanger_ setDepositEventDelegate:self];
    }
}

- (void)releaseEventDelegate
{
    [super releaseEventDelegate];
    
    if(cchanger_) {
        [cchanger_ setDepositEventDelegate:nil];
    }
}

- (IBAction)eventButtonDidPush:(id)sender {
    [configList_ show];
}

- (IBAction)onBeginDeposit:(id)sender {
    int result = EPOS2_SUCCESS;
    if(cchanger_ == nil) {
        return;
    }
    
    [cchanger_ beginDeposit];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"beginDeposit"];
        return;
    }
}

- (IBAction)onPauseDeposit:(id)sender {
    int result = EPOS2_SUCCESS;
    if(cchanger_ == nil) {
        return;
    }
    
    [cchanger_ pauseDeposit];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"pauseDeposit"];
        return;
    }
}

- (IBAction)onRestartDeposit:(id)sender {
    int result = EPOS2_SUCCESS;
    if(cchanger_ == nil) {
        return;
    }
    
    [cchanger_ restartDeposit];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"restartDeposit"];
        return;
    }
}

- (IBAction)onEndDeposit:(id)sender {
    int result = EPOS2_SUCCESS;
    if(cchanger_ == nil) {
        return;
    }
    
    [cchanger_ endDeposit:config_];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"endDeposit"];
        return;
    }
}

- (void) onCChangerDeposit:(Epos2CashChanger *)cchangerObj code:(int)code status:(int)status amount:(long)amount data:(NSDictionary *)data
{
    int oposCode = 0;
    if(code == EPOS2_CCHANGER_CODE_ERR_OPOSCODE) {
        oposCode = [cchangerObj getOposErrorCode];
        [ShowMsg showResult:code oposCode:oposCode];
    } else {
        [ShowMsg showResult:code];
    }

    self.textCashChanger.text = [self.textCashChanger.text stringByAppendingString:[NSString stringWithFormat:@"OnDeposit:\n"]];
    self.textCashChanger.text = [self.textCashChanger.text stringByAppendingString:[NSString stringWithFormat:@"  status:%@\n", [self getStatusText:status]]];
    self.textCashChanger.text = [self.textCashChanger.text stringByAppendingString:[NSString stringWithFormat:@"  amount:%ld\n", amount]];
    
    for (id key in [data keyEnumerator]) {
        long value = [[data valueForKey:key]longValue];
        self.textCashChanger.text = [self.textCashChanger.text stringByAppendingString:[NSString stringWithFormat:@"  %@:%ld\n", key, value]];
    }
    [self scrollText];
}

- (IBAction)clearCashChanger:(id)sender
{
    self.textCashChanger.text = @"";
}

- (void)onSelectPickerItem:(NSInteger)position obj:(id)obj
{
    if (obj == configList_) {
        [_buttonConfig setTitle:[configList_ getItem:position] forState:UIControlStateNormal];
        if(configList_.selectIndex == 0) {
            config_ = EPOS2_DEPOSIT_CHANGE;
        } else if(configList_.selectIndex == 1) {
            config_ = EPOS2_DEPOSIT_NOCHANGE;
        } else if(configList_.selectIndex == 2) {
            config_ = EPOS2_DEPOSIT_REPAY;
        } else {
            /* do nothing. */
        }
    }
}

- (NSString *)getStatusText:(int)status
{
    NSString *text = @"";
    switch (status) {
        case EPOS2_CCHANGER_STATUS_BUSY:
            text = @"Busy";
            break;
        case EPOS2_CCHANGER_STATUS_PAUSE:
            text = @"Pause";
            break;
        case EPOS2_CCHANGER_STATUS_END:
            text = @"End";
            break;
        case EPOS2_CCHANGER_STATUS_ERR:
            text = @"Error";
            break;
        default:
            text = [NSString stringWithFormat:@"%d", status];
            break;
    }
    return text;
}
@end
