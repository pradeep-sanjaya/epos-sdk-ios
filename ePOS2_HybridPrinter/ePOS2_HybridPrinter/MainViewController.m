#import "MainViewController.h"
#import "PassViewController.h"
#import "ValidationViewController.h"
#import "ShowMsg.h"

@interface MainViewController() 
@end

@implementation MainViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        hybridPrinter_ = nil;
        connectTarget_ = nil;
        lang_ = EPOS2_MODEL_ANK;
        hybridPrinterlang_ = EPOS2_MODEL_ANK;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSMutableArray *items = [[NSMutableArray alloc] init];

    langList_ = [[PickerTableView alloc] init];
    items = [[NSMutableArray alloc] init];
    [items addObject:NSLocalizedString(@"language_ank", @"")];
    [items addObject:NSLocalizedString(@"language_japanese", @"")];
    [items addObject:NSLocalizedString(@"language_chinese", @"")];
    [items addObject:NSLocalizedString(@"language_taiwan", @"")];
    [items addObject:NSLocalizedString(@"language_korean", @"")];
    [items addObject:NSLocalizedString(@"language_thai", @"")];
    [items addObject:NSLocalizedString(@"language_southasia", @"")];

    [langList_ setItemList:items];
    [_buttonLang setTitle:[langList_ getItem:0] forState:UIControlStateNormal];
    langList_.delegate = self;

    [self setDoneToolbar];

    int result = [Epos2Log setLogSettings:EPOS2_PERIOD_TEMPORARY output:EPOS2_OUTPUT_STORAGE ipAddress:nil port:0 logSize:1 logLevel:EPOS2_LOGLEVEL_LOW];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"setLogSettings"];
    }
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
}

- (IBAction)eventButtonDidPush:(id)sender
{
    connectTarget_ = [NSString stringWithString: _textTarget.text];
    switch (((UIView *)sender).tag) {
        case 1:
            [langList_ show];
            break;
            
        default:
            break;
    }
}

- (BOOL)initializeObject
{
    if(hybridPrinter_ == nil){
        hybridPrinter_ = [[Epos2HybridPrinter alloc] initWithLang:lang_];
    }
    else{
        if(lang_ != hybridPrinterlang_){
            [self finalizeObject];
            
            hybridPrinter_ = [[Epos2HybridPrinter alloc] initWithLang:lang_];
        }
    }
    

    if (hybridPrinter_ == nil) {
        return NO;
    }
    else{
        hybridPrinterlang_ = lang_;
    }

    return YES;
}

- (void)finalizeObject
{
    if (hybridPrinter_ == nil) {
        return;
    }

    [hybridPrinter_ clearCommandBuffer];

    [hybridPrinter_ setReceiveEventDelegate:nil];

    hybridPrinter_ = nil;
}

- (void)onSelectPrinter:(NSString *)target
{
    _textTarget.text = target;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *view = nil;

    if ([segue.identifier isEqualToString:@"DiscoveryView"]) {

        view = (DiscoveryViewController *)[segue destinationViewController];

        ((DiscoveryViewController *)view).delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"PassView"]) {
        
        view = (PassViewController *)[segue destinationViewController];
        if([self initializeObject])
        {
            ((PassViewController *)view).hybridPrinter_ = hybridPrinter_;
            ((PassViewController *)view).connectTarget_ = connectTarget_;
        }
    }
    else if ([segue.identifier isEqualToString:@"ValidationView"]) {
        
        view = (ValidationViewController *)[segue destinationViewController];
        if([self initializeObject])
        {
            ((ValidationViewController *)view).hybridPrinter_ = hybridPrinter_;
            ((ValidationViewController *)view).connectTarget_ = connectTarget_;
        }
    }
}

- (void)onSelectPickerItem:(NSInteger)position obj:(id)obj
{
    if (obj == langList_) {
        [_buttonLang setTitle:[langList_ getItem:position] forState:UIControlStateNormal];
        lang_ = (int)langList_.selectIndex;

    }
    else {
        ; //do nothing
    }
}

@end
