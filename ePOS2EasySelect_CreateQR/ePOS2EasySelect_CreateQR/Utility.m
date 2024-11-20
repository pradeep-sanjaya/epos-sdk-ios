#import "Utility.h"

@implementation Utility

static NSString *const EPOS2_ConnectionTypeString_TCP = @"TCP";
static NSString *const EPOS2_ConnectionTypeString_BT = @"BT";

//----------------------------------------------------------------------------//
#pragma mark - Utility for Epos2Printer parameter
//----------------------------------------------------------------------------//

+ (int)convertPrinterNameToPrinterSeries:(NSString *)printerName
{
    int printerSeries = EPOS2_TM_T88;

    if ([printerName isEqualToString:@"TM-T88V"] || [printerName isEqualToString:@"TM-T88VI"]) {
        printerSeries = EPOS2_TM_T88;
    }
    else if ([printerName isEqualToString:@"TM-m10"]) {
        printerSeries = EPOS2_TM_M10;
    }
    else if ([printerName isEqualToString:@"TM-m30"]) {
        printerSeries = EPOS2_TM_M30;
    }
    else if ([printerName isEqualToString:@"TM-P20"]) {
        printerSeries = EPOS2_TM_P20;
    }
    else if ([printerName isEqualToString:@"TM-P60II"]) {
        printerSeries = EPOS2_TM_P60II;
    }
    else if ([printerName isEqualToString:@"TM-P80"]) {
        printerSeries = EPOS2_TM_P80;
    }
    else if ([printerName isEqualToString:@"TM-H6000V"]) {
        printerSeries = EPOS2_TM_H6000;
    }
    else if ([printerName isEqualToString:@"TM-m30II"] || [printerName hasPrefix:@"TM-m30II-"]) {
        printerSeries = EPOS2_TM_M30II;
    }
    else if ([printerName isEqualToString:@"TM-m50"]) {
        printerSeries = EPOS2_TM_M50;
    }
    else if ([printerName isEqualToString:@"TM-T88VII"]) {
        printerSeries = EPOS2_TM_T88VII;
    }
    else if ([printerName isEqualToString:@"TM-L100"]) {
        printerSeries = EPOS2_TM_L100;
    }
    else if ([printerName isEqualToString:@"TM-P20II"]) {
        printerSeries = EPOS2_TM_P20II;
    }
    else if ([printerName isEqualToString:@"TM-P80II"]) {
        printerSeries = EPOS2_TM_P80II;
    }
    else if ([printerName isEqualToString:@"TM-m30III"] || [printerName hasPrefix:@"TM-m30III-"]) {
            printerSeries = EPOS2_TM_M30III;
    }
    else if ([printerName isEqualToString:@"TM-m50II"] || [printerName hasPrefix:@"TM-m50II-"]) {
        printerSeries = EPOS2_TM_M50II;
    }
    else if ([printerName isEqualToString:@"TM-m55"]) {
        printerSeries = EPOS2_TM_M55;
    }
    else {
        // if you use other printer , add convert printerSeries
    }

    return printerSeries;
}

//----------------------------------------------------------------------------//
#pragma mark - convert EposEasySelectInfo to Epos2Printer parameter
//----------------------------------------------------------------------------//

+ (NSString *)convertEasySelectInfoToTargetString:(EposEasySelectInfo *)easySelectInfo
{
    NSString *connectionTypeString = [self convertDeviceTypeToConnectionTypeString:easySelectInfo.deviceType];

    if (0 < [easySelectInfo.macAddress length]) {
        return [NSString stringWithFormat:@"%@:%@", connectionTypeString, easySelectInfo.macAddress];
    }else if (0 < [easySelectInfo.target length]) {
        return [NSString stringWithFormat:@"%@:%@", connectionTypeString, easySelectInfo.target];
    }else {
        return @"";
    }
}

+ (NSString *)convertDeviceTypeToConnectionTypeString:(int)deviceType
{
    NSString *connectionTypeString = @"";

    switch (deviceType) {
        case EPOS_EASY_SELECT_DEVTYPE_TCP:
            connectionTypeString = EPOS2_ConnectionTypeString_TCP;
            break;
        case EPOS_EASY_SELECT_DEVTYPE_BLUETOOTH:
            connectionTypeString = EPOS2_ConnectionTypeString_BT;
            break;
    }
    return connectionTypeString;
}

//----------------------------------------------------------------------------//
#pragma mark - convert Epos2DeviceInfo to EposEasySelectInfo
//----------------------------------------------------------------------------//

+ (int)convertEpos2DeviceInfoToEposEasySelectDeviceType:(Epos2DeviceInfo *)deviceInfo
{
    int deviceType = EPOS_EASY_SELECT_DEVTYPE_TCP;

    if ([self isDeviceNetwork:deviceInfo]) {
        deviceType = EPOS_EASY_SELECT_DEVTYPE_TCP;
    }
    else if ([self isDeviceBluetooth:deviceInfo]) {
        deviceType = EPOS_EASY_SELECT_DEVTYPE_BLUETOOTH;
    }

    return deviceType;
}

//----------------------------------------------------------------------------//
#pragma mark - Handle Epos2DeviceInfo
//----------------------------------------------------------------------------//
+ (BOOL)isDeviceBluetooth:(Epos2DeviceInfo *)deviceInfo
{
    NSString *bdAddress = [deviceInfo getBdAddress];

    if (!bdAddress) {
        return NO;
    }

    if ([bdAddress isEqualToString:@""]) {
        return NO;
    }

    return YES;
}

+ (BOOL)isDeviceNetwork:(Epos2DeviceInfo *)deviceInfo
{
    NSString *macAddress = [deviceInfo getMacAddress];

    if (!macAddress) {
        return NO;
    }

    if ([macAddress isEqualToString:@""]) {
        return NO;
    }

    return YES;
}

+ (NSString *)getAddressFromEpos2DeviceInfo:(Epos2DeviceInfo *)deviceInfo
{
    NSString *address = @"";

    if ([self isDeviceNetwork:deviceInfo]) {
        address = deviceInfo.macAddress;
    }
    else if ([self isDeviceBluetooth:deviceInfo]) {
        address = deviceInfo.bdAddress;
    }

    return address;
}

+ (NSString *)convertEpos2DeficeInfoToInterfaceString:(Epos2DeviceInfo *)deviceInfo
{
    int deviceType = [self convertEpos2DeviceInfoToEposEasySelectDeviceType:deviceInfo];

    return [self convertEposConnectionTypeToInterfaceString:deviceType];
}

//----------------------------------------------------------------------------//
#pragma mark - Handle EposEasySelectDeviceType
//----------------------------------------------------------------------------//
+ (NSString *)convertEposConnectionTypeToInterfaceString:(int)connectionType
{
    switch (connectionType) {
        case EPOS_EASY_SELECT_DEVTYPE_BLUETOOTH:
            return @"Bluetooth";
        case EPOS_EASY_SELECT_DEVTYPE_TCP:
            return @"Network";
        default:
            return @"";
    }
}

@end
