#import "SimpleSerialViewController.h"
#import "ShowMsg.h"

@interface SimpleSerialViewController() <Epos2SimpleSerialReceiveDelegate, Epos2ConnectionDelegate>
@end

@implementation SimpleSerialViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        simpleSerial_ = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setDoneToolbar];

    _textSimpleSerial.text = @"";
    isConnect_ = NO;
}

- (void)setDoneToolbar
{
    //set multiline edit keyboard accessory
    UIToolbar *doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;

    [doneToolbar sizeToFit];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneKeyboard:)];

    NSMutableArray *items = [NSMutableArray arrayWithObjects:space, doneButton, nil];
    [doneToolbar setItems:items animated:YES];
    _textSendCommand.inputAccessoryView = doneToolbar;
    _textTarget.inputAccessoryView = doneToolbar;
}

- (void)doneKeyboard:(id)sender
{
    [_textTarget resignFirstResponder];
    [_textSendCommand resignFirstResponder];
}

- (IBAction)connectProcess:(id)sender
{
    if (![self initializeObject]) {
        return;
    }

    if (![self connectSimpleSerial]) {
        return;
    }

    _buttonConnect.enabled = NO;
}

- (IBAction)disconnectProcess:(id)sender
{
    [self disconnectSimpleSerial];

    [self finalizeObject];

    _buttonConnect.enabled = YES;
}

- (BOOL)initializeObject
{
    if (simpleSerial_ != nil) {
        [self finalizeObject];
    }

    simpleSerial_ = [[Epos2SimpleSerial alloc] init];
    if (simpleSerial_ == nil) {
        [ShowMsg showErrorEpos:EPOS2_ERR_MEMORY method:@"init"];
        return NO;
    }

    [simpleSerial_ setReceiveEventDelegate:self];
    [simpleSerial_ setConnectionEventDelegate:self];

    return YES;
}

- (void)finalizeObject
{
    if (simpleSerial_ == nil) {
        return;
    }

    [simpleSerial_ setReceiveEventDelegate:nil];
    [simpleSerial_ setConnectionEventDelegate:nil];

    simpleSerial_ = nil;
}

- (BOOL)connectSimpleSerial
{
    int result = EPOS2_SUCCESS;

    if (simpleSerial_ == nil) {
        return NO;
    }

    result = [simpleSerial_ connect:_textTarget.text timeout:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"connect"];
        [self finalizeObject];
        return NO;
    }
    isConnect_ = YES;

    return YES;
}

- (void)disconnectSimpleSerial
{
    int result = EPOS2_SUCCESS;

    if (nil == simpleSerial_) {
        return;
    }

    if(isConnect_ == YES) {
        result = [simpleSerial_ disconnect];
        if (result != EPOS2_SUCCESS) {
            isConnect_ = NO;
            
            [ShowMsg showErrorEpos:result method:@"disconnect"];
        }
    }
    else {
        return ;
    }
}

- (void) onSimpleSerialReceive:(Epos2SimpleSerial *)serialObj data:(NSData *)data
{
    NSUInteger dataIndex = 0;
    NSUInteger dataLength = data.length;
    const char *dataBytes = (char *)data.bytes;

    for (dataIndex = 0; dataIndex < dataLength; dataIndex++) {

        _textSimpleSerial.text = [_textSimpleSerial.text stringByAppendingString:[NSString stringWithFormat:@"%02X ", dataBytes[dataIndex]]];

    }

    [self scrollText];
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

- (IBAction)clearSimpleSerial:(id)sender
{
    _textSimpleSerial.text = @"";
}

- (IBAction)onSendCommand:(id)sender
{
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
    const char *utf8Data = _textSendCommand.text.UTF8String;

    if (simpleSerial_ == nil) {
        return;
    }

    for (index = 0; index <  _textSendCommand.text.length; index++) {
        BOOL isNumber = NO;
        for (enableIndex = 0; enableIndex < sizeof(enableNumber); enableIndex++) {
            if (enableNumber[enableIndex] == utf8Data[index]) {
                isNumber = YES;
                stringNumber = [stringNumber stringByAppendingString:[NSString stringWithFormat:@"%c", utf8Data[index]]];
                break;
            }
        }

        if ((utf8Data[index] == 0x0A) || (utf8Data[index] == 0x20) || !isNumber || stringNumber.length == 2 || (index == _textSendCommand.text.length - 1)) {
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

    _textSendCommand.text = @"";

    for (index = 0; index <  newText.length / 2; index++) {
        unsigned int hexBin = 0;
        NSString *stringHex = [newText substringWithRange:NSMakeRange(index * 2, 2)];

        [[NSScanner scannerWithString:stringHex] scanHexInt:&hexBin];
        if (hexBin == 0x0A) {
            _textSendCommand.text = [_textSendCommand.text stringByAppendingString:CR];
        }
        else {
            _textSendCommand.text = [_textSendCommand.text stringByAppendingString:[NSString stringWithFormat:@"%02X ", hexBin]];
        }

        sendData[inputIndex] = (unsigned char)hexBin;
        inputIndex++;
    }

    if (sendData) {
        NSData *data = [NSData dataWithBytes:sendData length:inputIndex];

        int result = [simpleSerial_ sendCommand:data];
        if (EPOS2_SUCCESS != result) {
            [ShowMsg showErrorEpos:result method:@"sendCommand"];
        }

        free(sendData);
        sendData = nil;
    }
}

- (void)scrollText
{
    NSRange range;
    range = _textSimpleSerial.selectedRange;
    range.location = _textSimpleSerial.text.length;
    _textSimpleSerial.selectedRange = range;
    _textSimpleSerial.scrollEnabled = YES;

    CGFloat scrollY = _textSimpleSerial.contentSize.height + _textSimpleSerial.font.pointSize - _textSimpleSerial.bounds.size.height;
    CGPoint scrollPoint;

    if (scrollY < 0) {
        scrollY = 0;
    }

    scrollPoint = CGPointMake(0.0, scrollY);

    [_textSimpleSerial setContentOffset:scrollPoint animated:YES];
}

@end
