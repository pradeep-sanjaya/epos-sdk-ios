#import "DiscoveryViewController.h"
#import "ShowMsg.h"

@interface DiscoveryViewController()<UITableViewDataSource, UITableViewDelegate, Epos2DiscoveryDelegate>
@end

@implementation DiscoveryViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        filteroption_  = [[Epos2FilterOption alloc] init];
        [filteroption_ setDeviceType:EPOS2_TYPE_HYBRID_PRINTER];
        printerList_ = [[NSMutableArray alloc]init];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowNumber = 0;
    if (section == 0) {
        rowNumber = [printerList_ count];
    }
    else {
        rowNumber = 1;
    }
    return rowNumber;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"basis-cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }

    if (indexPath.section == 0) {
        if (indexPath.row >= 0 && indexPath.row < [printerList_ count]) {
            cell.textLabel.text = [(Epos2DeviceInfo *)[printerList_ objectAtIndex:indexPath.row] getDeviceName];
            cell.detailTextLabel.text = [(Epos2DeviceInfo *)[printerList_ objectAtIndex:indexPath.row] getTarget];
        }
    }
    else {
        cell.textLabel.text = @"other...";
        cell.detailTextLabel.text = @"";
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onSelectPrinter:)]) {
            [self.delegate onSelectPrinter:[(Epos2DeviceInfo *)[printerList_ objectAtIndex:indexPath.row] getTarget]];
            self.delegate = nil;
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    else {
        [self performSelectorOnMainThread:@selector(connectDevice:) withObject:nil waitUntilDone:NO];
    }
}

- (void)connectDevice:(id)userInfo
{
    int result = EPOS2_SUCCESS;
    [Epos2Discovery stop];
    if (printerList_ != nil) {
        [printerList_ removeAllObjects];
    }

    Epos2BluetoothConnection *btConnection = [[Epos2BluetoothConnection alloc] init];
    NSMutableString *BDAddress = [[NSMutableString alloc] init];
    result = [btConnection connectDevice:BDAddress];
    if (result == EPOS2_SUCCESS) {
        [self.delegate onSelectPrinter:(NSString *)BDAddress];
        self.delegate = nil;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else {
        [Epos2Discovery start:filteroption_ delegate:self];
        [_printerView_ reloadData];
    }
    [ShowMsg showErrorEposBt:result method:@"connectDevice"];
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

- (void) onDiscovery:(Epos2DeviceInfo *)deviceInfo
{
    [printerList_ addObject:deviceInfo];
    [_printerView_ reloadData];
}

@end
