#import "DMD30ViewController.h"
#import "UIViewController+Extension.h"
#import "ShowMsg.h"

#define KEY_RESULT                  @"Result"
#define KEY_METHOD                  @"Method"
#define BLINK_INTERVAL              1000

@interface DMD30ViewController() <Epos2DispReceiveDelegate>
@end

@implementation DMD30ViewController

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

    [self initializeObject];
    target_ = _textTarget.text;
    text_ = _textData.text;
    isSwitchBlink_ = _switchBlink.on;
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
    _textData.inputAccessoryView = doneToolbar;
}

- (void)doneKeyboard:(id)sender
{
    [_textTarget resignFirstResponder];
    [_textData resignFirstResponder];
    target_ =_textTarget.text;
    text_ = _textData.text;
}

- (IBAction)textDisplay:(id)sender
{
    [self showIndicator:NSLocalizedString(@"wait", @"")];
    
    isSwitchBlink_ = _switchBlink.on;
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        if (![self runLineDisplaySequence]) {
            [self hideIndicator];
        }
    }];
}

- (BOOL)runLineDisplaySequence
{
    int result = EPOS2_SUCCESS;

    if (![self createDisplayData]) {
        return NO;
    }

    if (![self connectDisplay]) {
        return NO;
    }

    result = [lineDisplay_  sendData];
    if (result != EPOS2_SUCCESS) {
        [lineDisplay_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"sendData"];
        [self disconnectDisplay];
        return NO;
    }

    return YES;
}

- (BOOL)createDisplayData
{
    int result = EPOS2_SUCCESS;

    if (lineDisplay_ == nil) {
        return NO;
    }

    result = [lineDisplay_ addInitialize];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"addInitialize"];
        return NO;
    }

    result = [lineDisplay_ addSetCursorPosition:1 y:1];
    if (result != EPOS2_SUCCESS) {
        [lineDisplay_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addSetCursorPosition"];
        return NO;
    }

    if (isSwitchBlink_) {
        result = [lineDisplay_ addSetBlink:BLINK_INTERVAL];
        if (result != EPOS2_SUCCESS) {
            [lineDisplay_ clearCommandBuffer];
            [ShowMsg showErrorEpos:result method:@"addSetBlink"];
            return NO;
        }
    }

    result = [lineDisplay_ addText:text_];
    if (result != EPOS2_SUCCESS) {
        [lineDisplay_ clearCommandBuffer];
        [ShowMsg showErrorEpos:result method:@"addText"];
        return NO;
    }

    return YES;
}

- (BOOL)initializeObject
{

    lineDisplay_ = [[Epos2LineDisplay alloc]initWithDisplayModel:EPOS2_DM_D30];

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
        [ShowMsg showResult:code];
        [self disconnectDisplay];
        [self hideIndicator];
    }];
}
@end
