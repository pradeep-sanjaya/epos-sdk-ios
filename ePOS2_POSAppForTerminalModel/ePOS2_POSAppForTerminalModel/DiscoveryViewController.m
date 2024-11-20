//
//  DiscoveryViewController.m
//  ePOS2_Composite
//
//

#import "DiscoveryViewController.h"
#import "AppDelegate.h"

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
        printerList2_ = [[NSMutableArray alloc]init];
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
    
    if (printerList2_ != nil) {
        [printerList2_ removeAllObjects];
    }
}

- (void)dealloc
{
    printerList2_ = nil;
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
        rowNumber = [printerList2_ count];
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
        if (indexPath.row >= 0 && indexPath.row < [printerList2_ count]) {
            cell.textLabel.text = [(Epos2DeviceInfo *)[printerList2_ objectAtIndex:indexPath.row] getDeviceName];
            cell.detailTextLabel.text = [(Epos2DeviceInfo *)[printerList2_ objectAtIndex:indexPath.row] getTarget];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString* target = [[printerList2_ objectAtIndex:indexPath.row] getTarget];
        NSRange found = [target rangeOfString:@"["];
        AppDelegate *appDelegate =(AppDelegate*) [[UIApplication sharedApplication] delegate];
        
        if(found.location == NSNotFound) {
            //update appdelegate
            appDelegate.targetPrinter = target;
            appDelegate.targetDisplay = target;
            appDelegate.targetScanner = target;
            appDelegate.targetCashChanger = target;
        } else {
            NSString *target_IP = [target substringWithRange:NSMakeRange(0, found.location)];
            appDelegate.targetPrinter = target;
            appDelegate.targetDisplay = [target_IP stringByAppendingString:NSLocalizedString(@"deviceId_display", nil)];
            appDelegate.targetScanner = [target_IP stringByAppendingString:NSLocalizedString(@"deviceId_scanner", nil)];
            appDelegate.targetCashChanger = [target_IP stringByAppendingString:NSLocalizedString(@"deviceId_cashchanger", nil)];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)restartDiscovery:(id)sender {
    
    [ePOS2SDKManager stopDiscovery];
    
    [printerList2_ removeAllObjects];
    [_printerView_ reloadData];
    
    [ePOS2SDKManager startDiscovery:filteroption_];
}

- (void) onDiscoveryEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager deviceInfo:(Epos2DeviceInfo *)deviceInfo;
{
        [printerList2_ addObject:deviceInfo];
        [_printerView_ reloadData];
}

@end
