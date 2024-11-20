#import <CoreLocation/CLBeaconRegion.h>
#import "ePOSEasySelect.h"

@interface BeaconPrinterInfo : NSObject 

@property (nonatomic, copy) CLBeacon *beacon;
@property (nonatomic) NSInteger tag;
@property (nonatomic) BOOL reliable;

@property (nonatomic,strong) EposEasySelectInfo *easyselectInfo;

@end


