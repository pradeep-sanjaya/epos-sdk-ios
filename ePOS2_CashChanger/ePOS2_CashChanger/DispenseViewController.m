#import "DispenseViewController.h"
#import "ShowMsg.h"

@interface DispenseViewController()<Epos2CChangerDispenseDelegate>
@end

@implementation DispenseViewController

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

    _textCash.keyboardType = UIKeyboardTypeNumberPad;
    _textJpy1.keyboardType = UIKeyboardTypeNumberPad;
    _textJpy5.keyboardType = UIKeyboardTypeNumberPad;
    _textJpy10.keyboardType = UIKeyboardTypeNumberPad;
    _textJpy50.keyboardType = UIKeyboardTypeNumberPad;
    _textJpy100.keyboardType = UIKeyboardTypeNumberPad;
    _textJpy500.keyboardType = UIKeyboardTypeNumberPad;
    _textJpy1000.keyboardType = UIKeyboardTypeNumberPad;
    _textJpy2000.keyboardType = UIKeyboardTypeNumberPad;
    _textJpy5000.keyboardType = UIKeyboardTypeNumberPad;
    _textJpy10000.keyboardType = UIKeyboardTypeNumberPad;

    [self releaseEventDelegate];
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
    _textCash.inputAccessoryView = doneToolbar;
    _textJpy1.inputAccessoryView = doneToolbar;
    _textJpy5.inputAccessoryView = doneToolbar;
    _textJpy10.inputAccessoryView = doneToolbar;
    _textJpy50.inputAccessoryView = doneToolbar;
    _textJpy100.inputAccessoryView = doneToolbar;
    _textJpy500.inputAccessoryView = doneToolbar;
    _textJpy1000.inputAccessoryView = doneToolbar;
    _textJpy2000.inputAccessoryView = doneToolbar;
    _textJpy5000.inputAccessoryView = doneToolbar;
    _textJpy10000.inputAccessoryView = doneToolbar;
}

- (void)doneCashChanger:(id)sender
{
    [_textCash resignFirstResponder];
    [_textJpy1 resignFirstResponder];
    [_textJpy5 resignFirstResponder];
    [_textJpy10 resignFirstResponder];
    [_textJpy50 resignFirstResponder];
    [_textJpy100 resignFirstResponder];
    [_textJpy500 resignFirstResponder];
    [_textJpy1000 resignFirstResponder];
    [_textJpy2000 resignFirstResponder];
    [_textJpy5000 resignFirstResponder];
    [_textJpy10000 resignFirstResponder];
}

- (void)setEventDelegate
{
    [super setEventDelegate];
    
    if(cchanger_) {
        [cchanger_ setDispenseEventDelegate:self];
    }
}

- (void)releaseEventDelegate
{
    [super releaseEventDelegate];
    
    if(cchanger_) {
        [cchanger_ setDispenseEventDelegate:nil];
    }
}

- (IBAction)onDispenseChange:(id)sender {
    int result = EPOS2_SUCCESS;
    long cash = [_textCash.text  intValue];
    if(cchanger_ == nil) {
        return;
    }
    
    [cchanger_ dispenseChange:cash];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"dispenseChange"];
        return;
    }
}

- (IBAction)onDispenseCash:(id)sender {
    int result = EPOS2_SUCCESS;
    NSDictionary *dict = @{
        @"jpy1" : [NSNumber numberWithInteger:[_textJpy1.text integerValue]],
        @"jpy5" : [NSNumber numberWithInteger:[_textJpy5.text integerValue]],
        @"jpy10" : [NSNumber numberWithInteger:[_textJpy10.text integerValue]],
        @"jpy50" : [NSNumber numberWithInteger:[_textJpy50.text integerValue]],
        @"jpy100" : [NSNumber numberWithInteger:[_textJpy100.text integerValue]],
        @"jpy500" : [NSNumber numberWithInteger:[_textJpy500.text integerValue]],
        @"jpy1000" : [NSNumber numberWithInteger:[_textJpy1000.text integerValue]],
        @"jpy2000" : [NSNumber numberWithInteger:[_textJpy2000.text integerValue]],
        @"jpy5000" : [NSNumber numberWithInteger:[_textJpy5000.text integerValue]],
        @"jpy10000" : [NSNumber numberWithInteger:[_textJpy10000.text integerValue]]
    };
    
    if(cchanger_ == nil) {
        return;
    }
    
    [cchanger_ dispenseCash:dict];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"dispenseCash"];
        return;
    }
}

- (void) onCChangerDispense:(Epos2CashChanger *)cchangerObj code:(int)code
{
    int oposCode = 0;
    if(code == EPOS2_CCHANGER_CODE_ERR_OPOSCODE) {
        oposCode = [cchangerObj getOposErrorCode];
        [ShowMsg showResult:code oposCode:oposCode];
    } else {
        [ShowMsg showResult:code];
    }
}

- (IBAction)clearCashChanger:(id)sender
{
    self.textCashChanger.text = @"";
}
@end
