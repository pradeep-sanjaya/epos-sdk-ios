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
- (void)onGfeReceiveEPOS2SDKManager:(EPOS2SDKManager*)EPOS2SDKManager code:(int)code data:(NSString *)data;
- (void)onPtrReceiveEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager code:(int)code status:(Epos2PrinterStatusInfo *)status printJobId:(NSString *)printJobId;
- (void)onDispReceiveEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager code:(int)code;
- (void)onScanDataEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager scanData:(NSString *)scanData;
- (void)onFirmwareListDownloadEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager code:(int)code firmwareList:(NSMutableArray<Epos2FirmwareInfo *> *)firmwareList;
- (void)onFirmwareInformationReceiveEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager code:(int)code firmwareInfo:(Epos2FirmwareInfo *)firmwareInfo;
- (void)onFirmwareUpdateProgressEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager task:(NSString *)task progress:(float)progress;
- (void)onFirmwareUpdateEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager code:(int)code maxWaitTime:(int)maxWaitTime;
- (void)onUpdateVerifyEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager code:(int)code;
@end

@interface EPOS2SDKManager : NSObject< Epos2DiscoveryDelegate,Epos2GermanyFiscalElementReceiveDelegate,Epos2PtrReceiveDelegate,Epos2DispReceiveDelegate,Epos2ScanDelegate,Epos2FirmwareListDownloadDelegate, Epos2FirmwareInformationDelegate, Epos2FirmwareUpdateDelegate, Epos2VerifyeUpdateDelegate, Epos2ConnectionDelegate>{
    Epos2GermanyFiscalElement* gfe_;
    Epos2Printer* printer_;
    Epos2LineDisplay* display_;
    Epos2BarcodeScanner* scanner_;
}

@property (nonatomic, weak) id<SDKDelegate> delegate;
- (id)init;

-(BOOL)startDiscovery:(Epos2FilterOption *)filteroption;
-(BOOL)stopDiscovery;

- (BOOL)initializeGfeObject;
- (void)finalizeGfeObject;
- (BOOL)connectGermanyFiscalElement:(NSString *)target;
- (BOOL)disconnectGermanyFiscalElement;
- (BOOL)operateGermanyFiscalElement:(NSString*)jsonFunc timeout:(long)timeout;

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
- (BOOL)getPrinterFirmwareInfo:(long)timeout;
- (BOOL)downloadFirmwareList:(NSString *)firmwareUpdatePrinterModel option:(NSString *)option;
- (BOOL)updateFirmware:(Epos2FirmwareInfo *)targetFirmwareInfo;
- (BOOL)verifyUpdate:(Epos2FirmwareInfo *)targetFirmwareInfo;

- (BOOL)initializeDisplayObject;
- (void)finalizeDisplayObject;
- (BOOL)connectLineDisplay:(NSString *)target;
- (BOOL)disconnectLineDisplay;
- (BOOL)checkConnectionLineDisplay;
- (BOOL)sendDataLineDisplay;
- (BOOL)addInitializeLineDisplay;
- (BOOL)addSetCursorPositionLineDisplay:(long)x y:(long)y;
- (BOOL)addTextLineDisplay:(NSString*)data;
- (BOOL)indicateDisplay:(NSString *)data;

- (BOOL)initializeScannerObject;
- (void)finalizeScannerObject;
- (BOOL)connectBarcodeScanner:(NSString *)target;
- (BOOL)disconnectBarcodeScanner;

- (NSString *)makeMessage:(int)code;
- (NSString *)getEposResultText:(int)resultCode;
- (void)showError:(NSString*)errorDetail method:(NSString*)method;
- (NSString *)getEposBtErrorText:(int)error;

@end
