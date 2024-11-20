//
//  MicrControl.m
//  ePOS2_HybridPrinter
//

#import "MicrControl.h"
#import "ShowMsg.h"

@implementation MicrControl

- (BOOL) insertPaper
{
    int result = EPOS2_SUCCESS;
    
    if(![super insertPaper]) {
        return NO;
    }
    
    micrData_ = @"";
    
    [self waitOnHybdReceiveStart];
    
    result = [hybridPrinter_ readMicrData:EPOS2_PARAM_DEFAULT timeout:EPOS2_PARAM_DEFAULT];
    if (result != EPOS2_SUCCESS) {
        [self signalOnHybdReceive];
        [ShowMsg showErrorEpos:result method:@"readMicrData"];
    }
    
    if(result == EPOS2_SUCCESS){
        result = [self waitOnHybdReceive];
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
    
    if(result == EPOS2_SUCCESS){
        result = [self waitOnHybdReceive];
        if(result == EPOS2_SUCCESS) {
            [self waitOnEject];
        }
        else{
            [self signalOnEject];
        }
    }
    else {
        [self signalOnHybdReceive];
        [self signalOnEject];
        [ShowMsg showErrorEpos:result method:@"ejectPaper"];
    }

    return (result == EPOS2_SUCCESS);
}

- (NSString*) getMicrData
{
    return micrData_;
}

- (void) onHybdReceive:(Epos2HybridPrinter *)hybridPrinterObj method:(int)method code:(int)code micrData:(NSString *)micrData status:(Epos2HybridPrinterStatusInfo *)status
{
    if(method == EPOS2_METHOD_READMICRDATA){
        micrData_ = micrData;
    }
    
    [super onHybdReceive:hybridPrinterObj
                  method:method
                    code:code
                micrData:micrData
                  status:status];
}

@end

