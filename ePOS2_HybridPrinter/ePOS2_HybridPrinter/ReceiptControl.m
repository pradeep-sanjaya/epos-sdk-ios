//
//  ReceiptControl.m
//  ePOS2_HybridPrinter
//

#import <Foundation/Foundation.h>
#import "ReceiptControl.h"
#import "ShowMsg.h"

@implementation ReceiptControl

- (BOOL) addData
{
    int result = EPOS2_SUCCESS;
    NSDate *nsDate = [NSDate date];
    
    if(hybridPrinter_ == nil) {
        return NO;
    }
    
    result = [hybridPrinter_ addFeedLine:3];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEposOnMainThread:result method:@"addFeedLine"];
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addTextFont:EPOS2_FONT_B];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addTextFont"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addTextAlign:EPOS2_ALIGN_CENTER];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addTextAlign"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addLogo:48 key2:48];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addLogo"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addTextStyle:EPOS2_FALSE ul:EPOS2_FALSE em:EPOS2_TRUE color:EPOS2_COLOR_1];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addTextStyle"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addText:@"( 555 ) 555 - 5555\n"];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addText:@"SHIOJIRI BEACH, 12\n\n"];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addText:@"TAX INCLUDE\n\n"];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addTextAlign:EPOS2_ALIGN_LEFT];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addTextAlign"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addTextStyle:EPOS2_FALSE ul:EPOS2_FALSE em:EPOS2_FALSE color:EPOS2_COLOR_1];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addTextStyle"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addText:@"#ORD 24 -REG 02- "];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        NSDateFormatter *formatDmyHms = [[NSDateFormatter alloc] init];
        formatDmyHms.dateFormat = @"dd/MM/yyyy HH:mm:ss";
        formatDmyHms.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        NSString *dmyHmsString = [formatDmyHms stringFromDate:nsDate];
        
        result = [hybridPrinter_ addText:dmyHmsString];
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
        result = [hybridPrinter_ addText:@"QTY ITEM                         TOTAL\n"];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addText:@"  1 LRG ORANGE                    2.25\n"];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addText:@"  4 YASHI NUGGETS                 2.40\n"];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addText:@"  1 PREMIUM YASHI SALAD           3.50\n"];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addText:@"  3 YASHI BURGER                 10.50\n"];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addText:@"  1 LRG YASHI FRENCH FRIES        1.75\n"];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addText:@"  1 SMILE                         0.00\n\n"];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addText:@"SUB TOTAL                        20.40\n"];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addText:@"TAKE OUT TAX                      3.06\n"];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addText:@"                                  ----\n"];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addText:@"                                 23.46\n\n"];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addText:@"CASH TENDERED                    24.00\n"];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addText:@"CHANGE                             .54\n"];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addText:@"        THANK YOU PLEASE CALL AGAIN   \n\n"];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addText:@"------------------------------------------\n"];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addText"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addFeedLine:2];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addFeedLine"];
        }
    }
    
    if (result == EPOS2_SUCCESS) {
        result = [hybridPrinter_ addCut:EPOS2_CUT_NO_FEED];
        if (result != EPOS2_SUCCESS) {
            [ShowMsg showErrorEposOnMainThread:result method:@"addCut"];
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
    else {
        result = [self waitOnHybdReceive];
    }
    
    return (result == EPOS2_SUCCESS);
}


- (BOOL) selectPaperType
{
    int result = EPOS2_SUCCESS;
    
    if(hybridPrinter_ == nil){
        return NO;
    }
    
    result = [hybridPrinter_ selectPaperType:EPOS2_PAPER_TYPE_RECEIPT];
    if (result != EPOS2_SUCCESS) {
        [ShowMsg showErrorEposOnMainThread:result method:@"selectPaperType"];
    }
    
    return (result == EPOS2_SUCCESS);
}

@end
