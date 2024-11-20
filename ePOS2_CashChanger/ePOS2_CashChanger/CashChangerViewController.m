#import "CashChangerViewController.h"
#import "ShowMsg.h"
#import "AppDelegate.h"

@interface CashChangerViewController()
@property (weak, nonatomic) AppDelegate *appDelegate;
@end

@implementation CashChangerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    _textCashChanger.text = @"";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
 
    cchanger_ = _appDelegate.cchanger;
    isConnect_ = _appDelegate.isConnect;
    
    [self setEventDelegate];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _appDelegate.cchanger = cchanger_;
    _appDelegate.isConnect = isConnect_;
    
    [self releaseEventDelegate];
}

- (void)setEventDelegate
{
    if(cchanger_) {
        [cchanger_ setStatusChangeEventDelegate:self];
        [cchanger_ setStatusUpdateEventDelegate:self];
        [cchanger_ setDirectIOEventDelegate:self];
        [cchanger_ setConnectionEventDelegate:self];
    }
}

- (void)releaseEventDelegate
{
    if(cchanger_) {
        [cchanger_ setStatusChangeEventDelegate:nil];
        [cchanger_ setStatusUpdateEventDelegate:nil];
        [cchanger_ setDirectIOEventDelegate:nil];
        [cchanger_ setConnectionEventDelegate:nil];
    }
}

- (BOOL)initializeObject
{
    if (cchanger_ != nil) {
        [self finalizeObject];
    }
    
    cchanger_ = [[Epos2CashChanger alloc] init];
    if (cchanger_ == nil) {
        [ShowMsg showErrorEpos:EPOS2_ERR_MEMORY method:@"init"];
        return NO;
    }
    
    [self setEventDelegate];
    
    return YES;
}

- (void)finalizeObject
{
    if (cchanger_ == nil) {
        return;
    }

    [self releaseEventDelegate];
    
    cchanger_ = nil;
}

- (void)onCChangerStatusChange:(Epos2CashChanger *)cchangerObj code:(int)code status:(NSDictionary *)status
{
    [ShowMsg showResult:code];
    
    _textCashChanger.text = [_textCashChanger.text stringByAppendingString:[NSString stringWithFormat:@"OnStatusChange:\n"]];

    for (id key in [status keyEnumerator]) {
        int value = [[status valueForKey:key]intValue];
        NSString *text = [self getCashStatusText:value];
        _textCashChanger.text = [_textCashChanger.text stringByAppendingString:[NSString stringWithFormat:@"  %@:%@\n", key, text]];
    }
    [self scrollText];
}

- (void) onCChangerDirectIO:(Epos2CashChanger *)cchangerObj eventnumber:(long)eventnumber data:(long)data string:(NSString *)string
{
    _textCashChanger.text = [_textCashChanger.text stringByAppendingString:[NSString stringWithFormat:@"OnDirectIO:\n"]];
    _textCashChanger.text = [_textCashChanger.text stringByAppendingString:[NSString stringWithFormat:@"  eventnumber:%ld\n", eventnumber]];
    _textCashChanger.text = [_textCashChanger.text stringByAppendingString:[NSString stringWithFormat:@"  data:%ld\n", data]];
    _textCashChanger.text = [_textCashChanger.text stringByAppendingString:[NSString stringWithFormat:@"  string:%@\n", string]];
    [self scrollText];
}

- (void) onCChangerStatusUpdate:(Epos2CashChanger *)cchangerObj status:(long)status
{
    _textCashChanger.text = [_textCashChanger.text stringByAppendingString:[NSString stringWithFormat:@"OnStatusUpdate:\n"]];
    _textCashChanger.text = [_textCashChanger.text stringByAppendingString:[NSString stringWithFormat:@"  status:%@\n", [self getStatusUpdateText:status]]];
}

- (void) onConnection:(id)deviceObj eventType:(int)eventType
{
    if(eventType == EPOS2_EVENT_DISCONNECT) {
        isConnect_ = NO;
    }
    else {
        //Do each process.
    }
}

- (void)scrollText
{
    NSRange range;
    range = _textCashChanger.selectedRange;
    range.location = _textCashChanger.text.length;
    _textCashChanger.selectedRange = range;
    _textCashChanger.scrollEnabled = YES;
    
    CGFloat scrollY = _textCashChanger.contentSize.height + _textCashChanger.font.pointSize - _textCashChanger.bounds.size.height;
    CGPoint scrollPoint;
    
    if (scrollY < 0) {
        scrollY = 0;
    }
    
    scrollPoint = CGPointMake(0.0, scrollY);
    
    [_textCashChanger setContentOffset:scrollPoint animated:YES];
}

- (NSString *) getCashStatusText:(int)status
{
    NSString *text = @"";
    switch (status) {
        case EPOS2_ST_EMPTY:
            text = @"Empty";
            break;
        case EPOS2_ST_NEAR_EMPTY:
            text = @"NearEmpty";
            break;
        case EPOS2_ST_OK:
            text = @"OK";
            break;
        case EPOS2_ST_NEAR_FULL:
            text = @"NearFull";
            break;
        case EPOS2_ST_FULL:
            text = @"Full";
            break;
        default:
            break;
    }
    
    return text;
}

- (NSString *)getStatusUpdateText:(long)status
{
    NSString *text = @"";
    switch (status) {
        case EPOS2_CCHANGER_SUE_POWER_ONLINE:
            text = @"POWER_ONLINE";
            break;
        case EPOS2_CCHANGER_SUE_POWER_OFF:
            text = @"POWER_OFF";
            break;
        case EPOS2_CCHANGER_SUE_POWER_OFFLINE:
            text = @"POWER_OFFLINE";
            break;
        case EPOS2_CCHANGER_SUE_POWER_OFF_OFFLINE:
            text = @"OFF_OFFLINE";
            break;
        case EPOS2_CCHANGER_SUE_STATUS_EMPTY:
            text = @"STATUS_EMPTY";
            break;
        case EPOS2_CCHANGER_SUE_STATUS_NEAREMPTY:
            text = @"STATUS_NEAREMPTY";
            break;
        case EPOS2_CCHANGER_SUE_STATUS_EMPTYOK:
            text = @"STATUS_EMPTYOK";
            break;
        case EPOS2_CCHANGER_SUE_STATUS_FULL:
            text = @"STATUS_FULL";
            break;
        case EPOS2_CCHANGER_SUE_STATUS_NEARFULL:
            text = @"STATUS_NEARFULL";
            break;
        case EPOS2_CCHANGER_SUE_STATUS_FULLOK:
            text = @"STATUS_FULLOK";
            break;
        case EPOS2_CCHANGER_SUE_STATUS_JAM:
            text = @"STATUS_JAM";
            break;
        case EPOS2_CCHANGER_SUE_STATUS_JAMOK:
            text = @"STATUS_JAMOK";
            break;
        default:
            text = [NSString stringWithFormat:@"%ld", status];
            break;
    }
    return text;
}

@end
