#import "ShowMsg.h"
#import "ePOS2.h"

@interface ShowMsg()
+ (void)show:(NSString *)msg;
+ (NSString *)getEposErrorText:(int)result;
+ (NSString *)getEposResultText:(int)result;
@end

@implementation ShowMsg

+ (void)showErrorEpos:(int)resultCode method:(NSString *)method
{
    NSString *msg = [NSString stringWithFormat:@"%@\n%@\n\n%@\n%@\n",
                     NSLocalizedString(@"methoderr_errcode", @""),
                     [self getEposErrorText:resultCode],
                     NSLocalizedString(@"methoderr_method", @""),
                     method];
    [self show:msg];
}

+ (void)showResult:(int)code
{
    NSString *msg = [NSString stringWithFormat:@"%@\n%@\n",
                     NSLocalizedString(@"statusmsg_result", @""),
                     [self getEposResultText:code]];
    [self show:msg];
}

//show alart view
+ (void)show:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:nil
                          message:msg
                          delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil
                         ];
    [alert show];
}

//convert Epos2 Error to text
+ (NSString *)getEposErrorText:(int)error
{
    NSString *errText = @"";
    switch (error) {
        case EPOS2_SUCCESS:
            errText = @"SUCCESS";
            break;
        case EPOS2_ERR_PARAM:
            errText = @"ERR_PARAM";
            break;
        case EPOS2_ERR_TIMEOUT:
            errText = @"ERR_TIMEOUT";
            break;
        case EPOS2_ERR_CONNECT:
            errText = @"ERR_CONNECT";
            break;
        case EPOS2_ERR_MEMORY:
            errText = @"ERR_MEMORY";
            break;
        case EPOS2_ERR_ILLEGAL:
            errText = @"ERR_ILLEGAL";
            break;
        case EPOS2_ERR_PROCESSING:
            errText = @"ERR_PROCESSING";
            break;
        case EPOS2_ERR_NOT_FOUND:
            errText = @"ERR_NOT_FOUND";
            break;
        case EPOS2_ERR_IN_USE:
            errText = @"ERR_IN_USE";
            break;
        case EPOS2_ERR_TYPE_INVALID:
            errText = @"ERR_TYPE_INVALID";
            break;
        case EPOS2_ERR_DISCONNECT:
            errText = @"ERR_DISCONNECT";
            break;
        case EPOS2_ERR_ALREADY_OPENED:
            errText = @"ERR_ALREADY_OPENED";
            break;
        case EPOS2_ERR_ALREADY_USED:
            errText = @"ERR_ALREADY_USED";
            break;
        case EPOS2_ERR_BOX_COUNT_OVER:
            errText = @"ERR_BOX_COUNT_OVER";
            break;
        case EPOS2_ERR_BOX_CLIENT_OVER:
            errText = @"ERR_BOXT_CLIENT_OVER";
            break;
        case EPOS2_ERR_FAILURE:
            errText = @"ERR_FAILURE";
            break;
        default:
            errText = [NSString stringWithFormat:@"%d", error];
            break;
    }
    return errText;
}

//convert Epos2 Result code to text
+ (NSString *)getEposResultText:(int)resultCode
{
    NSString *result = @"";
    switch (resultCode) {
        case EPOS2_CODE_SUCCESS:
            result = @"SUCCESS";
            break;
        case EPOS2_CODE_ERR_NOT_FOUND:
            result = @"ERR_NOT_FOUND";
            break;
        case EPOS2_CODE_ERR_FAILURE:
            result = @"ERR_FAILURE";
            break;
        default:
            result = [NSString stringWithFormat:@"%d", resultCode];
            break;
    }

    return result;
}

@end
