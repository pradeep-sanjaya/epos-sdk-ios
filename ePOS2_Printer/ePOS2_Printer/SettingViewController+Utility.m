#import "SettingViewController+Utility.h"

@implementation SettingViewController (Utility)

- (NSString *)convertPrintSpeedEnum2String:(int)speedEnum {
    NSString *speedStr = @"invalid";
    switch (speedEnum) {
        case EPOS2_PRINTER_SETTING_PRINTSPEED_1:
            speedStr = NSLocalizedString(@"printspeed_1", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTSPEED_2:
            speedStr = NSLocalizedString(@"printspeed_2", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTSPEED_3:
            speedStr = NSLocalizedString(@"printspeed_3", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTSPEED_4:
            speedStr = NSLocalizedString(@"printspeed_4", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTSPEED_5:
            speedStr = NSLocalizedString(@"printspeed_5", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTSPEED_6:
            speedStr = NSLocalizedString(@"printspeed_6", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTSPEED_7:
            speedStr = NSLocalizedString(@"printspeed_7", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTSPEED_8:
            speedStr = NSLocalizedString(@"printspeed_8", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTSPEED_9:
            speedStr = NSLocalizedString(@"printspeed_9", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTSPEED_10:
            speedStr = NSLocalizedString(@"printspeed_10", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTSPEED_11:
            speedStr = NSLocalizedString(@"printspeed_11", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTSPEED_12:
            speedStr = NSLocalizedString(@"printspeed_12", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTSPEED_13:
            speedStr = NSLocalizedString(@"printspeed_13", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTSPEED_14:
            speedStr = NSLocalizedString(@"printspeed_14", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTSPEED_15:
            speedStr = NSLocalizedString(@"printspeed_15", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTSPEED_16:
            speedStr = NSLocalizedString(@"printspeed_16", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTSPEED_17:
            speedStr = NSLocalizedString(@"printspeed_17", @"");
            break;
        default:
            break;
    }
    
    return speedStr;
}

- (NSString *)convertPrintDensityEnum2String:(int)dencityEnum {
    NSString *deinsityStr = @"invalid";
    switch (dencityEnum) {
        case EPOS2_PRINTER_SETTING_PRINTDENSITY_DIP:
            deinsityStr = NSLocalizedString(@"printdensity_DIP", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTDENSITY_70:
            deinsityStr = NSLocalizedString(@"printdensity_70", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTDENSITY_75:
            deinsityStr = NSLocalizedString(@"printdensity_75", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTDENSITY_80:
            deinsityStr = NSLocalizedString(@"printdensity_80", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTDENSITY_85:
            deinsityStr = NSLocalizedString(@"printdensity_85", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTDENSITY_90:
            deinsityStr = NSLocalizedString(@"printdensity_90", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTDENSITY_95:
            deinsityStr = NSLocalizedString(@"printdensity_95", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTDENSITY_100:
            deinsityStr = NSLocalizedString(@"printdensity_100", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTDENSITY_105:
            deinsityStr = NSLocalizedString(@"printdensity_105", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTDENSITY_110:
            deinsityStr = NSLocalizedString(@"printdensity_110", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTDENSITY_115:
            deinsityStr = NSLocalizedString(@"printdensity_115", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTDENSITY_120:
            deinsityStr = NSLocalizedString(@"printdensity_120", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTDENSITY_125:
            deinsityStr = NSLocalizedString(@"printdensity_125", @"");
            break;
        case EPOS2_PRINTER_SETTING_PRINTDENSITY_130:
            deinsityStr = NSLocalizedString(@"printdensity_130", @"");
            break;
        default:
            break;
    }
    
    return deinsityStr;
}

- (NSString *)convertPaperWidthEnum2String:(int)paperWidthEnum {
    NSString *paperWidthStr = @"invalid";
    switch (paperWidthEnum) {
        case EPOS2_PRINTER_SETTING_PAPERWIDTH_58_0:
            paperWidthStr = NSLocalizedString(@"paperwidth_58", @"");
            break;
        case EPOS2_PRINTER_SETTING_PAPERWIDTH_60_0:
            paperWidthStr = NSLocalizedString(@"paperwidth_60", @"");
            break;
        case EPOS2_PRINTER_SETTING_PAPERWIDTH_70_0:
            paperWidthStr = NSLocalizedString(@"paperwidth_70", @"");
            break;
        case EPOS2_PRINTER_SETTING_PAPERWIDTH_76_0:
            paperWidthStr = NSLocalizedString(@"paperwidth_76", @"");
            break;
        case EPOS2_PRINTER_SETTING_PAPERWIDTH_80_0:
            paperWidthStr = NSLocalizedString(@"paperwidth_80", @"");
            break;
        default:
            break;
    }
    
    return paperWidthStr;
}

- (int)convertPrintSpeedString2Enum:(NSString *)speedStr {
    int speedEnum = EPOS2_PRINTER_SETTING_PRINTSPEED_14;
    
    if([speedStr compare:NSLocalizedString(@"printspeed_1", @"")] == NSOrderedSame){
        speedEnum = EPOS2_PRINTER_SETTING_PRINTSPEED_1;
    }
    if([speedStr compare:NSLocalizedString(@"printspeed_2", @"")] == NSOrderedSame){
        speedEnum = EPOS2_PRINTER_SETTING_PRINTSPEED_2;
    }
    if([speedStr compare:NSLocalizedString(@"printspeed_3", @"")] == NSOrderedSame){
        speedEnum = EPOS2_PRINTER_SETTING_PRINTSPEED_3;
    }
    if([speedStr compare:NSLocalizedString(@"printspeed_4", @"")] == NSOrderedSame){
        speedEnum = EPOS2_PRINTER_SETTING_PRINTSPEED_4;
    }
    if([speedStr compare:NSLocalizedString(@"printspeed_5", @"")] == NSOrderedSame){
        speedEnum = EPOS2_PRINTER_SETTING_PRINTSPEED_5;
    }
    if([speedStr compare:NSLocalizedString(@"printspeed_6", @"")] == NSOrderedSame){
        speedEnum = EPOS2_PRINTER_SETTING_PRINTSPEED_6;
    }
    if([speedStr compare:NSLocalizedString(@"printspeed_7", @"")] == NSOrderedSame){
        speedEnum = EPOS2_PRINTER_SETTING_PRINTSPEED_7;
    }
    if([speedStr compare:NSLocalizedString(@"printspeed_8", @"")] == NSOrderedSame){
        speedEnum = EPOS2_PRINTER_SETTING_PRINTSPEED_8;
    }
    if([speedStr compare:NSLocalizedString(@"printspeed_9", @"")] == NSOrderedSame){
        speedEnum = EPOS2_PRINTER_SETTING_PRINTSPEED_9;
    }
    if([speedStr compare:NSLocalizedString(@"printspeed_10", @"")] == NSOrderedSame){
        speedEnum = EPOS2_PRINTER_SETTING_PRINTSPEED_10;
    }
    if([speedStr compare:NSLocalizedString(@"printspeed_11", @"")] == NSOrderedSame){
        speedEnum = EPOS2_PRINTER_SETTING_PRINTSPEED_11;
    }
    if([speedStr compare:NSLocalizedString(@"printspeed_12", @"")] == NSOrderedSame){
        speedEnum = EPOS2_PRINTER_SETTING_PRINTSPEED_12;
    }
    if([speedStr compare:NSLocalizedString(@"printspeed_13", @"")] == NSOrderedSame){
        speedEnum = EPOS2_PRINTER_SETTING_PRINTSPEED_13;
    }
    if([speedStr compare:NSLocalizedString(@"printspeed_14", @"")] == NSOrderedSame){
        speedEnum = EPOS2_PRINTER_SETTING_PRINTSPEED_14;
    }
    if([speedStr compare:NSLocalizedString(@"printspeed_15", @"")] == NSOrderedSame){
        speedEnum = EPOS2_PRINTER_SETTING_PRINTSPEED_15;
    }
    if([speedStr compare:NSLocalizedString(@"printspeed_16", @"")] == NSOrderedSame){
        speedEnum = EPOS2_PRINTER_SETTING_PRINTSPEED_16;
    }
    if([speedStr compare:NSLocalizedString(@"printspeed_17", @"")] == NSOrderedSame){
        speedEnum = EPOS2_PRINTER_SETTING_PRINTSPEED_17;
    }
    
    return speedEnum;
}

- (int)convertPrintDeinsityString2Enum:(NSString *)densityStr {
    int densityEnum = EPOS2_PRINTER_SETTING_PRINTDENSITY_DIP;
    
    if([densityStr compare:NSLocalizedString(@"printdensity_DIP", @"")] == NSOrderedSame){
        densityEnum = EPOS2_PRINTER_SETTING_PRINTDENSITY_DIP;
    }
    if([densityStr compare:NSLocalizedString(@"printdensity_70", @"")] == NSOrderedSame){
        densityEnum = EPOS2_PRINTER_SETTING_PRINTDENSITY_70;
    }
    if([densityStr compare:NSLocalizedString(@"printdensity_75", @"")] == NSOrderedSame){
        densityEnum = EPOS2_PRINTER_SETTING_PRINTDENSITY_75;
    }
    if([densityStr compare:NSLocalizedString(@"printdensity_80", @"")] == NSOrderedSame){
        densityEnum = EPOS2_PRINTER_SETTING_PRINTDENSITY_80;
    }
    if([densityStr compare:NSLocalizedString(@"printdensity_85", @"")] == NSOrderedSame){
        densityEnum = EPOS2_PRINTER_SETTING_PRINTDENSITY_85;
    }
    if([densityStr compare:NSLocalizedString(@"printdensity_90", @"")] == NSOrderedSame){
        densityEnum = EPOS2_PRINTER_SETTING_PRINTDENSITY_90;
    }
    if([densityStr compare:NSLocalizedString(@"printdensity_95", @"")] == NSOrderedSame){
        densityEnum = EPOS2_PRINTER_SETTING_PRINTDENSITY_95;
    }
    if([densityStr compare:NSLocalizedString(@"printdensity_100", @"")] == NSOrderedSame){
        densityEnum = EPOS2_PRINTER_SETTING_PRINTDENSITY_100;
    }
    if([densityStr compare:NSLocalizedString(@"printdensity_105", @"")] == NSOrderedSame){
        densityEnum = EPOS2_PRINTER_SETTING_PRINTDENSITY_105;
    }
    if([densityStr compare:NSLocalizedString(@"printdensity_110", @"")] == NSOrderedSame){
        densityEnum = EPOS2_PRINTER_SETTING_PRINTDENSITY_110;
    }
    if([densityStr compare:NSLocalizedString(@"printdensity_115", @"")] == NSOrderedSame){
        densityEnum = EPOS2_PRINTER_SETTING_PRINTDENSITY_115;
    }
    if([densityStr compare:NSLocalizedString(@"printdensity_120", @"")] == NSOrderedSame){
        densityEnum = EPOS2_PRINTER_SETTING_PRINTDENSITY_120;
    }
    if([densityStr compare:NSLocalizedString(@"printdensity_125", @"")] == NSOrderedSame){
        densityEnum = EPOS2_PRINTER_SETTING_PRINTDENSITY_125;
    }
    if([densityStr compare:NSLocalizedString(@"printdensity_130", @"")] == NSOrderedSame){
        densityEnum = EPOS2_PRINTER_SETTING_PRINTDENSITY_130;
    }
    
    return densityEnum;
}

- (int)convertPaperWidthString2Enum:(NSString *)widthStr {
    int widthEnum = EPOS2_PRINTER_SETTING_PAPERWIDTH_58_0;
    
    if([widthStr compare: NSLocalizedString(@"paperwidth_58", @"")] == NSOrderedSame){
        widthEnum = EPOS2_PRINTER_SETTING_PAPERWIDTH_58_0;
    }
    if([widthStr compare: NSLocalizedString(@"paperwidth_60", @"")] == NSOrderedSame){
        widthEnum = EPOS2_PRINTER_SETTING_PAPERWIDTH_60_0;
    }
    if([widthStr compare: NSLocalizedString(@"paperwidth_70", @"")] == NSOrderedSame){
        widthEnum = EPOS2_PRINTER_SETTING_PAPERWIDTH_70_0;
    }
    if([widthStr compare: NSLocalizedString(@"paperwidth_76", @"")] == NSOrderedSame){
        widthEnum = EPOS2_PRINTER_SETTING_PAPERWIDTH_76_0;
    }
    if([widthStr compare: NSLocalizedString(@"paperwidth_80", @"")] == NSOrderedSame){
        widthEnum = EPOS2_PRINTER_SETTING_PAPERWIDTH_80_0;
    }
    
    return widthEnum;
}

@end
