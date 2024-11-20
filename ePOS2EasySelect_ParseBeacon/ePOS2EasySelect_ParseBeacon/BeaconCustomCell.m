#import "BeaconCustomCell.h"

@implementation BeaconCustomCell

- (void)setPrinterInfomation:(BeaconPrinterInfo *)printerInfo selected:(BOOL)selected
{
    [self setPrinterName:printerInfo.easyselectInfo.printerName];
    [self setIpAddress:printerInfo.easyselectInfo.target];
    
    
    CLBeacon *beacon = printerInfo.beacon;
    
    [self.rssiBar setDrawInfo:selected rssiLevel:beacon.rssi];
    self.rssiLabel.text = [NSString stringWithFormat:@"RSSI:%ddBm", (int)beacon.rssi];
    self.printButton.tag = printerInfo.tag;
    
    if (selected) {
        self.printButton.hidden = NO;
        
        if ((beacon.rssi == 0) || ([printerInfo.easyselectInfo.target length] == 0)) {
            self.printButton.enabled = NO;
        }else {
            self.printButton.enabled = YES;
        }
        
        if(self.printButton.enabled) {
            self.printButton.backgroundColor = [UIColor blueColor];
            self.printButton.titleLabel.textColor = [UIColor whiteColor];
        }else {
            self.printButton.backgroundColor = [UIColor grayColor];
            self.printButton.titleLabel.textColor = [UIColor whiteColor];
        }
    }
    else {
        self.printButton.hidden = YES;
    }
    
    
    
}

- (void)setPrinterName:(NSString *)printerName
{
    if ([printerName length] == 0) {
        self.printerNameLabel.text = [NSString stringWithFormat:@"Printer : %@", @"TM-T88V(Unknown)"];
    }
    else {
        self.printerNameLabel.text = [NSString stringWithFormat:@"Printer : %@", printerName];
    }
}

- (void)setIpAddress:(NSString *)ipAddress
{
    if ([ipAddress length] == 0) {
        NSString *ipaddressText =@"IP Address :Unknown";
        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:ipaddressText];
        NSDictionary *stringAttributes = @{ NSForegroundColorAttributeName : [UIColor redColor]};
        NSRange range = [ipaddressText rangeOfString:@"Unknown"];
        
        [mutableAttributedString setAttributes:stringAttributes range:range];
        self.ipAdderssLabel.attributedText = mutableAttributedString ;
    }
    else {
        self.ipAdderssLabel.text = [NSString stringWithFormat:@"%@", ipAddress];
    }
}

- (void)drawRect:(CGRect)rect
{
    self.printButton.layer.cornerRadius = 5;
    self.printButton.clipsToBounds = true;
}

@end
