#import "DiscoveryViewController.h"
#import "ShowMsg.h"

@interface DiscoveryViewController () <UITableViewDataSource, UITableViewDelegate, Epos2DiscoveryDelegate>
@end

@implementation DiscoveryViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        filteroption_ = [[Epos2FilterOption alloc] init];
        [filteroption_ setDeviceType:EPOS2_TYPE_PRINTER];
        printerList_ = [[NSMutableArray alloc] init];
        self.delegate = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _printerView_.dataSource = self;
    _printerView_.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    int result = [Epos2Discovery start:filteroption_ delegate:self];
    if (EPOS2_SUCCESS != result) {
        [ShowMsg showErrorEpos:result method:@"start"];
    }

    [_printerView_ reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    int result = EPOS2_SUCCESS;

    while (YES) {
        result = [Epos2Discovery stop];

        if (result != EPOS2_ERR_PROCESSING) {
            break;
        }
    }

    if (printerList_ != nil) {
        [printerList_ removeAllObjects];
    }
}

- (void)dealloc
{
    printerList_ = nil;
    filteroption_ = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [printerList_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"basis-cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }

    if (indexPath.row >= 0 && indexPath.row < [printerList_ count]) {
        cell.textLabel.text = [(Epos2DeviceInfo *)[printerList_ objectAtIndex:indexPath.row] getDeviceName];
        cell.detailTextLabel.text = [(Epos2DeviceInfo *)[printerList_ objectAtIndex:indexPath.row] getTarget];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSelectPrinter:)]) {
        [self.delegate onSelectPrinter:[printerList_ objectAtIndex:indexPath.row]];
        self.delegate = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)restartDiscovery:(id)sender
{
    int result = EPOS2_SUCCESS;

    while (YES) {
        result = [Epos2Discovery stop];

        if (result != EPOS2_ERR_PROCESSING) {
            if (result == EPOS2_SUCCESS) {
                break;
            }
            else {
                [ShowMsg showErrorEpos:result method:@"stop"];
                return;
            }
        }
    }

    [printerList_ removeAllObjects];
    [_printerView_ reloadData];

    result = [Epos2Discovery start:filteroption_ delegate:self];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEpos:result method:@"start"];
    }
}

- (void)onDiscovery:(Epos2DeviceInfo *)deviceInfo
{
    // BLE Printer is not supported on ePOS EasySelect.
    if(![deviceInfo.getTarget hasPrefix:@"BLE:"]){
        [printerList_ addObject:deviceInfo];
        [_printerView_ reloadData];
    }
}

@end
