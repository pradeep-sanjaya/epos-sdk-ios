#import <Foundation/Foundation.h>
#import "FirmWareUpdateViewController.h"
#import "ShowMsg.h"

#define DISCONNECT_INTERVAL                  0.5

@interface FirmWareUpdateViewController() <SelectPickerTableDelegate, Epos2FirmwareListDownloadDelegate, Epos2FirmwareInformationDelegate, Epos2FirmwareUpdateDelegate, Epos2VerifyeUpdateDelegate>
@end

@implementation FirmWareUpdateViewController

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
    
    // Initialize restart message view
    [self initializeNotesMessage];
    [self hideIndicator];
    [self hideWaitingMessage];
    
    // Initialize utils
    [self initFirmwareListPickerTable];
    
    [self setDoneToolbar];
    
    [self updateButtonState:NO];
    _buttonUpdateFirmware.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //check POS terminal model connection
    NSRange range = [printerInfo_.target rangeOfString:@"["];
    if (range.location != NSNotFound) {
        // Back connection setting view due to POS terminal model is not supported.
        [ShowMsg showErrorEpos:EPOS2_ERR_PARAM method:NSLocalizedString(@"error_msg_firm_update", @"")];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (![self initializeObject]) {
        // Back connection setting view when fail to create instance.
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    _labelGetPrinterFirmware.text = @"-";
    [self updateButtonState:NO];
    _buttonFirmwareList.enabled = NO;
    _buttonUpdateFirmware.enabled = NO;
    
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
        _buttonGetPrinterFirmware.enabled = state;
        _buttonDownloadFirmwareList.enabled = state;
    }];
}

- (void)initializeNotesMessage {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString *ss = @"";
        ss = [ss stringByAppendingString:[NSString stringWithFormat:@"1. %@", NSLocalizedString(@"note1_1", "")]];
        ss = [ss stringByAppendingString:@"\n"];
        ss = [ss stringByAppendingString:[NSString stringWithFormat:@"   %@", NSLocalizedString(@"note1_2", "")]];
        ss = [ss stringByAppendingString:@"\n"];
        
        ss = [ss stringByAppendingString:[NSString stringWithFormat:@"   %@", NSLocalizedString(@"note1_3", "")]];
        ss = [ss stringByAppendingString:@"\n\n"];
        
        ss = [ss stringByAppendingString:[NSString stringWithFormat:@"2. %@", NSLocalizedString(@"note2", "")]];
        ss = [ss stringByAppendingString:@"\n\n"];
        
        ss = [ss stringByAppendingString:[NSString stringWithFormat:@"3. %@", NSLocalizedString(@"note3", "")]];
        ss = [ss stringByAppendingString:@"\n\n"];
        
        ss = [ss stringByAppendingString:[NSString stringWithFormat:@"4. %@", NSLocalizedString(@"note4", "")]];
        ss = [ss stringByAppendingString:@"\n\n"];
        
        ss = [ss stringByAppendingString:[NSString stringWithFormat:@"5. %@", NSLocalizedString(@"note5", "")]];
        ss = [ss stringByAppendingString:@"\n\n"];
        
        ss = [ss stringByAppendingString:[NSString stringWithFormat:@"6. %@", NSLocalizedString(@"note6", "")]];
        ss = [ss stringByAppendingString:@"\n\n"];
        
        ss = [ss stringByAppendingString:[NSString stringWithFormat:@"7. %@", NSLocalizedString(@"note7", "")]];
        ss = [ss stringByAppendingString:@"\n\n"];
        
        ss = [ss stringByAppendingString:[NSString stringWithFormat:@"8. %@", NSLocalizedString(@"note8", "")]];
        ss = [ss stringByAppendingString:@"\n\n"];
        
        ss = [ss stringByAppendingString:[NSString stringWithFormat:@"9. %@", NSLocalizedString(@"note9", "")]];
        ss = [ss stringByAppendingString:@"\n\n"];
        
        NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:ss];
        [as addAttribute:NSForegroundColorAttributeName
                   value:[UIColor redColor]
                   range:NSMakeRange(0, ss.length)];
        [as addAttribute:NSFontAttributeName
                   value:[UIFont systemFontOfSize:15.f]
                   range:NSMakeRange(0, ss.length)];
        [as addAttribute:NSUnderlineStyleAttributeName
                   value:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
                   range:NSMakeRange(0, ss.length)];
        _noteMessage.attributedText = as;
    }];
}

// Picker to select setting
- (void)initFirmwareListPickerTable {
    firmwareInfoList_ = [[NSMutableArray alloc] init];
    firmwareList_ = [[PickerTableView alloc] init];
    firmwareList_.delegate = self;
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
    _textTargetPrinterModel.inputAccessoryView = doneToolbar;
    _textTargetOption.inputAccessoryView = doneToolbar;
}

- (void)doneKeyboard:(id)sender
{
    [_textTargetPrinterModel resignFirstResponder];
    [_textTargetOption resignFirstResponder];
}

- (IBAction)eventButtonDidPush:(id)sender {
    switch (((UIView *)sender).tag) {
        case 1:
            //get firmversion
            [self getPrinterFirmware];
            break;

        case 2: {
            //download firm
            [self downloadFirmwareList];
            break;
        }
        case 3: {
            //select download firmlist
            [firmwareList_ show];
            break;
        }
        case 4: {
            //update firm
            [self updateFirmware];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)onSelectPickerItem:(NSInteger)position obj:(id)obj {
    if (obj == firmwareList_) {
        Epos2FirmwareInfo* firmInfo = [firmwareInfoList_ objectAtIndex:position];
        [_buttonFirmwareList setTitle:[firmInfo getVersion] forState:UIControlStateNormal];
        targetFirmwareInfo_ = firmInfo;
    }
}

- (void)getPrinterFirmware {
    [self showIndicator:NSLocalizedString(@"wait", @"")];
    
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        //Note: This API must be used from background thread only
        int result = [printer_ getPrinterFirmwareInfo:60000 delegate:self];
        if(result != EPOS2_SUCCESS){
            [self hideIndicator];
            [ShowMsg showErrorEpos:result method:@"getPrinterFirmware"];
        }
    }];
}

- (void)downloadFirmwareList {
    NSString *printerModel = _textTargetPrinterModel.text;
    NSString *option = _textTargetOption.text;
    
    [self showIndicator:NSLocalizedString(@"wait", @"")];
    
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        int result = [printer_ downloadFirmwareList:printerModel option:option delegate:self];
        if(result != EPOS2_SUCCESS){
            [self hideIndicator];
            [ShowMsg showErrorEpos:result method:@"downloadFirmwareList"];
        }
    }];
}

- (void)updateFirmware {
    if(targetFirmwareInfo_ == nil) {
        return;
    }
    
    [self showWaitingMessage];
    
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        int result = [printer_ updateFirmware:targetFirmwareInfo_ delegate:self];
        if(result != EPOS2_SUCCESS){
            [self hideWaitingMessage];
            [ShowMsg showErrorEpos:result method:@"updateFirmware"];
        }
    }];
}

- (void)verifyUpdate {
    if(targetFirmwareInfo_ == nil) {
        return;
    }
    
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        int result = [printer_ verifyUpdate:targetFirmwareInfo_ delegate:self];
        if(result != EPOS2_SUCCESS) {
            [self hideWaitingMessage];
            [ShowMsg showErrorEpos:result method:@"verifyUpdate"];
        }
    }];
}

- (void)onFirmwareInformationReceive:(int)code firmwareInfo:(Epos2FirmwareInfo *)firmwareInfo {
    if(code != EPOS2_CODE_SUCCESS){
        [self hideIndicator];
        [ShowMsg showErrorEposCode:code method:@"onFirmwareInformationReceive"];
        return;
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _labelGetPrinterFirmware.text = [firmwareInfo getVersion];
    }];
    
    [self hideIndicator];
}

- (void)onFirmwareListDownload:(int)code firmwareList:(NSMutableArray<Epos2FirmwareInfo *> *)firmwareList {
    if(code != EPOS2_CODE_SUCCESS){
        [self hideIndicator];
        [ShowMsg showErrorEposCode:code method:@"onFirmwareListDownload"];
        return;
    }
    
    if(firmwareList == nil) {
        [self hideIndicator];
        return;
    }
    
    [firmwareInfoList_ removeAllObjects];
    
    NSMutableArray<NSString *> *firmwareVersionList = [[NSMutableArray alloc] init];
    int firmwareListCount = (int)[firmwareList count];
    for(int i=0; i<firmwareListCount; i++) {
        Epos2FirmwareInfo* firmwareInfo = [firmwareList objectAtIndex:i];
        [firmwareInfoList_ addObject:firmwareInfo];
        [firmwareVersionList addObject:[firmwareInfo getVersion]];
    }
    
    [firmwareList_ setItemList:firmwareVersionList];
    targetFirmwareInfo_ = [firmwareList objectAtIndex:0];
    
    [_buttonFirmwareList setTitle:[firmwareVersionList objectAtIndex:0] forState:UIControlStateNormal];
    _buttonFirmwareList.enabled = YES;
    _buttonUpdateFirmware.enabled = YES;
    [self hideIndicator];
}

- (void)onFirmwareUpdateProgress:(NSString *)task progress:(float)progress{
    NSString* progressStr = [NSString stringWithFormat:@"%.1f%%", progress*100];
    [self updateWaitingMessage:task progress:progressStr blink:NO];
}

- (void)onFirmwareUpdate:(int)code maxWaitTime:(int)maxWaitTime {
    if(code != EPOS2_CODE_SUCCESS) {
        [ShowMsg showErrorEposCode:code method:@"onFirmwareUpdate"];
        [self hideWaitingMessage];
        return;
    }
    
    [self updateWaitingMessage:NSLocalizedString(@"reconnect_message", @"") progress:@"" blink:YES];
    
    [self disconnectPrinter];
    
    // Reconnect Printer.
    [NSThread sleepForTimeInterval:maxWaitTime];
    if(![self connectPrinter]){
        [self hideWaitingMessage];
        return;
    }
    
    [self updateWaitingMessage:NSLocalizedString(@"verify_message", @"") progress:@"" blink:NO];
    
    [self verifyUpdate];
}

- (void)onUpdateVerify:(int)code {
    [self hideWaitingMessage];
    [ShowMsg showErrorEposCode:code method:@"onUpdateVerify"];
}

// Printer control
- (BOOL)initializeObject {
    printer_ = [[Epos2Printer alloc] initWithPrinterSeries:printerInfo_.printerSeries lang:printerInfo_.lang];
    if (printer_ == nil) {
        [ShowMsg showErrorEpos:EPOS2_ERR_PARAM method:@"initiWithPrinterSeries"];
        return NO;
    }
    
    return YES;
}

- (void)finalizeObject {
    if (printer_ == nil) {
        return;
    }
    
    printer_ = nil;
}

-(BOOL)connectPrinter {
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

- (void)disconnectPrinter {
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

// View control

- (void)showWaitingMessage {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_navigationItem setHidesBackButton:YES animated:NO];
        [_viewWatingUpdate setHidden:NO];
        [_labelWatingMessage setHidden:NO];
        [_labelWaitingProgress setHidden:NO];
        [_noteMessage setHidden:NO];
        [self.view setNeedsDisplay];
    }];
}

- (void)hideWaitingMessage {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_navigationItem setHidesBackButton:NO animated:NO];
        [_viewWatingUpdate setHidden:YES];
        [_labelWatingMessage setHidden:YES];
        [_labelWaitingProgress setHidden:YES];
        [_noteMessage setHidden:YES];
        [self.view setNeedsDisplay];
    }];
}

- (void)updateWaitingMessage:(NSString *)message progress:(NSString*)progress blink:(BOOL)blink {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _labelWatingMessage.text = message;
        _labelWaitingProgress.text = progress;
        if(blink) {
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat
                             animations:^{_labelWatingMessage.alpha = 0;}
                             completion:^(BOOL finished){_labelWatingMessage.alpha = 0;}];
        } else {
            [UIView animateWithDuration:0.001
                             animations:^{_labelWatingMessage.alpha = 1.0;}];
        }
    }];
}
@end
