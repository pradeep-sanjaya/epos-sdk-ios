//
//  ESemaphore.h
//  ePOS2_HybridPrinter
//

#ifndef ESemaphore_h
#define ESemaphore_h
#import <Foundation/Foundation.h>

@interface ESemaphore : NSObject
{
    BOOL isWaiting_;
    dispatch_semaphore_t semaphoreWaiting_;
    dispatch_semaphore_t semaphoreNotify_;
}

- (void) startWaiting;
- (void) wait;
- (void) signal;
@end

#endif /* ESemaphore_h */
