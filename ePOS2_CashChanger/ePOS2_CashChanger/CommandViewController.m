#import "CommandViewController.h"
#import "ShowMsg.h"

@interface CommandViewController()<Epos2CChangerCommandReplyDelegate, Epos2CChangerDirectIOCommandReplyDelegate>
@end

@implementation CommandViewController

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
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneCashChanger:)];
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects:space, doneButton, nil];
    [doneToolbar setItems:items animated:YES];
    _textCommandData.inputAccessoryView = doneToolbar;
    _textDirectIOCommand.inputAccessoryView = doneToolbar;
    _textDirectIOData.inputAccessoryView = doneToolbar;
    _textDirectIOString.inputAccessoryView = doneToolbar;
}

- (void)doneCashChanger:(id)sender
{
    [_textCommandData resignFirstResponder];
    [_textDirectIOCommand resignFirstResponder];
    [_textDirectIOData resignFirstResponder];
    [_textDirectIOString resignFirstResponder];
}

- (void)setEventDelegate
{
    [super setEventDelegate];
    
    if(cchanger_) {
        [cchanger_ setCommandReplyEventDelegate:self];
        [cchanger_ setDirectIOCommandReplyEventDelegate:self];
    }
}

- (void)releaseEventDelegate
{
    [super releaseEventDelegate];
    
    if(cchanger_) {
        [cchanger_ setCommandReplyEventDelegate:nil];
        [cchanger_ setDirectIOCommandReplyEventDelegate:nil];
    }
}

- (IBAction)onSendCommand:(id)sender {
    NSUInteger index = 0;
    NSUInteger inputIndex = 0;
    NSUInteger enableIndex = 0;
    NSString *stringNumber = @"";
    NSString *newText = @"";
    NSString *CR = @"\n";
    unsigned char enableNumber[] = {0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39,
        0x41, 0x42, 0x43, 0x44, 0x45, 0x46,
        0x61, 0x62, 0x63, 0x64, 0x65, 0x66
    };
    unsigned char *sendData = nil;
    const char *utf8Data = _textCommandData.text.UTF8String;
    
    if (cchanger_ == nil) {
        return;
    }
    
    for (index = 0; index <  _textCommandData.text.length; index++) {
        BOOL isNumber = NO;
        for (enableIndex = 0; enableIndex < sizeof(enableNumber); enableIndex++) {
            if (enableNumber[enableIndex] == utf8Data[index]) {
                isNumber = YES;
                stringNumber = [stringNumber stringByAppendingString:[NSString stringWithFormat:@"%c", utf8Data[index]]];
                break;
            }
        }
        
        if ((utf8Data[index] == 0x0A) || (utf8Data[index] == 0x20) || !isNumber || stringNumber.length == 2 || (index == _textCommandData.text.length - 1)) {
            if (stringNumber.length) {
                if (stringNumber.length == 1) {
                    newText = [newText stringByAppendingString:@"0"];
                }
                newText = [newText stringByAppendingString:stringNumber];
            }
            
            if (utf8Data[index] != 0x20 && !isNumber) {
                newText = [newText stringByAppendingString:[NSString stringWithFormat:@"%02X", utf8Data[index]]];
            }
            stringNumber = @"";
        }
    }
    
    sendData = (unsigned char *)malloc(newText.length / 2);
    
    _textCommandData.text = @"";
    
    for (index = 0; index <  newText.length / 2; index++) {
        unsigned int hexBin = 0;
        NSString *stringHex = [newText substringWithRange:NSMakeRange(index * 2, 2)];
        
        [[NSScanner scannerWithString:stringHex] scanHexInt:&hexBin];
        if (hexBin == 0x0A) {
            _textCommandData.text = [_textCommandData.text stringByAppendingString:CR];
        }
        else {
            _textCommandData.text = [_textCommandData.text stringByAppendingString:[NSString stringWithFormat:@"%02X ", hexBin]];
        }
        
        sendData[inputIndex] = (unsigned char)hexBin;
        inputIndex++;
    }
    
    if (sendData) {
        NSData *data = [NSData dataWithBytes:sendData length:inputIndex];
        
        int result = [cchanger_ sendCommand:data];
        if (EPOS2_SUCCESS != result) {
            [ShowMsg showErrorEpos:result method:@"sendCommand"];
        }
        
        free(sendData);
        sendData = nil;
    }
}

- (IBAction)onSendDirectIOCommand:(id)sender {
    int result = EPOS2_SUCCESS;
    long command = [_textDirectIOCommand.text intValue];
    long data = [_textDirectIOData.text intValue];
    
    if(cchanger_ == nil) {
        return;
    }
    
    [cchanger_ sendDirectIOCommand:command data:data string:_textDirectIOString.text];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"sendDirectIOCommand"];
        return;
    }
}

- (void) onCChangerCommandReply:(Epos2CashChanger *)cchangerObj code:(int)code data:(NSData *)data
{
    NSUInteger dataIndex = 0;
    NSUInteger dataLength = data.length;
    const char *dataBytes = (char *)data.bytes;
    
    [ShowMsg showResult:code];
    
    self.textCashChanger.text = [self.textCashChanger.text stringByAppendingString:[NSString stringWithFormat:@"OnCommandReply:\n"]];
    
    for (dataIndex = 0; dataIndex < dataLength; dataIndex++) {
        self.textCashChanger.text = [self.textCashChanger.text stringByAppendingString:[NSString stringWithFormat:@"%02X ", dataBytes[dataIndex]]];
    }
    self.textCashChanger.text = [self.textCashChanger.text stringByAppendingString:[NSString stringWithFormat:@"\n"]];
    [self scrollText];
}

- (void) onCChangerDirectIOCommandReply:(Epos2CashChanger *)cchangerObj code:(int)code command:(long)command data:(long)data string:(NSString *)string
{
    int oposCode = 0;
    if(code == EPOS2_CCHANGER_CODE_ERR_OPOSCODE) {
        oposCode = [cchangerObj getOposErrorCode];
        [ShowMsg showResult:code oposCode:oposCode];
    } else {
        [ShowMsg showResult:code];
    }
    
    self.textCashChanger.text = [self.textCashChanger.text stringByAppendingString:[NSString stringWithFormat:@"OnDirectIOCommandReply:\n"]];

    self.textCashChanger.text = [self.textCashChanger.text stringByAppendingString:[NSString stringWithFormat:@"  command:%ld\n", command]];
    self.textCashChanger.text = [self.textCashChanger.text stringByAppendingString:[NSString stringWithFormat:@"  data:%ld\n", data]];
    self.textCashChanger.text = [self.textCashChanger.text stringByAppendingString:[NSString stringWithFormat:@"  string:%@\n", string]];
    [self scrollText];
}

- (IBAction)clearCashChanger:(id)sender
{
    self.textCashChanger.text = @"";
}
@end
