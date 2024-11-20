#import "DiscoveryViewController.h"

@interface DiscoveryViewController()
@end

@implementation DiscoveryViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        ePOS2SDKManager = [[EPOS2SDKManager alloc] init];
        ePOS2SDKManager.delegate = self;
        
        filteroption_  = [[Epos2FilterOption alloc] init];
        [filteroption_ setDeviceType:EPOS2_TYPE_PRINTER];
        printerList_ = [[NSMutableArray alloc]init];
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

    [ePOS2SDKManager startDiscovery:filteroption_];

    [_printerView_ reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [ePOS2SDKManager stopDiscovery];

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
    } else {
        cell.textLabel.text = @"other...";
        cell.detailTextLabel.text = @"";
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString* target = [[printerList_ objectAtIndex:indexPath.row] getTarget];
        NSRange found = [target rangeOfString:@"["];
        if(found.location == NSNotFound) {
            targetPrn_ = target;
            targetGfe_ = target;
            targetDsp_ = target;
            targetScn_ = target;
        } else {
            NSString *target_IP = [target substringWithRange:NSMakeRange(0, found.location)];
            targetPrn_ = target;
            targetGfe_ = [target_IP stringByAppendingString:NSLocalizedString(@"deviceId_gfe", nil)];
            targetDsp_ = [target_IP stringByAppendingString:NSLocalizedString(@"deviceId_display", nil)];
            targetScn_ = [target_IP stringByAppendingString:NSLocalizedString(@"deviceId_scanner", nil)];
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
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
        targetGfe_ = BDAddress;
        targetPrn_ = BDAddress;
        targetDsp_ = BDAddress;
        targetScn_ = BDAddress;
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [ePOS2SDKManager startDiscovery:filteroption_];
        [_printerView_ reloadData];
    }
}

- (IBAction)restartDiscovery:(id)sender {
    [ePOS2SDKManager stopDiscovery];

    [printerList_ removeAllObjects];
    [_printerView_ reloadData];

    [ePOS2SDKManager startDiscovery:filteroption_];
}

- (void) onDiscoveryEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager deviceInfo:(Epos2DeviceInfo *)deviceInfo;
{
    [printerList_ addObject:deviceInfo];
    [_printerView_ reloadData];
}

@end
