//
#include <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


#if !TARGET_IPHONE_SIMULATOR
#define HAS_AVFF 1
#endif

@protocol QRCodeCaptureDelegate <NSObject>
@optional
- (void)didScanResult:(NSString *)result;
@end

@interface QRCodeCapture : NSObject

@property(nonatomic, assign) id<QRCodeCaptureDelegate> delegate;
- (id)init;
- (BOOL)connectCaptureSettion;
- (void)startCapture:(UIView*)targetView scanDelegate:(id<QRCodeCaptureDelegate>)scanDelegate;
- (void)stopCapture;
- (void)disConnectCaptureSettion;
- (void)setFrameColor:(UIColor*)color;
@end

