#import "CashCountViewController.h"
#import "ShowMsg.h"

@interface CashCountViewController()<Epos2CChangerCashCountDelegate>
@end

@implementation CashCountViewController

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
        [cchanger_ setCashCountEventDelegate:self];
    }
}

- (void)releaseEventDelegate
{
    [super releaseEventDelegate];
    
    if(cchanger_) {
        [cchanger_ setCashCountEventDelegate:nil];
    }
}

- (IBAction)onReadCashCount:(id)sender {
    int result = EPOS2_SUCCESS;
    if(cchanger_ == nil) {
        return;
    }
    
    [cchanger_ readCashCount];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"readCashCount"];
        return;
    }
}

- (void) onCChangerCashCount:(Epos2CashChanger *)cchangerObj code:(int)code data:(NSDictionary *)data
{

    [ShowMsg showResult:code];
    
    self.textCashChanger.text = [self.textCashChanger.text stringByAppendingString:[NSString stringWithFormat:@"OnCashCount:\n"]];
    
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
@end
