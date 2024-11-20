#ifndef PrinterInfo_h
#define PrinterInfo_h

@interface PrinterInfo : NSObject
+ (PrinterInfo *)sharedPrinterInfo;

@property int printerSeries;
@property int lang;
@property NSString* target;
@property NSString* ip;

@end

#endif /* PrinterInfo_h */
