#import <Foundation/Foundation.h>
#import "ePOS2.h"

@interface ShowMsg : NSObject
    //show method error
+ (void)showErrorEpos:(int)result method:(NSString *)method;

//show LineDisplay Result
+ (void)showResult:(int)code;

@end
