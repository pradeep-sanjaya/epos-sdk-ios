#import "CollectViewController.h"
#import "ShowMsg.h"

@interface CollectViewController()<Epos2CChangerCollectDelegate>
@end

@implementation CollectViewController

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
    
    collectTypeList_ = [[PickerTableView alloc] init];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:NSLocalizedString(@"all_cash", @"")];
    [items addObject:NSLocalizedString(@"part_of_cash", @"")];
    
    [collectTypeList_ setItemList:items];
    [_buttonCollectType setTitle:[collectTypeList_ getItem:0] forState:UIControlStateNormal];
    collectTypeList_.delegate = self;
    
    collectType_ = EPOS2_COLLECT_ALL_CASH;
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
        [cchanger_ setCollectEventDelegate:self];
    }
}

- (void)releaseEventDelegate
{
    [super releaseEventDelegate];
    
    if(cchanger_) {
        [cchanger_ setCollectEventDelegate:nil];
    }
}

- (IBAction)eventButtonDidPush:(id)sender {
    [collectTypeList_ show];
}

- (IBAction)onCollectCash:(id)sender {
    int result = EPOS2_SUCCESS;
    
    if(cchanger_ == nil) {
        return;
    }
    
    [cchanger_ collectCash:collectType_];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"collectCash"];
        return;
    }
}

- (void) onCChangerCollect:(Epos2CashChanger *)cchangerObj code:(int)code
{
    [ShowMsg showResult:code];
}

- (IBAction)clearCashChanger:(id)sender
{
    self.textCashChanger.text = @"";
}

- (void)onSelectPickerItem:(NSInteger)position obj:(id)obj
{
    if (obj == collectTypeList_) {
        [_buttonCollectType setTitle:[collectTypeList_ getItem:position] forState:UIControlStateNormal];
        if(collectTypeList_.selectIndex == 0) {
            collectType_ = EPOS2_COLLECT_ALL_CASH;
        } else if(collectTypeList_.selectIndex == 1) {
            collectType_ = EPOS2_COLLECT_PART_OF_CASH;
        } else {
            /* do nothing. */
        }
    }
}
@end
