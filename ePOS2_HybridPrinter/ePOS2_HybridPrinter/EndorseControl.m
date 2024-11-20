//
//  EndorseControl.m
//  ePOS2_HybridPrinter
//

#import <Foundation/Foundation.h>
#import "EndorseControl.h"
#import "ShowMsg.h"

@implementation EndorseControl

- (BOOL) addData
{
    int result = EPOS2_SUCCESS;
    NSDate *nsDate = [NSDate date];
    
    if(hybridPrinter_ == nil){
        return NO;
    }
    
    result = [hybridPrinter_ addText:@"FOR DEPOSIT ONLY FLESH*MART #5521\n"];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addText:@"TE#01 TR#8009 OP00000001  TIM"];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        NSDateFormatter *formatHm = [[NSDateFormatter alloc] init];
        formatHm.dateFormat = @"HH:mm";
        formatHm.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        NSString *hmString = [formatHm stringFromDate:nsDate];
        
        result = [hybridPrinter_ addText:hmString];
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
        result = [hybridPrinter_ addText:@" H ID#                    "];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        NSDateFormatter *formatDmy = [[NSDateFormatter alloc] init];
        formatDmy.dateFormat = @"dd/MM/yy";
        formatDmy.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        NSString *DmyString = [formatDmy stringFromDate:nsDate];
        
        result = [hybridPrinter_ addText:DmyString];
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
    
    if (result != EPOS2_SUCCESS) {
        [self clearData];
    }
    
    return (result == EPOS2_SUCCESS);
}

- (BOOL) selectPaperType
{
    int result = EPOS2_SUCCESS;
    
    if(hybridPrinter_ == nil){
        return NO;
    }
    
    result = [hybridPrinter_ selectPaperType:EPOS2_PAPER_TYPE_ENDORSE];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEposOnMainThread:result method:@"selectPaperType"];

    }
    
    return (result == EPOS2_SUCCESS);
}

@end
