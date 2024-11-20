#import "DrawerViewController.h"
#import "ShowMsg.h"

@interface DrawerViewController()
@end

@implementation DrawerViewController

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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (IBAction)onOpenDrawer:(id)sender {
    int result = EPOS2_SUCCESS;
    if(cchanger_ == nil) {
        return;
    }
    
    [cchanger_ openDrawer];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"openDrawer"];
        return;
    }
}

- (IBAction)clearCashChanger:(id)sender
{
    self.textCashChanger.text = @"";
}
@end
