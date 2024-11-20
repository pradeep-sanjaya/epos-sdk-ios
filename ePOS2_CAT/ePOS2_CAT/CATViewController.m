#import "CATViewController.h"
#import "ShowMsg.h"
#import "AppDelegate.h"

@interface CATViewController()
@property (weak, nonatomic) AppDelegate *appDelegate;
@end

@implementation CATViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    _textCAT.text = @"";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
 
    cat_ = _appDelegate.cat;
    isConnect_ = _appDelegate.isConnect;

    [self setEventDelegate];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _appDelegate.cat = cat_;
    _appDelegate.isConnect = isConnect_;
    
    [self releaseEventDelegate];
}

- (void)setEventDelegate
{
    if(cat_) {
        [cat_ setStatusUpdateEventDelegate:self];
        [cat_ setConnectionEventDelegate:self];
    }
}

- (void)releaseEventDelegate
{
    if(cat_) {
        [cat_ setStatusUpdateEventDelegate:nil];
        [cat_ setConnectionEventDelegate:nil];
    }
}

- (BOOL)initializeObject
{
    if (cat_ != nil) {
        [self finalizeObject];
    }
    
    cat_ = [[Epos2CAT alloc] init];
    if (cat_ == nil) {
        [ShowMsg showErrorEpos:EPOS2_ERR_MEMORY method:@"init"];
        return NO;
    }
    
    [self setEventDelegate];
    
    return YES;
}

- (void)finalizeObject
{
    if (cat_ == nil) {
        return;
    }

    [self releaseEventDelegate];
    
    cat_ = nil;
}

- (void) onCATStatusUpdate:(Epos2CAT *)catObj status:(long)status
{
    _textCAT.text = [_textCAT.text stringByAppendingString:[NSString stringWithFormat:@"OnStatusUpdate:\n"]];
    _textCAT.text = [_textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  status:%@\n", [self getStatusUpdateText:status]]];
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
    range = _textCAT.selectedRange;
    range.location = _textCAT.text.length;
    _textCAT.selectedRange = range;
    _textCAT.scrollEnabled = YES;
    
    CGFloat scrollY = _textCAT.contentSize.height + _textCAT.font.pointSize - _textCAT.bounds.size.height;
    CGPoint scrollPoint;
    
    if (scrollY < 0) {
        scrollY = 0;
    }
    
    scrollPoint = CGPointMake(0.0, scrollY);
    
    [_textCAT setContentOffset:scrollPoint animated:YES];
}

- (NSString *) getPaymentConditionText:(int)paymentCondition
{
    NSString *text = @"";
    switch (paymentCondition) {
        case EPOS2_PAYMENT_CONDITION_LUMP_SUM:
            text = @"lump_sum";
            break;
        case EPOS2_PAYMENT_CONDITION_BONUS_1:
            text = @"bonus_1";
            break;
        case EPOS2_PAYMENT_CONDITION_BONUS_2:
            text = @"bonus_2";
            break;
        case EPOS2_PAYMENT_CONDITION_BONUS_3:
            text = @"bonus_3";
            break;
        case EPOS2_PAYMENT_CONDITION_BONUS_4:
            text = @"bonus_4";
            break;
        case EPOS2_PAYMENT_CONDITION_BONUS_5:
            text = @"bonus_5";
            break;
        case EPOS2_PAYMENT_CONDITION_INSTALLMENT_1:
            text = @"installment_1";
            break;
        case EPOS2_PAYMENT_CONDITION_INSTALLMENT_2:
            text = @"installment_2";
            break;
        case EPOS2_PAYMENT_CONDITION_INSTALLMENT_3:
            text = @"installment_3";
            break;
        case EPOS2_PAYMENT_CONDITION_REVOLVING:
            text = @"revolving";
            break;
        case EPOS2_PAYMENT_CONDITION_COMBINATION_1:
            text = @"combination_1";
            break;
        case EPOS2_PAYMENT_CONDITION_COMBINATION_2:
            text = @"combination_2";
            break;
        case EPOS2_PAYMENT_CONDITION_COMBINATION_3:
            text = @"combination_3";
            break;
        case EPOS2_PAYMENT_CONDITION_COMBINATION_4:
            text = @"combination_4";
            break;
        case EPOS2_PAYMENT_CONDITION_DEBIT:
            text = @"debit";
            break;
        case EPOS2_PAYMENT_CONDITION_ELECTRONIC_MONEY:
            text = @"electronic_money";
            break;
        case EPOS2_PAYMENT_CONDITION_OTHER:
            text = @"other";
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
        case EPOS2_CAT_SUE_POWER_ONLINE:
            text = @"POWER_ONLINE";
            break;
        case EPOS2_CAT_SUE_POWER_OFF_OFFLINE:
            text = @"OFF_OFFLINE";
            break;
        case EPOS2_CAT_SUE_LOGSTATUS_OK:
            text = @"LOGSTATUS_OK";
            break;
        case EPOS2_CAT_SUE_LOGSTATUS_NEARFULL:
            text = @"LOGSTATUS_NEARFULL";
            break;
        case EPOS2_CAT_SUE_LOGSTATUS_FULL:
            text = @"LOGSTATUS_FULL";
            break;
        default:
            text = [NSString stringWithFormat:@"%ld", status];
            break;
    }
    return text;
}

- (NSString *) getCatServiceText:(int)service
{
    NSMutableString *text = [[NSMutableString alloc]initWithString:@""];
    switch (service) {
        case EPOS2_SERVICE_CREDIT:
            [text appendString:@"Credit"];
            break;
        case EPOS2_SERVICE_DEBIT:
            [text appendString:@"Debit"];
            break;
        case EPOS2_SERVICE_UNIONPAY:
            [text appendString:@"UnionPay"];
            break;
        case EPOS2_SERVICE_EDY:
            [text appendString:@"Edy"];
            break;
        case EPOS2_SERVICE_ID:
            [text appendString:@"iD"];
            break;
        case EPOS2_SERVICE_NANACO:
            [text appendString:@"nanaco"];
            break;
        case EPOS2_SERVICE_QUICPAY:
            [text appendString:@"QUICPay"];
            break;
        case EPOS2_SERVICE_SUICA:
            [text appendString:@"Suica"];
            break;
        case EPOS2_SERVICE_WAON:
            [text appendString:@"WAON"];
            break;
        case EPOS2_SERVICE_POINT:
            [text appendString:@"POINT"];
            break;
        case EPOS2_SERVICE_COMMON:
            [text appendString:@"common"];
            break;
        case EPOS2_SERVICE_NFCPAYMENT:
            [text appendString:@"NFCPayment"];
            break;
        case EPOS2_SERVICE_PITAPA:
            [text appendString:@"PiTaPa"];
            break;
        case EPOS2_SERVICE_FISC:
            [text appendString:@"FISC"];
            break;
        case EPOS2_SERVICE_QR:
            [text appendString:@"QR"];
            break;
        case EPOS2_SERVICE_CREDIT_DEBIT:
            [text appendString:@"CreditDebit"];
            break;
        case EPOS2_SERVICE_MULTI:
            [text appendString:@"Multi"];
            break;
        default:
            // Do nothing
            break;
    }
    
    return text;
}

@end
