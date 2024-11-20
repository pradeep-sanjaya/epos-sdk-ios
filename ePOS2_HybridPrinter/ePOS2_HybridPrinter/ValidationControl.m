//
//  ValidationControl.m
//  ePOS2_HybridPrinter
//

#import <Foundation/Foundation.h>
#import "ValidationControl.h"
#import "ShowMsg.h"

@implementation ValidationControl

- (BOOL) addData
{
    int result = EPOS2_SUCCESS;
    NSDate *nsDate = [NSDate date];
    
    if(hybridPrinter_ == nil){
        return NO;
    }
    
    result = [hybridPrinter_ addTextSize:2 height:2];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEposOnMainThread:result method:@"addTextSize"];
    }
    
    if(result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addText:@"SAVINGS - DEPOSIT           $500.00\n"];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if(result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addTextSize:1 height:1];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addTextSize"];
        }
    }
    
    if(result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addText:@"BALANCE: $ 3418.35\n"];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if(result == EPOS2_SUCCESS) {
        NSDateFormatter *formatDmyHm = [[NSDateFormatter alloc] init];
        formatDmyHm.dateFormat = @"dd/MM/yy HH:mm";
        formatDmyHm.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        NSString *dmyHmsString = [formatDmyHm stringFromDate:nsDate];
        
        result = [hybridPrinter_ addText:dmyHmsString];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if(result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addText:@" Branch: 32001  Teller: 10022\n"];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
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
    
    if(hybridPrinter_ == nil) {
        return NO;
    }
    
    result = [hybridPrinter_ selectPaperType:EPOS2_PAPER_TYPE_VALIDATION];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEposOnMainThread:result method:@"selectPaperType"];
    }
    
    return (result == EPOS2_SUCCESS);
}

@end
