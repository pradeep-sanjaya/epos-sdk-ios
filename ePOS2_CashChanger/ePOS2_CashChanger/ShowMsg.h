#import <Foundation/Foundation.h>
#import "ePOS2.h"

@interface ShowMsg : NSObject
    //show method error
+ (void)showErrorEpos:(int)resultCode method:(NSString *)method;
+ (void)showResult:(int)code;
+ (void)showResult:(int)code oposCode:(int)oposCode;
@end
