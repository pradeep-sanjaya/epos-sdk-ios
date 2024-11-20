#import <Foundation/Foundation.h>
#import "ePOS2.h"

@interface ShowMsg : NSObject
// show method error
+ (void)showErrorEpos:(int)result method:(NSString *)method;
+ (void)showErrorEposOnMainThread:(int)result method:(NSString *)method;

+ (void)showErrorEposBt:(int)result method:(NSString *)method;
+ (void)showErrorEposBtOnMainThread:(int)result method:(NSString *)method;


// show HybridPrinter Result
+ (void)showResult:(int)code errMsg:(NSString *)errMsg;
+ (void)showResultOnMainThread:(int)code errMsg:(NSString *)errMsg;

// show message
+ (void)show:(NSString *)msg;
+ (void)showOnMainThread:(NSString*)msg;
@end
