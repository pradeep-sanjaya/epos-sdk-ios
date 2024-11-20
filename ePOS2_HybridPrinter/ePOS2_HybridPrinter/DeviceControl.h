//
//  DeviceControl.h
//  ePOS2_HybridPrinter
//
#ifndef DeviceControl_h
#define DeviceControl_h

#import <Foundation/Foundation.h>
#import "ESemaphore.h"
#import "ePOS2.h"

@interface DeviceControl : NSObject <Epos2HybdStatusChangeDelegate, Epos2HybdReceiveDelegate>
{
    enum DeviceControlType : int {
        DEVICE_CONTROL_NONE = 0,
        DEVICE_CONTROL_RECEIPT,
        DEVICE_CONTROL_SLIP,
        DEVICE_CONTROL_ENDORSE,
        DEVICE_CONTROL_VALIDATION,
        DEVICE_CONTROL_MICR
    };
    Epos2HybridPrinter *hybridPrinter_;
    enum DeviceControlType firstControlType_;
    enum DeviceControlType nextControlType_;
    NSString* connectTarget_;
    NSString* warningText_;
    int errorCodeOnReceive_;
    ESemaphore *semaphoreOnReceive_;
    ESemaphore *semaphoreOnEjectPaper_;
    
}

- (id) initWithPrinter:(Epos2HybridPrinter*)hybridPrinter ConnectTarget:(NSString*)connectTarget;
- (void) setFirstControlType:(enum DeviceControlType) controlType;
- (void) setNextControlType:(enum DeviceControlType) controlType;
- (BOOL) checkErrorStatus;
- (BOOL) startSequence;
- (NSString*) getWarningText;

- (BOOL) addData;
- (void) clearData;
- (BOOL) connectHybridPrinter;
- (void) disconnectHybridPrinter;
- (BOOL) isPrintable:(Epos2HybridPrinterStatusInfo *)status;
- (BOOL) selectPaperType;
- (BOOL) sendData;
- (BOOL) insertPaper;
- (BOOL) ejectPaper;

- (void) waitOnHybdReceiveStart;
- (int) waitOnHybdReceive;
- (void) signalOnHybdReceive;
- (void) waitOnEjectStart;
- (void) waitOnEject;
- (void) signalOnEject;
- (NSString *)makeWarningsMessage:(Epos2HybridPrinterStatusInfo *)status;
- (NSString *)makeErrorMessage:(Epos2HybridPrinterStatusInfo *)status;
- (void) onHybdReceive:(Epos2HybridPrinter *)hybridPrinterObj method:(int)method code:(int)code micrData:(NSString *)micrData status:(Epos2HybridPrinterStatusInfo *)status;

@end
#endif /* DeviceControl_h */
