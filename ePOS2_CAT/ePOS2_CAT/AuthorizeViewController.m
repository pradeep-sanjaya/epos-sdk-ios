#import "AuthorizeViewController.h"
#import "ShowMsg.h"

#define SEQUENCE_NUM    (0001)

@interface AuthorizeViewController()<Epos2CATAuthorizeSalesDelegate, Epos2CATAuthorizeVoidDelegate,Epos2CATClearOutputDelegate, Epos2CATAuthorizeRefundDelegate, Epos2CATAuthorizeCompletionDelegate,Epos2CATAccessDailyLogDelegate,Epos2CATCheckConnectionDelegate,Epos2CATDirectIODelegate,Epos2CATCashDepositDelegate>
@end

@implementation AuthorizeViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        cat_ = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    serviceList_ = [[PickerTableView alloc] init];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:NSLocalizedString(@"credit", @"")];
    [items addObject:NSLocalizedString(@"debit", @"")];
    [items addObject:NSLocalizedString(@"unionpay", @"")];
    [items addObject:NSLocalizedString(@"edy", @"")];
    [items addObject:NSLocalizedString(@"id", @"")];
    [items addObject:NSLocalizedString(@"nanaco", @"")];
    [items addObject:NSLocalizedString(@"quicpay", @"")];
    [items addObject:NSLocalizedString(@"suica", @"")];
    [items addObject:NSLocalizedString(@"waon", @"")];
    [items addObject:NSLocalizedString(@"point", @"")];
    [items addObject:NSLocalizedString(@"nfcpayment", @"")];
    [items addObject:NSLocalizedString(@"pitapa", @"")];
    [items addObject:NSLocalizedString(@"fisc", @"")];
    [items addObject:NSLocalizedString(@"qr", @"")];
    [items addObject:NSLocalizedString(@"credit_debit", @"")];
    [items addObject:NSLocalizedString(@"multi", @"")];
    
    [serviceList_ setItemList:items];
    [_buttonService setTitle:[serviceList_ getItem:0] forState:UIControlStateNormal];
    serviceList_.delegate = self;
    service_ = EPOS2_SERVICE_CREDIT;
    
    authorizeList_ = [[PickerTableView alloc] init];
    items = [[NSMutableArray alloc ] init];
    [items addObject:NSLocalizedString(@"authorize_sales", @"")];
    [items addObject:NSLocalizedString(@"authorize_void", @"")];
    [items addObject:NSLocalizedString(@"authorize_refund", @"")];
    [items addObject:NSLocalizedString(@"authorize_completion", @"")];
    [items addObject:NSLocalizedString(@"clear_output", @"")];
    
    [authorizeList_ setItemList:items];
    [_buttonAuthorize setTitle:[authorizeList_ getItem:0] forState:UIControlStateNormal];
    authorizeList_.delegate = self;
    authorize_ = 0;
    
    _textTotalAmount.keyboardType = UIKeyboardTypeNumberPad;
    _textAmount.keyboardType = UIKeyboardTypeNumberPad;
    _textTax.keyboardType = UIKeyboardTypeNumberPad;
    
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
    
    if(cat_) {
        [cat_ setAuthorizeSalesEventDelegate:self];
        [cat_ setAuthorizeVoidEventDelegate:self];
        [cat_ setAuthorizeRefundEventDelegate:self];
        [cat_ setAuthorizeCompletionEventDelegate:self];
        [cat_ setAccessDailyLogEventDelegate:self];
        [cat_ setCheckConnectionEventDelegate:self];
        [cat_ setClearOutputEventDelegate:self];
        [cat_ setDirectIOEventDelegate:self];
        [cat_ setCashDepositEventDelegate:self];
    }
}

- (void)releaseEventDelegate
{
    [super releaseEventDelegate];
    
    if(cat_) {
        [cat_ setAuthorizeSalesEventDelegate:nil];
        [cat_ setAuthorizeVoidEventDelegate:nil];
        [cat_ setAuthorizeRefundEventDelegate:nil];
        [cat_ setAuthorizeCompletionEventDelegate:nil];
        [cat_ setAccessDailyLogEventDelegate:nil];
        [cat_ setCheckConnectionEventDelegate:nil];
        [cat_ setClearOutputEventDelegate:nil];
        [cat_ setDirectIOEventDelegate:nil];
        [cat_ setCashDepositEventDelegate:nil];
    }
}

- (void)setDoneToolbar
{
    UIToolbar *doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    
    [doneToolbar sizeToFit];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneCAT:)];
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects:space, doneButton, nil];
    [doneToolbar setItems:items animated:YES];
    _textTotalAmount.inputAccessoryView = doneToolbar;
    _textAmount.inputAccessoryView = doneToolbar;
    _textTax.inputAccessoryView = doneToolbar;
    _textAsi.inputAccessoryView = doneToolbar;
    _textDailyLogType.inputAccessoryView = doneToolbar;
}

- (void)doneCAT:(id)sender
{
    [_textTotalAmount resignFirstResponder];
    [_textAmount resignFirstResponder];
    [_textTax resignFirstResponder];
    [_textAsi resignFirstResponder];
    [_textDailyLogType resignFirstResponder];
}

- (IBAction)eventButtonDidPush:(id)sender
{
    switch (((UIView *)sender).tag) {
        case 1:
            [serviceList_ show];
            break;
        case 2:
            [authorizeList_ show];
            break;
        default:
            break;
    }
}

- (IBAction)onClearance:(id)sender
{
    int result = EPOS2_SUCCESS;
    long totalAmount = [_textTotalAmount.text intValue];
    long amount = [_textAmount.text intValue];
    long tax = [_textTax.text intValue];
    NSString *asi = _textAsi.text;
    
    if(cat_ == nil) {
        return;
    }
    
    switch (authorize_) {
        case 0:// authorizeSalse
            result = [cat_ authorizeSales:service_ totalAmount:totalAmount amount:amount tax:tax sequence:SEQUENCE_NUM additionalSecurityInformation:asi];
            break;
        case 1:// authorizeVoid
            result = [cat_ authorizeVoid:service_ totalAmount:totalAmount amount:amount tax:tax sequence:SEQUENCE_NUM additionalSecurityInformation:asi];
            break;
        case 2:// authorizeRefund
            result = [cat_ authorizeRefund:service_ totalAmount:totalAmount amount:amount tax:tax sequence:SEQUENCE_NUM additionalSecurityInformation:asi];
            break;
        case 3:// authorizeComplation
            result = [cat_ authorizeCompletion:service_ totalAmount:totalAmount amount:amount tax:tax sequence:SEQUENCE_NUM additionalSecurityInformation:asi];
            break;
        case 4:// clearOutput
            result = [cat_ clearOutput];
            break;
        default:
            break;
    }
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:[authorizeList_ getItem:authorize_]];
        return;
    }
}

- (IBAction)onAccessDailyLog:(id)sender {
    int result = EPOS2_SUCCESS;
    NSString *asi = _textAsi.text;
    NSString *dailyLogType = _textDailyLogType.text;
    
    if(cat_ == nil) {
        return;
    }
    
    result = [cat_ accessDailyLog:service_ sequence:SEQUENCE_NUM dailyLogType:dailyLogType additionalSecurityInformation:asi];
    
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"accessDailyLog"];
        return;
    }
}

- (IBAction)onCheckConnection:(id)sender {
    int result = EPOS2_SUCCESS;
    NSString *asi = _textAsi.text;
    
    if(cat_ == nil) {
        return;
    }
    
    result = [cat_ checkConnection:asi];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"checkConnection"];
        return;
    }
}

- (IBAction)onCashDeposit:(id)sender {
    int result = EPOS2_SUCCESS;
    long amount = [_textAmount.text intValue];
    
    if(cat_ == nil) {
        return;
    }
    
    result = [cat_ cashDeposit:service_ amount:amount sequence:SEQUENCE_NUM];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"cashDeposit"];
        return;
    }
}

- (void) onCATAuthorizeSales:(Epos2CAT *)catObj code:(int)code sequence:(long)sequence service:(int)service result:(Epos2CATAuthorizeResult *)result
{
    int oposCode = 0;
    if(code == EPOS2_CAT_CODE_ERR_OPOSCODE) {
        oposCode = [catObj getOposErrorCode];
        [ShowMsg showResult:code oposCode:oposCode];
    } else {
        [ShowMsg showResult:code];
    }
    
    if(result != nil) {
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"OnCATAuthorizeSales:\n"]];
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  Sequence:%ld\n", sequence]];
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  Service:%@\n", [self getCatServiceText:service]]];
        self.textCAT.text = [self.textCAT.text stringByAppendingString:@"  Result:\n"];
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[self makeAuthorizeResultMessage:result]];
    }
    [self scrollText];
}

- (void) onCATAuthorizeVoid:(Epos2CAT *)catObj code:(int)code sequence:(long)sequence service:(int)service result:(Epos2CATAuthorizeResult *)result
{
    int oposCode = 0;
    if(code == EPOS2_CAT_CODE_ERR_OPOSCODE) {
        oposCode = [catObj getOposErrorCode];
        [ShowMsg showResult:code oposCode:oposCode];
    } else {
        [ShowMsg showResult:code];
    }
    
    if(result != nil) {
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"OnCATAuthorizeVoid:\n"]];
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  Sequence:%ld\n", sequence]];
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  Service:%@\n", [self getCatServiceText:service]]];
        self.textCAT.text = [self.textCAT.text stringByAppendingString:@"  Result:\n"];
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[self makeAuthorizeResultMessage:result]];
    }
    [self scrollText];
}

- (void)onCATClearOutput:(Epos2CAT *)catObj code:(int)code abortCode:(long)abortCode {
    int oposCode = 0;
    if(code == EPOS2_CAT_CODE_ERR_OPOSCODE) {
        oposCode = [catObj getOposErrorCode];
        [ShowMsg showResult:code oposCode:oposCode];
    } else {
        [ShowMsg showResult:code];
    }
    
    self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"OnCATClearOutput:\n"]];
    self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  AbortCode:%ld\n", abortCode]];
    
    [self scrollText];
}

- (void) onCATAuthorizeRefund:(Epos2CAT *)catObj code:(int)code sequence:(long)sequence service:(int)service result:(Epos2CATAuthorizeResult *)result
{
    int oposCode = 0;
    if(code == EPOS2_CAT_CODE_ERR_OPOSCODE) {
        oposCode = [catObj getOposErrorCode];
        [ShowMsg showResult:code oposCode:oposCode];
    } else {
        [ShowMsg showResult:code];
    }
    
    if(result != nil) {
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"OnCATAuthorizeRefund:\n"]];
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  Sequence:%ld\n", sequence]];
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  Service:%@\n", [self getCatServiceText:service]]];
        self.textCAT.text = [self.textCAT.text stringByAppendingString:@"  Result:\n"];
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[self makeAuthorizeResultMessage:result]];
    }
    [self scrollText];
}

- (void) onCATAuthorizeCompletion:(Epos2CAT *)catObj code:(int)code sequence:(long)sequence service:(int)service result:(Epos2CATAuthorizeResult *)result
{
    int oposCode = 0;
    if(code == EPOS2_CAT_CODE_ERR_OPOSCODE) {
        oposCode = [catObj getOposErrorCode];
        [ShowMsg showResult:code oposCode:oposCode];
    } else {
        [ShowMsg showResult:code];
    }
    
    if(result != nil) {
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"OnCATAuthorizeCompletion:\n"]];
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  Sequence:%ld\n", sequence]];
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  Service:%@\n", [self getCatServiceText:service]]];
        self.textCAT.text = [self.textCAT.text stringByAppendingString:@"  Result:\n"];
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[self makeAuthorizeResultMessage:result]];
    }
    [self scrollText];
}

- (void) onCATAccessDailyLog:(Epos2CAT *)catObj code:(int)code sequence:(long)sequence service:(int)service dailyLog:(NSArray *)dailyLog
{
    int oposCode = 0;
    if(code == EPOS2_CAT_CODE_ERR_OPOSCODE) {
        oposCode = [catObj getOposErrorCode];
        [ShowMsg showResult:code oposCode:oposCode];
    } else {
        [ShowMsg showResult:code];
    }
    
    if(dailyLog != nil) {
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"OnCATAccessDailyLog:\n"]];
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  Sequence:%ld\n", sequence]];
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  Service:%@\n", [self getCatServiceText:service]]];
        for(Epos2CATDailyLog *log in dailyLog) {
            self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  Kid:%@\n", [log getKid]]];
            self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  SalesCount:%lld\n", [log getSalesCount]]];
            self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  SalesAmount:%lld\n", [log getSalesAmount]]];
            self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  VoidCount:%lld\n", [log getVoidCount]]];
            self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  VoidAmount:%lld\n", [log getVoidAmount]]];
        }
    }
    [self scrollText];
}

- (void) onCATCheckConnection:(Epos2CAT *)catObj code:(int)code additionalSecurityInformation:(NSString *)asi
{
    int oposCode = 0;
    if(code == EPOS2_CAT_CODE_ERR_OPOSCODE) {
        oposCode = [catObj getOposErrorCode];
        [ShowMsg showResult:code oposCode:oposCode];
    } else {
        [ShowMsg showResult:code];
    }
    
    if(asi != nil) {
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"OnCATCheckConnection:\n"]];
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  additionalSecurityInformation:%@\n", asi]];
    }
    [self scrollText];
}

- (void) onCATDirectIO:(Epos2CAT *)catObj eventNumber:(long)eventNumber data:(long)data string:(NSString *)string
{
    self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"OnCATDirectIO:\n"]];
    self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  EventNumber:%ld\n", eventNumber]];
    self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  Data:%ld\n", data]];
    self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  String:%@\n", string]];
    
    [self scrollText];
}

- (void) onCATCashDeposit:(Epos2CAT *)catObj code:(int)code sequence:(long)sequence service:(int)service result:(Epos2CATCashDepositResult *)result
{
    int oposCode = 0;
    if(code == EPOS2_CAT_CODE_ERR_OPOSCODE) {
        oposCode = [catObj getOposErrorCode];
        [ShowMsg showResult:code oposCode:oposCode];
    } else {
        [ShowMsg showResult:code];
    }
    
    if(result != nil) {
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"onCATCashDeposit:\n"]];
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  Sequence:%ld\n", sequence]];
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  Service:%@\n", [self getCatServiceText:service]]];
        self.textCAT.text = [self.textCAT.text stringByAppendingString:@"  Result:\n"];
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[self makeCashDepositResultMessage:result]];
    }
    [self scrollText];
}

- (NSString *) makeCashDepositResultMessage:(Epos2CATCashDepositResult *)result
{
    NSMutableString *resultMsg = [[NSMutableString alloc]initWithString:@""];
    
    [resultMsg appendString:[NSString stringWithFormat:@"    AccountNumber:%@\n", [result getAccountNumber]]];
    [resultMsg appendString:[NSString stringWithFormat:@"    SlipNumber:%@\n", [result getSlipNumber]]];
    [resultMsg appendString:[NSString stringWithFormat:@"    PaymentCondition:%@\n", [self getPaymentConditionText:[result getPaymentCondition]]]];
    [resultMsg appendString:[NSString stringWithFormat:@"    Balance:%ld\n", [result getBalance]]];
    [resultMsg appendString:[NSString stringWithFormat:@"    AdditionalSecurityInformation:%@\n", [result getAdditionalSecurityInformation]]];
    
    return resultMsg;
}

- (NSString *) makeAuthorizeResultMessage:(Epos2CATAuthorizeResult *)result
{
    NSMutableString *resultMsg = [[NSMutableString alloc]initWithString:@""];
    
    [resultMsg appendString:[NSString stringWithFormat:@"    AccountNumber:%@\n", [result getAccountNumber]]];
    [resultMsg appendString:[NSString stringWithFormat:@"    SettledAmount:%ld\n", [result getSettledAmount]]];
    [resultMsg appendString:[NSString stringWithFormat:@"    SlipNumber:%@\n", [result getSlipNumber]]];
    [resultMsg appendString:[NSString stringWithFormat:@"    Kid:%@\n", [result getKid]]];
    [resultMsg appendString:[NSString stringWithFormat:@"    ApprovalCode:%@\n", [result getApprovalCode]]];
    [resultMsg appendString:[NSString stringWithFormat:@"    TransactionNumber:%@\n", [result getTransactionNumber]]];
    [resultMsg appendString:[NSString stringWithFormat:@"    PaymentCondition:%@\n", [self getPaymentConditionText:[result getPaymentCondition]]]];
    [resultMsg appendString:[NSString stringWithFormat:@"    VoidSlipNumber:%@\n", [result getVoidSlipNumber]]];
    [resultMsg appendString:[NSString stringWithFormat:@"    Balance:%ld\n", [result getBalance]]];
    [resultMsg appendString:[NSString stringWithFormat:@"    TransactionType:%@\n", [result getTransactionType]]];
    [resultMsg appendString:[NSString stringWithFormat:@"    AdditionalSecurityInformation:%@\n", [result getAdditionalSecurityInformation]]];
    
    return resultMsg;
}

- (void)onSelectPickerItem:(NSInteger)position obj:(id)obj
{
    if (obj == serviceList_) {
        [_buttonService setTitle:[serviceList_ getItem:position] forState:UIControlStateNormal];
        switch ((int)serviceList_.selectIndex) {
            case 0:
                service_ = EPOS2_SERVICE_CREDIT;
                break;
            case 1:
                service_ = EPOS2_SERVICE_DEBIT;
                break;
            case 2:
                service_ = EPOS2_SERVICE_UNIONPAY;
                break;
            case 3:
                service_ = EPOS2_SERVICE_EDY;
                break;
            case 4:
                service_ = EPOS2_SERVICE_ID;
                break;
            case 5:
                service_ = EPOS2_SERVICE_NANACO;
                break;
            case 6:
                service_ = EPOS2_SERVICE_QUICPAY;
                break;
            case 7:
                service_ = EPOS2_SERVICE_SUICA;
                break;
            case 8:
                service_ = EPOS2_SERVICE_WAON;
                break;
            case 9:
                service_ = EPOS2_SERVICE_POINT;
                break;
            case 10:
                service_ = EPOS2_SERVICE_NFCPAYMENT;
                break;
            case 11:
                service_ = EPOS2_SERVICE_PITAPA;
                break;
            case 12:
                service_ = EPOS2_SERVICE_FISC;
                break;
            case 13:
                service_ = EPOS2_SERVICE_QR;
                break;
            case 14:
                service_ = EPOS2_SERVICE_CREDIT_DEBIT;
                break;
            case 15:
                service_ = EPOS2_SERVICE_MULTI;
                break;
            default:
                break;
        }
    } else if (obj == authorizeList_) {
        [_buttonAuthorize setTitle:[authorizeList_ getItem:position] forState:UIControlStateNormal];
        authorize_ = (int)authorizeList_.selectIndex;
    }
    else {
        ; //do nothing
    }
}

- (IBAction)clearCAT:(id)sender
{
    self.textCAT.text = @"";
}
@end
