#import <Foundation/Foundation.h>

@interface ShowMsg : NSObject
    //show method error
+ (void)showErrorEpos:(int)result method:(NSString *)method;

//show CommBox Result
+ (void)showResult:(int)code;
@end
