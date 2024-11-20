#import "ConnectViewController.h"

@interface ConnectViewController()
@end

@implementation ConnectViewController

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

    [_switchTraining addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    _switchTraining.on = NO;

    [self setDoneToolbar];
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
    _textTarget.inputAccessoryView = doneToolbar;
    _textSetTimeout.inputAccessoryView = doneToolbar;
}

- (void)doneCAT:(id)sender
{
    [_textTarget resignFirstResponder];
    [_textSetTimeout resignFirstResponder];
}

- (IBAction)connectProcess:(id)sender
{
    if (![self initializeObject]) {
        return;
    }

    if (![self connectCAT]) {
        return;
    }

    _buttonConnect.enabled = NO;
}

- (IBAction)disconnectProcess:(id)sender
{
    [self disconnectCAT];

    [self finalizeObject];

    _buttonConnect.enabled = YES;
}

- (BOOL)connectCAT
{
    int result = EPOS2_SUCCESS;

    if (cat_ == nil) {
        return NO;
    }

    result = [cat_ connect:_textTarget.text timeout:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"connect"];
        [self finalizeObject];
        return NO;
    }
    isConnect_ = YES;

    return YES;
}

- (void)disconnectCAT
{
    int result = EPOS2_SUCCESS;

    if (cat_ == nil) {
        return;
    }

    if(isConnect_ == YES) {
        result = [cat_ disconnect];
        if (result != EPOS2_SUCCESS) {
            isConnect_ = NO;
            
            [ShowMsg showErrorEpos:result method:@"disconnect"];
        }
    }
    else {
        return;
    }
}

- (IBAction)setTimeoutCat:(id)sender
{
    int result = EPOS2_SUCCESS;

    if (cat_ == nil) {
        return;
    }
    
    long timeout = [_textSetTimeout.text intValue];
    
    result = [cat_ setTimeout:timeout];
    
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"setTimeout"];
    }
    
    return;
}

- (void) switchChanged:(UISwitch *)switchParts
{
    if(cat_ == nil) {
        return;
    }
    if(_switchTraining.on == YES) {
        [cat_ setTrainingMode:EPOS2_TRUE];
    } else {
        [cat_ setTrainingMode:EPOS2_FALSE];
    }
}

- (IBAction)clearCAT:(id)sender
{
    self.textCAT.text = @"";
}
@end
