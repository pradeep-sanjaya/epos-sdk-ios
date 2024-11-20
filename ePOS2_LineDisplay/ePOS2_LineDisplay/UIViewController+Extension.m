//
//  UIViewController+Extension.m
//
//

#import "UIViewController+Extension.h"

@implementation UIViewController (Extension)

- (void)showIndicator:(NSString *)msg {
    if(msg == nil){
        return;
    }
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        view.center = CGPointMake(60, 30);
        [alertController.view addSubview:view];
        [view startAnimating];
        [self presentViewController:alertController animated:YES completion:nil];
        [self.view setNeedsDisplay];
    }];
}

- (void)hideIndicator {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self dismissViewControllerAnimated:true completion:nil];
            [self.view setNeedsDisplay];
    }];
}
@end
