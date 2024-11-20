#import <Foundation/Foundation.h>
#import "FirmWareUpdateViewController.h"

@interface FirmWareUpdateViewController() <SelectPickerTableDelegate, SDKDelegate>
@end

@implementation FirmWareUpdateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Initialize restart message view
    [self initializeNotesMessage];
    [self hideWaitingMessage];

    // Initialize utils
    [self initFirmwareListPickerTable];

    _textFWUpdate.editable = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setDoneToolbar];
    _textFWUpdate.text = @"";
    _buttonGetPrinterFirmware.enabled = NO;
    _buttonDownloadFirmwareList.enabled = NO;
    _buttonUpdateFirmware.enabled = NO;
    _buttonFirmwareList.enabled = NO;

    //check POS terminal model connection
    NSRange range = [targetPrn_ rangeOfString:@"["];
    if (range.location != NSNotFound) {
        // Back connection setting view due to POS terminal model is not supported.
        _textFWUpdate.text = [_textFWUpdate.text stringByAppendingString:[NSString stringWithFormat:NSLocalizedString(@"error_msg_firm_update", @"")]];
    } else {
        ePOS2SDKManager = [[EPOS2SDKManager alloc] init];
        ePOS2SDKManager.delegate = self;

        queueForSDK = [[NSOperationQueue alloc] init];
        queueForSDK.maxConcurrentOperationCount = 1;

        [queueForSDK addOperationWithBlock:^{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self beginProcess];
            }];

            if([ePOS2SDKManager initializePrinterObject:printerSeries_]) {
                if([ePOS2SDKManager connectPrinter:targetPrn_]) {
                    printerModel_ = NSLocalizedString(@"printermodel_m30", @"");

                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        _buttonGetPrinterFirmware.enabled = YES;
                        _buttonDownloadFirmwareList.enabled = YES;
                    }];
                }
            }

            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self endProcess];
            }];
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    _textFWUpdate.text = @"";
    _labelGetPrinterFirmware.text = @"-";
    _buttonGetPrinterFirmware.enabled = NO;
    _buttonDownloadFirmwareList.enabled = NO;
    _buttonUpdateFirmware.enabled = NO;

    [queueForSDK addOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self beginProcess];
        }];

        ePOS2SDKManager.delegate = nil;
        [ePOS2SDKManager disconnectPrinter];
        [ePOS2SDKManager finalizePrinterObject];
        ePOS2SDKManager = nil;

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self endProcess];
        }];
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
    _textTargetPrinterModel.inputAccessoryView = doneToolbar;
    _textTargetOption.inputAccessoryView = doneToolbar;
}

- (void)doneKeyboard:(id)sender
{
    [_textTargetPrinterModel resignFirstResponder];
    [_textTargetOption resignFirstResponder];
}



- (void)hideWaitingMessage {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_viewWatingUpdate setHidden:YES];
        [_labelWatingMessage setHidden:YES];
        [_noteMessage setHidden:YES];
        [self.view setNeedsDisplay];
    }];

}

// Firmware Updating Message
- (void)showWaitingMessage {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_viewWatingUpdate setHidden:NO];
        [_labelWatingMessage setHidden:NO];
        [_noteMessage setHidden:NO];
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

- (void)initFirmwareListPickerTable
{
    firmwareInfoList_ = [[NSMutableArray alloc] init];
    firmwareList_ = [[PickerTableView alloc] init];
    firmwareList_.delegate = self;
}
- (IBAction)eventButtonDidPush:(id)sender
{
    switch (((UIView *)sender).tag) {
        case 1:
            //get firmversion
            [self getPrinterFirmware];
            break;
        case 2:
            //download firm
            [self downloadFirmwareList];
            break;
        case 3:
            // select download firmlist
            [firmwareList_ show];
            break;
        case 4:
            //update firm
            [self updateFirmware];
            break;
        default:
            break;
    }
}

- (void)onSelectPickerItem:(NSInteger)position obj:(id)obj
{
    if (obj == firmwareList_) {
        Epos2FirmwareInfo* firmInfo = [firmwareInfoList_ objectAtIndex:position];
        [_buttonFirmwareList setTitle:[firmInfo getVersion] forState:UIControlStateNormal];
        targetFirmwareInfo_ = firmInfo;
    }
    else {
        ; //do nothing
    }
}

- (BOOL)getPrinterFirmware
{
    [queueForSDK addOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self beginProcess];
        }];

        if(![ePOS2SDKManager getPrinterFirmwareInfo:EPOS2_PARAM_DEFAULT]) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self endProcess];
            }];
        }
    }];

    return YES;
}

- (BOOL)downloadFirmwareList
{
    NSString *printerModel =_textTargetPrinterModel.text;
    NSString *option =_textTargetOption.text;
    [queueForSDK addOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self beginProcess];
        }];

        if(![ePOS2SDKManager downloadFirmwareList:printerModel option:option]) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self endProcess];
            }];
        }
    }];

    return YES;
}

- (BOOL)updateFirmware
{
    [queueForSDK addOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self showWaitingMessage];
        }];

        if(![ePOS2SDKManager updateFirmware:targetFirmwareInfo_]) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self hideWaitingMessage];
            }];
        }
    }];

    return YES;
}

- (void)onFirmwareInformationReceiveEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager code:(int)code firmwareInfo:(Epos2FirmwareInfo *)firmwareInfo
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _labelGetPrinterFirmware.text = [firmwareInfo getVersion];
        [self endProcess];
    }];
}

- (void)onFirmwareListDownloadEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager code:(int)code firmwareList:(NSMutableArray<Epos2FirmwareInfo *> *)firmwareList
{
    [queueForSDK addOperationWithBlock:^{
        if(firmwareList == nil){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self endProcess];
            }];
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

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_buttonFirmwareList setTitle:[firmwareVersionList objectAtIndex:0] forState:UIControlStateNormal];
            _buttonFirmwareList.enabled = YES;
            _buttonUpdateFirmware.enabled = YES;
            [self endProcess];
        }];
    }];
}

- (void)onFirmwareUpdateEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager code:(int)code maxWaitTime:(int)maxWaitTime
{
    [queueForSDK addOperationWithBlock:^{
        if(code != EPOS2_CODE_SUCCESS) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self hideWaitingMessage];
            }];
            return;
        }

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self updateWaitingMessage:NSLocalizedString(@"reconnect_message", @"") progress:@"" blink:YES];
        }];

        [ePOS2SDKManager disconnectPrinter];

        [NSThread sleepForTimeInterval:maxWaitTime];
        if(![ePOS2SDKManager connectPrinter:targetPrn_]) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self hideWaitingMessage];
            }];
            return;
        }

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self updateWaitingMessage:NSLocalizedString(@"verify_message", @"") progress:@"" blink:NO];
        }];

        // Verify firmware version.
        [ePOS2SDKManager verifyUpdate:targetFirmwareInfo_];

    }];
}

- (void)onFirmwareUpdateProgressEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager task:(NSString *)task progress:(float)progress
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString* progressStr = [NSString stringWithFormat:@"%.1f%%", progress*100];
        [self updateWaitingMessage:task progress:progressStr blink:NO];
    }];
}

- (void)onUpdateVerifyEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager code:(int)code
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self hideWaitingMessage];
    }];
}

- (void)onLogEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager apiLog:(NSString *)apiLog
{
    if(apiLog !=nil){
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            _textFWUpdate.text = [_textFWUpdate.text stringByAppendingString:apiLog];
            [self scrollText:_textFWUpdate];
        }];
    }
}

@end
