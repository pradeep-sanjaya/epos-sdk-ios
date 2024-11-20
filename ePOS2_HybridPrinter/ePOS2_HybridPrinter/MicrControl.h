//
//  MicrControl.h
//  ePOS2_HybridPrinter
//

#ifndef MicrControl_h
#define MicrControl_h
#import <Foundation/Foundation.h>
#import "DeviceControl.h"

@interface MicrControl : DeviceControl
{
    NSString* micrData_;
}
- (NSString*) getMicrData;
@end
#endif /* MicrControl_h */
