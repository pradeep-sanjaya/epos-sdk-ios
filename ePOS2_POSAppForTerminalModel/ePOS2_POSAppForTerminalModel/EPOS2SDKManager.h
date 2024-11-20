//
//  ePOS2SDKManager.h
//  ePOS2_POSAppForTerminalModel
//
//

#import <Foundation/Foundation.h>
#import "IndicatorView.h"
#import "ePOS2.h"


@class EPOS2SDKManager;
@protocol SDKDelegate <NSObject>
@optional
- (void)onDiscoveryEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager deviceInfo:(Epos2DeviceInfo *)deviceInfo;
- (void)onReconnectingEPOS2SDKManager;
- (void)onReconnectEPOS2SDKManager;
- (void)onDisconnectEPOS2SDKManager;
- (void)onLogEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager apiLog:(NSString *)apiLog;
- (void)onPtrReceiveEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager code:(int)code status:(Epos2PrinterStatusInfo *)status printJobId:(NSString *)printJobId;
- (void)onDispReceiveEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager code:(int)code;
- (void)onScanDataEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager scanData:(NSString *)scanData;
- (void)onCChangerDepositEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager code:(int)code status:(int)status amount:(long)amount data:(NSDictionary *)data;
- (void) onCChangerDispenseEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager code:(int)code;
@end

@interface EPOS2SDKManager : NSObject< Epos2DiscoveryDelegate,Epos2PtrReceiveDelegate,Epos2DispReceiveDelegate,Epos2ScanDelegate,Epos2ConnectionDelegate,Epos2CChangerDepositDelegate,Epos2CChangerDispenseDelegate>{
    Epos2Printer* printer_;
    Epos2LineDisplay* display_;
    Epos2BarcodeScanner* scanner_;
    Epos2CashChanger* cashChanger_;
    
    NSString *apiLog;
}

@property (nonatomic, weak) id<SDKDelegate> delegate;
- (id)init;

-(BOOL)startDiscovery:(Epos2FilterOption *)filteroption;
-(BOOL)stopDiscovery;

- (BOOL)initializePrinterObject:(int)printerSeries_;
- (void)finalizePrinterObject;
- (BOOL)connectPrinter:(NSString *)target;
- (BOOL)disconnectPrinter;
- (BOOL)sendDataPrinter;
- (void)clearCommandBufferPrinter;
- (BOOL)addFeedLinePrinter:(long)line;
- (BOOL)addTextAlignPrinter:(int)align;
- (BOOL)addTextSizePrinter:(long)width height:(long)height;
- (BOOL)addTextPrinter:(NSString*)text;
- (BOOL)addImagePrinter;
- (BOOL)addBarcodePrinter;
- (BOOL)addCutPrinter;
- (BOOL)addPulsePrinter;

- (BOOL)initializeDisplayObject;
- (void)finalizeDisplayObject;
- (BOOL)connectLineDisplay:(NSString *)target;
- (BOOL)disconnectLineDisplay;
- (BOOL)checkConnectionLineDisplay;
- (BOOL)sendDataLineDisplay;
- (BOOL)addInitializeLineDisplay;
- (BOOL)addSetCursorPositionLineDisplay:(long)x y:(long)y;
- (BOOL)addTextLineDisplay:(NSString*)data;
- (NSString *)formatDisplayData:(NSString*)prefix value:(long)value;
- (BOOL)indicateDisplay:(NSString *)data;

- (BOOL)initializeScannerObject;
- (void)finalizeScannerObject;
- (BOOL)connectBarcodeScanner:(NSString *)target;
- (BOOL)disconnectBarcodeScanner;

- (BOOL)initializeCashChangerObject;
- (void)finalizeCashChangerObject;
- (BOOL)connectCashChanger:(NSString *)target;
- (BOOL)disconnectCashChanger;
- (BOOL)beginDepositCashChanger;
- (BOOL)pauseDepositCashChanger;
- (BOOL)endDepositCashChanger:(int)config;
- (int) getOposErrorCodeCashChanger;
- (BOOL)dispenseChangeCashChanger:(long)cash;

- (NSString *)makeMessage:(int)code;

@end
