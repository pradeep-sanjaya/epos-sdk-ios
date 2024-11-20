#import "BeaconPrinterInfo.h"

@implementation BeaconPrinterInfo

-(id) init
{
    self = [super init];
    if (self) {
        self.beacon = nil;
        self.tag = 0;
        self.easyselectInfo = nil;
        self.reliable = NO;
    }
    
    return self;
}

@end
