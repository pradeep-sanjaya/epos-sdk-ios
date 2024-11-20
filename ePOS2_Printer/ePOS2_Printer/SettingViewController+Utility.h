#import "SettingViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SettingViewController (Utility)
- (NSString *)convertPrintSpeedEnum2String:(int)speedEnum;
- (NSString *)convertPrintDensityEnum2String:(int)dencityEnum;
- (NSString *)convertPaperWidthEnum2String:(int)paperWidthEnum;
- (int)convertPrintSpeedString2Enum:(NSString *)speedStr;
- (int)convertPrintDeinsityString2Enum:(NSString *)densityStr;
- (int)convertPaperWidthString2Enum:(NSString *)widthStr;
@end

NS_ASSUME_NONNULL_END
