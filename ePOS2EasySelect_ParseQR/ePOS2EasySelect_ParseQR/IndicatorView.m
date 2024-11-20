#import "IndicatorView.h"

@interface IndicatorView () {
    UIActivityIndicatorView *indicator_;
}
@end

@implementation IndicatorView

- (void)dealloc
{
    [self hide];
}

- (void)show:(UIView *)base
{
    if (!base) return;

    if (indicator_) return;

    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.frame = CGRectMake(0, 0, MAX(base.bounds.size.width, base.bounds.size.height),
                            MAX(base.bounds.size.width, base.bounds.size.height));
    self.hidden = NO;
    [base addSubview:self];

    indicator_ =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator_.bounds = CGRectMake(0, 0, 36, 36);
    indicator_.center = base.center;
    [self addSubview:indicator_];

    [indicator_ startAnimating];
}

- (void)hide
{
    if (!indicator_) {
        return;
    }

    [indicator_ stopAnimating];
    [self removeFromSuperview];
    indicator_ = nil;
}

@end
