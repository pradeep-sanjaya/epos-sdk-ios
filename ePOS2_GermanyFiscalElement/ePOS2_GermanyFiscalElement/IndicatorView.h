#import <UIKit/UIKit.h>

@interface IndicatorView : UIView

- (void)show:(UIView*)base;
- (void)hide;

- (void)stopIndicator;
- (void)restartIndicator;

@end
