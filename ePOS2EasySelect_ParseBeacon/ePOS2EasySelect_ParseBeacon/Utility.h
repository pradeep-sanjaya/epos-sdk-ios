#import <Foundation/Foundation.h>
#import "ePOSEasySelect.h"
#import "ePOS2.h"

@interface Utility : NSObject

+ (int)convertPrinterNameToPrinterSeries:(NSString *)printerName;
+ (NSString *)convertEasySelectInfoToTargetString:(EposEasySelectInfo *)easySelectInfo;
+ (NSString *)convertDeviceTypeToConnectionTypeString:(int)deviceType;

+ (int)convertEpos2DeviceInfoToEposEasySelectDeviceType:(Epos2DeviceInfo *)deviceInfo;
+ (NSString *)getAddressFromEpos2DeviceInfo:(Epos2DeviceInfo *)deviceInfo;
+ (NSString *)convertEpos2DeficeInfoToInterfaceString:(Epos2DeviceInfo *)deviceInfo;

+ (NSString *)convertEposConnectionTypeToInterfaceString:(int)connectionType;

@end
