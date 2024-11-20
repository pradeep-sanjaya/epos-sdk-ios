#import "DMD70ViewController.h"
#import "UIViewController+Extension.h"
#import "ShowMsg.h"

#define KEY_RESULT                  @"Result"
#define KEY_METHOD                  @"Method"
#define BLINK_INTERVAL              1000

@interface DMD70ViewController() <Epos2DispReceiveDelegate>
@end

@implementation DMD70ViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        lineDisplay_ = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setDoneToolbar];
    
    int result = [Epos2Log setLogSettings:EPOS2_PERIOD_TEMPORARY output:EPOS2_OUTPUT_STORAGE ipAddress:nil port:0 logSize:50 logLevel:EPOS2_LOGLEVEL_LOW];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"setLogSettings"];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _buttonOrder.enabled = NO;
    _buttonCheck.enabled = NO;
    [self initializeObject];
    target_ = _textTarget.text;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self finalizeObject];
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
    _textTarget.inputAccessoryView = doneToolbar;
}

- (void)doneKeyboard:(id)sender
{
    [_textTarget resignFirstResponder];
    target_ =_textTarget.text;
}

- (IBAction)eventButtonDidPush:(id)sender
{
    NSInteger tag = ((UIView *)sender).tag;
    [self showIndicator:NSLocalizedString(@"wait", @"")];
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        switch (tag) {
            case 0:
                // Landscape Screen
                [self landscapeScreen];
                break;
            case 1:
                // Portrait Screen
                [self portraitScreen];
                break;
            case 2:
                // Register Image
                [self registerImage];
                break;
            case 3:
                // Order Demo
                [self orderDemo];
                break;
            case 4:
                // Check Demo
                [self checkDemo];
                break;
            case 5:
                // Start SlideShow
                [self startSlideShow];
                break;
            case 6:
                // Stop SlideShow
                [self stopSlideShow];
                break;
            default:
                break;
        }
        [self hideIndicator];
    }];
}

-(void)landscapeScreen{
    int result = EPOS2_SUCCESS;
    _bIsLandscape = YES;
    if (lineDisplay_ == nil) {
        return;
    }

    result = [lineDisplay_ addInitialize];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addInitialize"];
        return;
    }
    
    result = [lineDisplay_ addCreateScreenCustom:EPOS2_LANDSCAPE_LAYOUT_MODE_5 column:44 row:13];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addCreateScreenCustom"];
        return;
    }

    result = [lineDisplay_ addCreateTextArea:1 x:1 y:1 width:17 height:5 scrollMode:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addCreateTextArea"];
        return;
    }

    result = [lineDisplay_ addBackgroundColor:EPOS2_ALL_ROWS r:255 g:255 b:255];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addBackgroundColor"];
        return;
    }
    
    result = [lineDisplay_ addCreateTextArea:2 x:18 y:1 width:16 height:5 scrollMode:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addCreateTextArea"];
        return;
    }
    result = [lineDisplay_ addBackgroundColor:EPOS2_ALL_ROWS r:0 g:255 b:255];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addBackgroundColor"];
        return;
    }

    result = [lineDisplay_ addStartSlideShow:500];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addStartSlideShow"];
        return;
    }
    
    
    if (![self connectDisplay]) {
        return;
    }
    
    result = [lineDisplay_  sendData];
    if (result != EPOS2_SUCCESS) {
        [lineDisplay_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"sendData"];
        [self disconnectDisplay];
        return;
    }
}

-(void)portraitScreen{
    int result = EPOS2_SUCCESS;
    _bIsLandscape = NO;
    if (lineDisplay_ == nil) {
        return;
    }
    
    result = [lineDisplay_ addInitialize];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addInitialize"];
        return;
    }
    
    result = [lineDisplay_ addCreateScreenCustom:EPOS2_PORTRAIT_LAYOUT_MODE_3 column:22 row:19];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addCreateScreenCustom"];
        return;
    }
    
    result = [lineDisplay_ addCreateTextArea:1 x:1 y:1 width:20 height:3 scrollMode:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addCreateTextArea"];
        return;
    }
    
    result = [lineDisplay_ addBackgroundColor:EPOS2_ALL_ROWS r:0 g:255 b:255];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addBackgroundColor"];
        return;
    }
    
    result = [lineDisplay_ addCreateTextArea:2 x:1 y:4 width:20 height:5 scrollMode:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addCreateTextArea"];
        return;
    }
    
    result = [lineDisplay_ addBackgroundColor:EPOS2_ALL_ROWS r:255 g:255 b:255];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addBackgroundColor"];
        return;
    }
    
    result = [lineDisplay_ addStartSlideShow:500];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addStartSlideShow"];
        return;
    }
    
    if (![self connectDisplay]) {
        return;
    }
    
    result = [lineDisplay_  sendData];
    if (result != EPOS2_SUCCESS) {
        [lineDisplay_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"sendData"];
        [self disconnectDisplay];
        return;
    }
    return;
}

-(void)registerImage{
    int result = EPOS2_SUCCESS;
    if (lineDisplay_ == nil) {
        return;
    }
    
    result = [lineDisplay_ addRegisterDownloadImage:[self imgToNSData:@"ThankE800.png"] key1:65 key2:65];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addRegisterDownloadImage"];
        return;
    }
    
    result = [lineDisplay_ addRegisterDownloadImage:[self imgToNSData:@"ThankE.png"] key1:66 key2:66];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addRegisterDownloadImage"];
        return;
    }

    if (![self connectDisplay]) {
        return;
    }
    
    result = [lineDisplay_  sendData];
    if (result != EPOS2_SUCCESS) {
        [lineDisplay_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"sendData"];
        [self disconnectDisplay];
        return;
    }
    
    [self updateButtonState:YES];
    
    return;
}

-(void)orderDemo{
    
    int result = EPOS2_SUCCESS;
    NSString *text = @"";
    if (lineDisplay_ == nil) {
        return;
    }
    
    result = [lineDisplay_ addClearSymbol];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addClearSymbol"];
        return;
    }
    
    if(_bIsWorkingSlideshow == NO) {
        result = [lineDisplay_ addClearImage];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addClearImage"];
            return;
        }
        
        result = [lineDisplay_ addStartSlideShow:500];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addStartSlideShow"];
            return;
        }
    }
    
    
    if(_bIsLandscape) {
        result = [lineDisplay_ addSetCurrentTextArea:1];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addSetCurrentWindow"];
            return;
        }
        
        text = [text stringByAppendingString:@"Item:\n"];
        text = [text stringByAppendingString:@"  Cut & Sewn\n"];
        text = [text stringByAppendingString:@"U.PC.45.00->"];
        result = [lineDisplay_ addText:text x:EPOS2_PARAM_UNUSE y:EPOS2_PARAM_UNUSE lang:EPOS2_LANG_EN r:0 g:0 b:0 ];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addtext"];
            return;
        }
        text = @"";
        text = [text stringByAppendingString:@"22.50"];
        result = [lineDisplay_ addText:text x:EPOS2_PARAM_UNUSE y:EPOS2_PARAM_UNUSE lang:EPOS2_LANG_EN r:255 g:0 b:0 ];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addtext"];
            return;
        }
        text = @"";
        
        text = [text stringByAppendingString:@"QTY:            3"];
        result = [lineDisplay_ addText:text x:EPOS2_PARAM_UNUSE y:EPOS2_PARAM_UNUSE lang:EPOS2_LANG_EN r:0 g:0 b:0 ];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addtext"];
            return;
        }
        text = @"";
        
        result = [lineDisplay_ addSetCurrentTextArea:2];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addSetCurrentWindow"];
            return;
        }
        
        text = [text stringByAppendingString:@"SubTotal:\n"];
        text = [text stringByAppendingString:@" $67.50\n"];
        result = [lineDisplay_ addText:text x:EPOS2_PARAM_UNUSE y:EPOS2_PARAM_UNUSE lang:EPOS2_LANG_EN r:0 g:0 b:0 ];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addtext"];
            return;
        }
        text = @"";
        
    }else
    {
        result = [lineDisplay_ addSetCurrentTextArea:1];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addSetCurrentWindow"];
            return;
        }
        
        text = [text stringByAppendingString:@"Item:\n"];
        text = [text stringByAppendingString:@"   Cut & Sewn\n"];
        result = [lineDisplay_ addText:text x:EPOS2_PARAM_UNUSE y:EPOS2_PARAM_UNUSE lang:EPOS2_LANG_EN r:0 g:0 b:0 ];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addtext"];
            return;
        }
        text = @"";
        
        result = [lineDisplay_ addSetCurrentTextArea:2];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addSetCurrentWindow"];
            return;
        }
        
        text = [text stringByAppendingString:@"Qty:               3"];
        text = [text stringByAppendingString:@"U.PC.:        $45.00"];
        result = [lineDisplay_ addText:text x:EPOS2_PARAM_UNUSE y:EPOS2_PARAM_UNUSE lang:EPOS2_LANG_EN r:0 g:0 b:0 ];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addtext"];
            return;
        }
        text = @"";
        
        text = [text stringByAppendingString:@"             (22.50)\n"];
        result = [lineDisplay_ addText:text x:EPOS2_PARAM_UNUSE y:EPOS2_PARAM_UNUSE lang:EPOS2_LANG_EN r:255 g:0 b:0 ];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addtext"];
            return;
        }
        text = @"";
        
        text = [text stringByAppendingString:@"SubTotal:     $67.50"];
        result = [lineDisplay_ addText:text x:EPOS2_PARAM_UNUSE y:EPOS2_PARAM_UNUSE lang:EPOS2_LANG_EN r:0 g:0 b:0 ];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addtext"];
            return;
        }
        text = @"";
    }
    if (![self connectDisplay]) {
        return;
    }
    
    result = [lineDisplay_  sendData];
    if (result != EPOS2_SUCCESS) {
        [lineDisplay_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"sendData"];
        [self disconnectDisplay];
        return;
    }
    return;
}

-(void)checkDemo{
    int result = EPOS2_SUCCESS;
    NSString *text = @"";
    if (lineDisplay_ == nil) {
        return;
    }
    
    result = [lineDisplay_ addStopSlideShow];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addStartSlideShow"];
        return;
    }
    
    if(_bIsLandscape) {
        result = [lineDisplay_ addDownloadImage:65 key2:65 dotX:0 dotY:0 width:800 height:240];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addDownloadImage"];
            return;
        }
        
        result = [lineDisplay_ addSetCurrentTextArea:1];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addSetCurrentWindow"];
            return;
        }
        
        result = [lineDisplay_ addClearCurrentTextArea];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addClearCurrentTextArea"];
            return;
        }
        
        text = [text stringByAppendingString:@"Store Information\n"];
        result = [lineDisplay_ addText:text x:EPOS2_PARAM_UNUSE y:EPOS2_PARAM_UNUSE lang:EPOS2_LANG_EN r:0 g:0 b:0 ];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addtext"];
            return;
        }
        text = @"";
        
        result = [lineDisplay_ addSetCurrentTextArea:2];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addSetCurrentWindow"];
            return;
        }
        
        result = [lineDisplay_ addClearCurrentTextArea];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addClearCurrentTextArea"];
            return;
        }
        
        text = [text stringByAppendingString:@"Total:    $66.50"];
        text = [text stringByAppendingString:@"Cash:    $100.50"];
        text = [text stringByAppendingString:@"Change:   $34.00"];
        result = [lineDisplay_ addText:text x:EPOS2_PARAM_UNUSE y:EPOS2_PARAM_UNUSE lang:EPOS2_LANG_EN r:0 g:0 b:0 ];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addtext"];
            return;
        }
        text = @"";
        
        result = [lineDisplay_ addSymbol:@"https://www.epson-pos.com/" type:EPOS2_SYMBOL_QRCODE_MODEL_2 level:EPOS2_LEVEL_L width:4 height:4 dotX:120 dotY:70 quietZone:EPOS2_FALSE];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addSymbol"];
            return;
        }
        
    }
    else {
        result = [lineDisplay_ addDownloadImage:66 key2:66 dotX:0 dotY:0 width:480 height:400];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addDownloadImage"];
            return;
        }
        result = [lineDisplay_ addSetCurrentTextArea:1];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addSetCurrentWindow"];
            return;
        }
        
        result = [lineDisplay_ addClearCurrentTextArea];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addClearCurrentTextArea"];
            return;
        }
        
        text = [text stringByAppendingString:@"Total:        $67.50"];
        text = [text stringByAppendingString:@"Cash:        $100.00"];
        text = [text stringByAppendingString:@"Change:       $32.50"];
        result = [lineDisplay_ addText:text x:EPOS2_PARAM_UNUSE y:EPOS2_PARAM_UNUSE lang:EPOS2_LANG_EN r:0 g:0 b:0 ];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addtext"];
            return;
        }
        text = @"";
        
        result = [lineDisplay_ addSetCurrentTextArea:2];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addSetCurrentWindow"];
            return;
        }
        
        result = [lineDisplay_ addClearCurrentTextArea];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addClearCurrentTextArea"];
            return;
        }
        text = [text stringByAppendingString:@"\n Store Information\n"];
        result = [lineDisplay_ addText:text x:EPOS2_PARAM_UNUSE y:EPOS2_PARAM_UNUSE lang:EPOS2_LANG_EN r:0 g:0 b:0 ];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addtext"];
            return;
        }
        text = @"";
        
        result = [lineDisplay_ addSymbol:@"https://www.epson-pos.com/" type:EPOS2_SYMBOL_QRCODE_MODEL_2 level:EPOS2_LEVEL_L width:4 height:4 dotX:160 dotY:260 quietZone:EPOS2_FALSE];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEpos:result method:@"addSymbol"];
            return;
        }
        
    }
    if (![self connectDisplay]) {
        return;
    }
    
    result = [lineDisplay_  sendData];
    if (result != EPOS2_SUCCESS) {
        [lineDisplay_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"sendData"];
        [self disconnectDisplay];
        return;
    }
    return;
}

-(void)startSlideShow{
    int result = EPOS2_SUCCESS;
    _bIsWorkingSlideshow = YES;
    if (lineDisplay_ == nil) {
        return;
    }
    
    result = [lineDisplay_ addInitialize];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addInitialize"];
        return;
    }
    
    result = [lineDisplay_ addStartSlideShow:500];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addStartSlideShow"];
        return;
    }
    
    
    if (![self connectDisplay]) {
        return;
    }
    
    result = [lineDisplay_  sendData];
    if (result != EPOS2_SUCCESS) {
        [lineDisplay_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"sendData"];
        [self disconnectDisplay];
        return;
    }
    return;
}

-(void)stopSlideShow{
    int result = EPOS2_SUCCESS;
    if (lineDisplay_ == nil) {
        return;
    }
    
    result = [lineDisplay_ addInitialize];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addInitialize"];
        return;
    }
    result = [lineDisplay_ addStopSlideShow];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addStartSlideShow"];
        return;
    }
    
    
    _bIsWorkingSlideshow = NO;
    if (![self connectDisplay]) {
        return;
    }
    
    result = [lineDisplay_  sendData];
    if (result != EPOS2_SUCCESS) {
        [lineDisplay_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"sendData"];
        [self disconnectDisplay];
        return;
    }
    
    return;
}


- (void)updateButtonState:(BOOL)state
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _buttonOrder.enabled = state;
        _buttonCheck.enabled = state;
    }];
}

- (BOOL)initializeObject
{
    
    lineDisplay_ = [[Epos2LineDisplay alloc]initWithDisplayModel:EPOS2_DM_D70];
    
    if (lineDisplay_ == nil) {
        [ShowMsg showErrorEpos:EPOS2_ERR_MEMORY method:@"initWithDisplayModel"];
        return NO;
    }
    
    [lineDisplay_ setReceiveEventDelegate:self];
    
    return YES;
}

- (void)finalizeObject
{
    if (lineDisplay_ == nil) {
        return;
    }
    
    [lineDisplay_ setReceiveEventDelegate:nil];
    
    lineDisplay_ = nil;
}

- (BOOL)connectDisplay
{
    int result = EPOS2_SUCCESS;
    
    if (lineDisplay_ == nil) {
        return NO;
    }
    
    //Note: This API must be used from background thread only
    result = [lineDisplay_ connect:target_ timeout:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [lineDisplay_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"connect"];
        return NO;
    }
    
    return YES;
}

- (void)disconnectDisplay
{
    int result = EPOS2_SUCCESS;
    
    if (lineDisplay_ == nil) {
        return;
    }
    
    //Note: This API must be used from background thread only
    result = [lineDisplay_ disconnect];
    if (result != EPOS2_SUCCESS) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[NSNumber numberWithInt:result] forKey:KEY_RESULT];
        [dict setObject:@"disconnect" forKey:KEY_METHOD];
        
        [self performSelectorOnMainThread:@selector(showEposErrorFromThread:) withObject:dict waitUntilDone:NO];
    }
    
    [lineDisplay_ clearCommandBuffer];
}

- (void)showEposErrorFromThread:(NSDictionary *)dict
{
    int result = EPOS2_SUCCESS;
    NSString *method = @"";
    result = [[dict valueForKey:KEY_RESULT] intValue];
    method = [dict valueForKey:KEY_METHOD];
    [ShowMsg showErrorEpos:result method:method];
}

- (void) onDispReceive:(Epos2LineDisplay *)displayObj code:(int)code
{
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        [self disconnectDisplay];
        [self hideIndicator];
        [ShowMsg showResult:code];
    }];
}

- (NSData*)imgToNSData:(NSString *)fileName
{
    NSString *imgName = [NSString stringWithFormat:@"%@", fileName];
    UIImage *img = [UIImage imageNamed:imgName];
    NSData *pngData = UIImagePNGRepresentation(img);
    return pngData;
}

@end
