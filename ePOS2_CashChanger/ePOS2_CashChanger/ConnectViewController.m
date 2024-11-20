#import "ConnectViewController.h"

@interface ConnectViewController()
@end

@implementation ConnectViewController

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

- (void)setDoneToolbar
{
    UIToolbar *doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    
    [doneToolbar sizeToFit];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneCashChanger:)];
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects:space, doneButton, nil];
    [doneToolbar setItems:items animated:YES];
    _textTarget.inputAccessoryView = doneToolbar;
}

- (void)doneCashChanger:(id)sender
{
    [_textTarget resignFirstResponder];
}

- (IBAction)connectProcess:(id)sender
{
    if (![self initializeObject]) {
        return;
    }

    if (![self connectCashChanger]) {
        return;
    }

    _buttonConnect.enabled = NO;
}

- (IBAction)disconnectProcess:(id)sender
{
    [self disconnectCashChanger];

    [self finalizeObject];

    _buttonConnect.enabled = YES;
}

- (BOOL)connectCashChanger
{
    int result = EPOS2_SUCCESS;

    if (cchanger_ == nil) {
        return NO;
    }

    result = [cchanger_ connect:_textTarget.text timeout:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"connect"];
        [self finalizeObject];
        return NO;
    }
    isConnect_ = YES;

    return YES;
}

- (void)disconnectCashChanger
{
    int result = EPOS2_SUCCESS;

    if (cchanger_ == nil) {
        return;
    }

    if(isConnect_ == YES) {
        result = [cchanger_ disconnect];
        if (result != EPOS2_SUCCESS) {
            isConnect_ = NO;
            
            [ShowMsg showErrorEpos:result method:@"disconnect"];
        }
    }
    else {
        return;
    }
}

- (IBAction)clearCashChanger:(id)sender
{
    self.textCashChanger.text = @"";
}
@end
