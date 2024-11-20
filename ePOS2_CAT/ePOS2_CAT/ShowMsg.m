#import "ShowMsg.h"

@interface ShowMsg()
+ (NSString *)getEposErrorText:(int)result;
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

+ (void)showResult:(int)code oposCode:(int)oposCode
{
    NSString *msg = [NSString stringWithFormat:@"%@\n%@\n\n%@\n%d\n",
                     NSLocalizedString(@"statusmsg_result", @""),
                     [self getEposResultText:code],
                     NSLocalizedString(@"opos_code", @""),
                     oposCode];

    [self show:msg];
}

//show alart view
+ (void)show:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:nil
                          message:msg
                          delegate:nil
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
        case EPOS2_CAT_CODE_SUCCESS:
            result = @"SUCCESS";
            break;
        case EPOS2_CAT_CODE_BUSY:
            result = @"BUSY";
            break;
        case EPOS2_CAT_CODE_EXCEEDING_LIMIT:
            result = @"EXCEEDING_LIMIT";
            break;
        case EPOS2_CAT_CODE_DISAGREEMENT:
            result = @"DISAGREEMENT";
            break;
        case EPOS2_CAT_CODE_INVALID_CARD:
            result = @"INVALID_CARD";
            break;
        case EPOS2_CAT_CODE_RESET:
            result = @"RESET";
            break;
        case EPOS2_CAT_CODE_ERR_CENTER:
            result = @"ERR_CENTER";
            break;
        case EPOS2_CAT_CODE_ERR_OPOSCODE:
            result = @"ERR_OPOSCODE";
            break;
        case EPOS2_CAT_CODE_ERR_PARAM:
            result = @"ERR_PARAM";
            break;
        case EPOS2_CAT_CODE_ERR_DEVICE:
            result = @"ERR_DEVICE";
            break;
        case EPOS2_CAT_CODE_ERR_SYSTEM:
            result = @"ERR_SYSTEM";
            break;
        case EPOS2_CAT_CODE_ERR_TIMEOUT:
            result = @"ERR_TIMEOUT";
            break;
        case EPOS2_CAT_CODE_ERR_FAILURE:
            result = @"ERR_FAILURE";
            break;
        case EPOS2_CAT_CODE_ERR_COMMAND:
            result = @"ERR_COMMAND";
            break;
        case EPOS2_CAT_CODE_ABORT_FAILURE:
            result = @"ABORT_FAILURE";
            break;
        default:
            result = [NSString stringWithFormat:@"%d", resultCode];
            break;
    }
    return result;
}

@end
