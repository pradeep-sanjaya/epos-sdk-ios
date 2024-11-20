#import "CommandViewController.h"
#import "ShowMsg.h"

@interface CommandViewController()<Epos2CATDirectIOCommandReplyDelegate, Epos2CATScanDataDelegate>
@end

@implementation CommandViewController

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
    [items addObject:NSLocalizedString(@"common", @"")];
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

    _textDirectIOCommand.keyboardType = UIKeyboardTypeNumberPad;
    _textDirectIOData.keyboardType = UIKeyboardTypeNumberPad;

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

- (void)setDoneToolbar
{
    UIToolbar *doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    
    [doneToolbar sizeToFit];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneCAT:)];
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects:space, doneButton, nil];
    [doneToolbar setItems:items animated:YES];
    _textDirectIOCommand.inputAccessoryView = doneToolbar;
    _textDirectIOData.inputAccessoryView = doneToolbar;
    _textDirectIOString.inputAccessoryView = doneToolbar;
    _textDirectIOAsi.inputAccessoryView = doneToolbar;
}

- (void)doneCAT:(id)sender
{
    [_textDirectIOCommand resignFirstResponder];
    [_textDirectIOData resignFirstResponder];
    [_textDirectIOString resignFirstResponder];
    [_textDirectIOAsi resignFirstResponder];
}

- (void)setEventDelegate
{
    [super setEventDelegate];
    
    if(cat_) {
        [cat_ setDirectIOCommandReplyEventDelegate:self];
        [cat_ setScanDataEventDelegate:self];
    }
}

- (void)releaseEventDelegate
{
    [super releaseEventDelegate];
    
    if(cat_) {
        [cat_ setDirectIOCommandReplyEventDelegate:nil];
        [cat_ setScanDataEventDelegate:nil];
    }
}

- (IBAction)eventButtonDidPush:(id)sender
{
    [serviceList_ show];
}

- (IBAction)onSendDirectIOCommand:(id)sender {
    int result = EPOS2_SUCCESS;
    long command = [_textDirectIOCommand.text intValue];
    long data = [_textDirectIOData.text intValue];
    NSString *asi = _textDirectIOAsi.text;
    
    if(cat_ == nil) {
        return;
    }
    
    [cat_ sendDirectIOCommand:command data:data string:_textDirectIOString.text service:service_ additionalSecurityInformation:asi];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"sendDirectIOCommand"];
        return;
    }
}

- (IBAction)onScanData:(id)sender {
    int result = EPOS2_SUCCESS;
    long command = [_textDirectIOCommand.text intValue];
    
    if(cat_ == nil) {
        return;
    }
    
    result = [cat_ scanData:command string:_textDirectIOString.text];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"scanData"];
        return;
    }
}

- (void) onCATDirectIOCommandReply:(Epos2CAT *)catObj code:(int)code command:(long)command data:(long)data string:(NSString *)string sequence:(long)sequence service:(int)service result:(Epos2CATDirectIOResult *)result
{
    int oposCode = 0;
    if(code == EPOS2_CAT_CODE_ERR_OPOSCODE) {
        oposCode = [catObj getOposErrorCode];
        [ShowMsg showResult:code oposCode:oposCode];
    } else {
        [ShowMsg showResult:code];
    }
    
    self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"OnCATDirectIOCommandReply:\n"]];
    self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  Command:%ld\n", command]];
    self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  Data:%ld\n", data]];
    self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  String:%@\n", string]];
    self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  Sequence:%ld\n", sequence]];
    self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  Service:%@\n", [self getCatServiceText:service]]];
    if(result != nil) {
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[self makeDirectIOResultMessage:result]];
    }
    [self scrollText];
}

- (void)onCATScanData:(Epos2CAT *)catObj code:(int)code additionalSecurityInformation:(NSString *)asi
{
    int oposCode = 0;
    if(code == EPOS2_CAT_CODE_ERR_OPOSCODE) {
        oposCode = [catObj getOposErrorCode];
        [ShowMsg showResult:code oposCode:oposCode];
    } else {
        [ShowMsg showResult:code];
    }
    if(asi != nil) {
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"OnCATScanData:\n"]];
        self.textCAT.text = [self.textCAT.text stringByAppendingString:[NSString stringWithFormat:@"  additionalSecurityInformation:%@\n", asi]];
    }
    
    [self scrollText];
}

- (NSString *) makeDirectIOResultMessage:(Epos2CATDirectIOResult *)result
{
    NSMutableString *resultMsg = [[NSMutableString alloc]initWithString:@""];

    [resultMsg appendString:[NSString stringWithFormat:@"  AccountNumber:%@\n", [result getAccountNumber]]];
    [resultMsg appendString:[NSString stringWithFormat:@"  SettledAmount:%ld\n", [result getSettledAmount]]];
    [resultMsg appendString:[NSString stringWithFormat:@"  SlipNumber:%@\n", [result getSlipNumber]]];
    [resultMsg appendString:[NSString stringWithFormat:@"  TransactionNumber:%@\n", [result getTransactionNumber]]];
    [resultMsg appendString:[NSString stringWithFormat:@"  PaymentCondition:%@\n", [self getPaymentConditionText:[result getPaymentCondition]]]];
    [resultMsg appendString:[NSString stringWithFormat:@"  Balance:%ld\n", [result getBalance]]];
    [resultMsg appendString:[NSString stringWithFormat:@"  AdditionalSecurityInformation:%@\n", [result getAdditionalSecurityInformation]]];
    
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
                service_ = EPOS2_SERVICE_COMMON;
                break;
            case 11:
                service_ = EPOS2_SERVICE_NFCPAYMENT;
                break;
            case 12:
                service_ = EPOS2_SERVICE_PITAPA;
                break;
            case 13:
                service_ = EPOS2_SERVICE_FISC;
                break;
            case 14:
                service_ = EPOS2_SERVICE_QR;
                break;
            case 15:
                service_ = EPOS2_SERVICE_CREDIT_DEBIT;
                break;
            case 16:
                service_ = EPOS2_SERVICE_MULTI;
                break;
            default:
                break;
        }
    }
}

- (IBAction)clearCAT:(id)sender
{
    self.textCAT.text = @"";
}
@end
