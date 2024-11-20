#import "PrinterSettingExViewController.h"
#import "ShowMsg.h"

#define KEY_SETTING                 @"PrinterSpec"
#define KEY_PRODUCT                 @"Product"
#define KEY_SERIALNO                @"SerialNo"
#define DISCONNECT_INTERVAL 0.5
#define RESTART_INTERVAL 60

@interface PrinterSettingExViewController () <Epos2PrinterGetPrinterSettingExDelegate, Epos2PrinterSetPrinterSettingExDelegate,Epos2PrinterVerifyPasswordDelegate>

@end

@implementation PrinterSettingExViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        printer_ = nil;
        printerInfo_ = [PrinterInfo sharedPrinterInfo];
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setDoneToolbar];
    [self updateButtonState:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _buttonGetPrinterSettingEx.enabled = NO;
    _buttonSetPrinterSettingEx.enabled = NO;
    
    // check POS terminal model connection
    NSRange range = [printerInfo_.target rangeOfString:@"["];
    if(range.location != NSNotFound) {
        [ShowMsg showErrorEpos:EPOS2_ERR_PARAM method:NSLocalizedString(@"error_msg_firm_update", @"")];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if(![self initializeObject]){
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [self showIndicator:NSLocalizedString(@"wait", @"")];
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        if([self connectPrinter]){
            [self updateButtonState:YES];
        }
        [self hideIndicator];
    }];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self showIndicator:NSLocalizedString(@"wait", @"")];
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        [self disconnectPrinter];
        [self finalizeObject];
        [self hideIndicator];
    }];
}
- (void)updateButtonState:(BOOL)state
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _buttonGetPrinterSettingEx.enabled = state;
        _buttonSetPrinterSettingEx.enabled = state;
    }];
}


- (void)setDoneToolbar
{
    UIToolbar *doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;

    [doneToolbar sizeToFit];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneKeyboard:)];

    NSMutableArray *items = [NSMutableArray arrayWithObjects:space, doneButton, nil];
    [doneToolbar setItems:items animated:YES];
    _textJson.inputAccessoryView = doneToolbar;
    _textPassword.inputAccessoryView = doneToolbar;
    
}

- (void)doneKeyboard:(id)sender
{
    [_textJson resignFirstResponder];
    [_textPassword resignFirstResponder];
}

- (IBAction)eventButtonDidPush:(id)sender {
    switch (((UIView*)sender).tag) {
        case 0:
            [self getPrinterSettingEx];
            break;
        case 1:
            [self verifyPasswordAndSetSetting];
            break;
        default:
            break;
    }
}
- (void)onVerifyPassword:(Epos2Printer *)printerObj code:(int)code
{
    [self hideIndicator];
    if((code != EPOS2_CODE_SUCCESS) && (code != EPOS2_CODE_NO_PASSWORD)) {
        [ShowMsg showErrorEposCode:code method:@"onVerifyPassword"];
        return;
    }
    NSString *password = _textPassword.text;
    if(code == EPOS2_CODE_NO_PASSWORD){
        password = nil;
    }
    
    [self setPrinterSettingEx:password];
}

- (void)onSetPrinterSettingEx:(Epos2Printer *)printerObj code:(int)code
{
    if(code != EPOS2_CODE_SUCCESS) {
        [self hideIndicator];
        [ShowMsg showErrorEposCode:code method:@"onSetPrinterSettingEx"];
        return;
    }
    _textJson.text = @"";
    
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        [self reconnectPrinter_And_GetPrinterSetting];
    }];
}

- (void)onGetPrinterSettingEx:(Epos2Printer *)printerObj code:(int)code jsonString:(NSString *)jsonString
{
    [self hideIndicator];
    if(code != EPOS2_CODE_SUCCESS) {
        [ShowMsg showErrorEposCode:code method:@"onGetPrinterSettingEx"];
        return;
    }
    
    if(jsonString != nil) {
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        if(data != nil) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSError * err;
            if(json != nil) {
                NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&err];
                if(jsonData != nil) {
                    NSString * viewJsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    _textJson.text = viewJsonString;
                }
                if(updatePassword_){
                    NSString *serialNumber = json[KEY_SETTING][KEY_PRODUCT][KEY_SERIALNO];
                    _textPassword.text = serialNumber;
                }
            }
        }
    }
}


- (BOOL)initializeObject
{
    printer_ = [[Epos2Printer alloc] initWithPrinterSeries:printerInfo_.printerSeries lang:printerInfo_.lang];

    if (printer_ == nil) {
        [ShowMsg showErrorEpos:EPOS2_ERR_PARAM method:@"initiWithPrinterSeries"];
        return NO;
    }
    
    [printer_ setGetPrinterSettingExDelegate:self];
    [printer_ setVerifyPasswordDelegate:self];
    [printer_ setSetPrinterSettingExDelegate:self];
    
    return YES;
}

- (void)finalizeObject
{
    if (printer_ == nil) {
        return;
    }

    [printer_ setGetPrinterSettingExDelegate:nil];
    [printer_ setVerifyPasswordDelegate:nil];
    [printer_ setSetPrinterSettingExDelegate:nil];

    printer_ = nil;
}

-(BOOL)connectPrinter
{
    int result = EPOS2_SUCCESS;

    if (printer_ == nil) {
        return NO;
    }

    //Note: This API must be used from background thread only
    result = [printer_ connect:printerInfo_.target timeout:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"connect"];
        return NO;
    }

    return YES;
}

- (void)disconnectPrinter
{
    int result = EPOS2_SUCCESS;

    if (printer_ == nil) {
        return;
    }

    //Note: This API must be used from background thread only
    result = [printer_ disconnect];
    int count = 0;
    //Note: Check if the process overlaps with another process in time.
    while(result == EPOS2_ERR_PROCESSING && count < 4) {
        [NSThread sleepForTimeInterval:DISCONNECT_INTERVAL];
        result = [printer_ disconnect];
        count++;
    }
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"disconnect"];
    }
}

- (void)getPrinterSettingEx
{
    if(printer_ == nil) {
        return;
    }
    
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        updatePassword_ = YES;
        int result = [printer_ getPrinterSettingEx:EPOS2_PARAM_DEFAULT];
        if(result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"getPrinterSettingEx"];
        }else{
            [self showIndicator:NSLocalizedString(@"get_setting_ex_msg", @"")];
        }
    }];
    
}

- (void)verifyPasswordAndSetSetting
{
    if(printer_ == nil) {
        return;
    }
    
    NSString* password = _textPassword.text;
    
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        int result = [printer_ verifyPassword:EPOS2_PARAM_DEFAULT administratorPassword:password];
        if(result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"verifyPassword"];
        }else{
            // Show wating restart message. onVerifyPassword stop this message.
            [self showIndicator:NSLocalizedString(@"verify_password_msg", @"")];
        }
    }];
}
- (void)setPrinterSettingEx:(NSString *)password
{
    if(printer_ == nil) {
        return;
    }
    
    NSString* jsonString = _textJson.text;

    if(jsonString == nil) {
        return;
    }
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        int result = [printer_ setPrinterSettingEx:EPOS2_PARAM_DEFAULT jsonString:jsonString administratorPassword:password];
        if(result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"setPrinterSettingEx"];
        }else{
            // Show wating restart message. onSetPrinterSettingEx stop this message.
            [self showIndicator:NSLocalizedString(@"restart_msg", @"")];
        }
        
    }];
}

- (BOOL)reconnect:(int)maxWait Interval:(int)interval
{
    int timeout = 0;
    int result;
    do {
        //Note: This API must be used from background thread only
        result = [printer_ disconnect];
        if(result == EPOS2_SUCCESS) {
            break;
        }
        
        [NSThread sleepForTimeInterval:interval];
        timeout += interval;    // Not correct measuring. When result is not TIMEOUT, wraptime do not equal interval.
        
        if(timeout > maxWait) {
            return NO;
        }
    } while (true);
    
    // Sleep RESTART_INTERVAL sec due to some printer do not available immediately after power on. see your printer's spec sheet.
    // Please set the sleep time according to the printer.
    [NSThread sleepForTimeInterval:RESTART_INTERVAL];
    timeout += 30;
    
    do {
        // For USB, change the target to "USB:".
        // Because USB port changes each time the printer restarts.
        // Please refer to the manual for details.
        //Note: This API must be used from background thread only
        result = [printer_ connect:printerInfo_.target timeout:interval*1000];
        if(result == EPOS2_SUCCESS) {
            break;
        }
        
        [NSThread sleepForTimeInterval:interval];
        timeout += interval;
        
        if(timeout > maxWait) {
            return NO;
        }
    } while (true);
    
    return YES;
}

- (void)reconnectPrinter_And_GetPrinterSetting
{
    // Reconnect printer with 3 sec interval until 120 sec done.
    BOOL ret = [self reconnect:120 Interval:3];
    [self hideIndicator];
    
    // If error, back connection setting view to confirm connection setting.
    if(!ret) {
        [ShowMsg showErrorEpos:EPOS2_ERR_CONNECT method:@"reconnect"];
        return;
    }
    
    // When restart success, get current setting to confirmation.
    updatePassword_ = NO;
    int result = [printer_ getPrinterSettingEx:EPOS2_PARAM_DEFAULT];
    if(result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"getPrinterSettingEx"];
        return;
    }
    [self showIndicator:NSLocalizedString(@"get_setting_ex_msg", @"")];
    
    //Wait onGetPrinterSetting callback to avoid multiple API calling.
    [NSThread sleepForTimeInterval:0.2];
}

@end
