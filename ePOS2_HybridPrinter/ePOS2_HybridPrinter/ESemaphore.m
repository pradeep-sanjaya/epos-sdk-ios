//
//  ESemaphore.m
//  ePOS2_HybridPrinter
//

#import "ESemaphore.h"

@implementation ESemaphore
- (id) init
{
    self = [super init];
    if (self) {
        isWaiting_ = NO;
        semaphoreWaiting_= dispatch_semaphore_create(0);
        semaphoreNotify_= dispatch_semaphore_create(0);        
    }
    
    return self;
}

- (void) startWaiting
{
    isWaiting_ = YES;
    dispatch_queue_t waitDispatchQueue;
    waitDispatchQueue = dispatch_queue_create("com.epson.ESemaphore", NULL);
    dispatch_async(waitDispatchQueue, ^{
        dispatch_semaphore_wait(semaphoreWaiting_, DISPATCH_TIME_FOREVER);
        isWaiting_ = NO;
        dispatch_semaphore_signal(semaphoreNotify_);
    });
}

- (void) wait
{
    if(isWaiting_){
        dispatch_semaphore_wait(semaphoreNotify_, DISPATCH_TIME_FOREVER);
    }
}

- (void) signal
{
    if(isWaiting_){
        dispatch_semaphore_signal(semaphoreWaiting_);
    }
}

@end
