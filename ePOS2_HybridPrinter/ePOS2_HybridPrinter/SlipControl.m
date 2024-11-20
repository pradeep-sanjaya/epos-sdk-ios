//
//  SlipControl.m
//  ePOS2_HybridPrinter
//

#import <Foundation/Foundation.h>
#import "SlipControl.h"
#import "ShowMsg.h"

@implementation SlipControl

- (BOOL) addData
{
    int result = EPOS2_SUCCESS;
    
    if(![super addData]) {
        return NO;
    }
    
    result = [hybridPrinter_ addPageBegin];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEposOnMainThread:result method:@"addPageBegin"];
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addTextFont:EPOS2_FONT_B];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addTextFont"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addPageDirection:EPOS2_DIRECTION_BOTTOM_TO_TOP];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addPageDirection"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addPageArea:188 y:0 width:340 height:687];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addPageArea"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addPagePosition:300 y:55];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addPagePosition"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        NSDateFormatter *formatMdy = [[NSDateFormatter alloc] init];
        formatMdy.dateStyle = NSDateFormatterMediumStyle;
        formatMdy.timeStyle = NSDateFormatterNoStyle;
        formatMdy.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        
        NSDate *nsDate = [NSDate date];
        NSString *mdyString = [formatMdy stringFromDate:nsDate];
        
        result = [hybridPrinter_ addText:mdyString];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addFeedLine:1];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addFeedLine"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addPagePosition:10 y:125];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addPagePosition"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addText:@"CASH                                         150.00\n"];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addPagePosition:10 y:170];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addPagePosition"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addText:@"One hundred fifty and zero cents\n"];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addPageEnd];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addPageEnd"];
        }
    }
    
    if (result != EPOS2_SUCCESS) {
        [self clearData];
    }

    return (result == EPOS2_SUCCESS);
}

- (void) clearData
{
    int result = EPOS2_SUCCESS;
    
    if(hybridPrinter_ == nil){
        return;
    }
    
    result = [hybridPrinter_ clearCommandBuffer];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEposOnMainThread:result method:@"clearCommandBuffer"];
    }
}

- (BOOL) sendData
{
    int result = EPOS2_SUCCESS;
    
    if(![super sendData]) {
        return NO;
    }
    
    [self waitOnHybdReceiveStart];
    
    result = [hybridPrinter_ sendData:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [self signalOnHybdReceive];
        [ShowMsg showErrorEposOnMainThread:result method:@"sendData"];
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [self waitOnHybdReceive];
    }

    return (result == EPOS2_SUCCESS);
}

- (BOOL) insertPaper
{
    int result = EPOS2_SUCCESS;
    
    if(![super insertPaper]) {
        return NO;
    }
    
    if(firstControlType_ != DEVICE_CONTROL_NONE) {
        [self waitOnHybdReceiveStart];
        
        result = [hybridPrinter_ waitInsertion:EPOS2_PARAM_DEFAULT];
        if(result == EPOS2_SUCCESS){
            result = [self waitOnHybdReceive];
        }
        else {
            [self signalOnHybdReceive];
            [ShowMsg showErrorEposOnMainThread:result method:@"waitInsertion"];
        }
    }
    
    return (result == EPOS2_SUCCESS);
}

- (BOOL) selectPaperType
{
    int result = EPOS2_SUCCESS;
    
    if(![super selectPaperType]) {
        return NO;
    }
    
    result = [hybridPrinter_ selectPaperType:EPOS2_PAPER_TYPE_SLIP];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEposOnMainThread:result method:@"selectPaperType"];
    }
    
    return (result == EPOS2_SUCCESS);
}

- (BOOL) ejectPaper
{
    int result = EPOS2_SUCCESS;
    
    if(![super ejectPaper]) {
        return NO;
    }
    
    [self waitOnHybdReceiveStart];
    [self waitOnEjectStart];
    
    result = [hybridPrinter_ ejectPaper];
    if (result != EPOS2_SUCCESS) {
        [self signalOnHybdReceive];
        [self signalOnEject];
        [ShowMsg showErrorEposOnMainThread:result method:@"ejectPaper"];
    }
    else {
        result = [self waitOnHybdReceive];
        if (result != EPOS2_SUCCESS) {
            [self signalOnEject];
        }
        else {
            [self waitOnEject];
        }
    }
    
    return (result == EPOS2_SUCCESS);
}

@end

