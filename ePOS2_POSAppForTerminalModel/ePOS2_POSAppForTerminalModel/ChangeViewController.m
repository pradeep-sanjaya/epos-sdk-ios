//
//  ChangeViewController.m
//  ePOS2_POSAppForTerminalModel
//
//
#import "ChangeViewController.h"
#import "OrdersViewController.h"
#import "AppDelegate.h"

@interface ChangeViewController()
@end

@implementation ChangeViewController
static dispatch_semaphore_t pauseDepositSemaphore;
static dispatch_semaphore_t endDepositSemaphore;

static const int64_t responseLimitTime = 15.0;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    ePOS2SDKManager = appDelegate.ePOS2SDKManager;
    enableDisplay = appDelegate.enableDisplay;
    enableCashChanger = appDelegate.enableCashChanger;
    itemList_ = appDelegate.eposPurchaseItemList;
    total = appDelegate.total;
    deposit = appDelegate.deposit;
    change = appDelegate.change;
    _textChange.text = [NSString stringWithFormat:@"%ld\n",appDelegate.change];
    _textChange.enabled = NO;
    
    queueForSDK = [[NSOperationQueue alloc] init];
    queueForSDK.maxConcurrentOperationCount = 1;
    ePOS2SDKManager.delegate = self;
    
    [queueForSDK addOperationWithBlock:^{

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self beginProcess];
            self->_textMessage.text = @"printing...";
        }];
        
        //display
        if(self->enableDisplay) {
            NSString* displayData = @"";
            displayData = [self->ePOS2SDKManager formatDisplayData:@"Deposit" value:self->deposit];
            displayData = [displayData stringByAppendingString:
                           [self->ePOS2SDKManager formatDisplayData:@"Change" value:self->change]];

            [self->ePOS2SDKManager indicateDisplay:displayData];
        }
        
        
        //Printer
        BOOL result;
        if([self createReceiptData]) {
            
            //Drawer
            [self->ePOS2SDKManager addPulsePrinter];
            
            result = [self->ePOS2SDKManager sendDataPrinter];
            
        }
        
        //CashChanger
        if(self->enableCashChanger){
            
            pauseDepositSemaphore = dispatch_semaphore_create(0);
            dispatch_time_t dispatch_Timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * responseLimitTime);
            [self->ePOS2SDKManager pauseDepositCashChanger];
            if(dispatch_semaphore_wait(pauseDepositSemaphore, dispatch_Timeout) != 0){
                [self errAlert2:@"error" msg:@"Callback isn't called"];
            }
            
            
            if(self->change == 0){
                [self->ePOS2SDKManager endDepositCashChanger:(int)EPOS2_DEPOSIT_NOCHANGE];
            }else{
                
                endDepositSemaphore = dispatch_semaphore_create(0);
                dispatch_time_t dispatch_Timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * responseLimitTime);
                [self->ePOS2SDKManager endDepositCashChanger:(int)EPOS2_DEPOSIT_CHANGE];
                if(dispatch_semaphore_wait(endDepositSemaphore, dispatch_Timeout) != 0){
                    [self errAlert2:@"error" msg:@"Callback isn't called"];
                }
                
                [self->ePOS2SDKManager dispenseChangeCashChanger:(long)self->change];
            }
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self endProcess];
        }];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

//Indicator
- (void)beginProcess
{
    if (Nil != indicator) {
        indicator = Nil;
    }
    indicator = [[IndicatorView alloc] init];
    [indicator show:[[UIApplication sharedApplication] keyWindow]];
}

- (void)endProcess
{
    if (Nil == indicator) {
        return;
    }
    [indicator hide];
    indicator = nil;
}

- (void)onReconnectingEPOS2SDKManager
{
    //Note: If RECONNECTING event occur, you should not call connect or disconnect API untill RECONNECT or DISCONNECT event occues.
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self beginProcess];
    }];
}

- (void)onReconnectEPOS2SDKManager
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self endProcess];
    }];
}

- (void)onDisconnectEPOS2SDKManager
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self endProcess];
        [self errAlert:@"Faild to connect printer" msg:@"Please re-connect printer"];
    }];
}

- (void)onLogEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager apiLog:(NSString *)apiLog
{
    if(apiLog !=nil){
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.ordersViewController.textApiLog.text = [appDelegate.ordersViewController.textApiLog.text stringByAppendingString:apiLog];
            [appDelegate.ordersViewController scrollText:appDelegate.ordersViewController.textApiLog];
        }];
    }
}

- (void)onPtrReceiveEPOS2SDKManager:(EPOS2SDKManager  *)ePOS2SDKManager code:(int)code status:(Epos2PrinterStatusInfo *)status printJobId:(NSString *)printJobId;
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self->_textMessage.text = [self->ePOS2SDKManager makeMessage:code];
    }];
}

- (void)errAlert:(NSString *)title msg:(NSString *)msg
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        //close PayViewController and ChangeViewController
        UIViewController* previousViewController = [[self presentingViewController] presentingViewController];
        [previousViewController dismissViewControllerAnimated:NO completion:nil];
        
        //close OrdersViewController
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.ordersViewController.navigationController popViewControllerAnimated:YES];
    }]];
    
    [self presentViewController:alert animated:YES completion:^{
    }];
}

- (void)errAlert2:(NSString *)title msg:(NSString *)msg
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }]];
    
    [self presentViewController:alert animated:YES completion:^{
    }];
}


- (IBAction)reprintButtonDidPush:(id)sender
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self->_textMessage.text = @"printing...";
    }];
    [queueForSDK addOperationWithBlock:^{
        [self->ePOS2SDKManager sendDataPrinter];
    }];
}

- (IBAction)doneButtonDidPush:(id)sender
{
    [ePOS2SDKManager clearCommandBufferPrinter];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.delegate = appDelegate.ordersViewController;
    if ([self->_delegate respondsToSelector:@selector(modalViewWillClose)]){
        [self->_delegate modalViewWillClose];
    }
    
    //close view
    UIViewController* previousViewController = [[self presentingViewController] presentingViewController];
    [previousViewController dismissViewControllerAnimated:NO completion:nil];
}

- (BOOL)createReceiptData
{
    NSMutableString* receiptData = [[NSMutableString alloc] init];
    if(receiptData != nil) {
        
        // Prefix
        [ePOS2SDKManager addTextAlignPrinter:EPOS2_ALIGN_CENTER];
        [ePOS2SDKManager addImagePrinter];
        [ePOS2SDKManager addFeedLinePrinter:1];
        
        [receiptData appendString:@"THE STORE 123 (555) 555 – 5555\n"];
        [receiptData appendString:@"STORE DIRECTOR – John Smith\n"];
        [receiptData appendString:@"\n"];
        [receiptData appendString:@"7/01/07 16:58 6153 05 0191 134\n"];
        [receiptData appendString:@"ST# 21 OP# 001 TE# 01 TR# 747\n"];
        [receiptData appendString:@"------------------------------\n"];
        [ePOS2SDKManager addTextPrinter:receiptData];
        [receiptData setString:@""];
        
        // Receipt Data
        [ePOS2SDKManager addTextAlignPrinter:EPOS2_ALIGN_LEFT];
        [receiptData appendString:[itemList_ createReceiptData]];
        [ePOS2SDKManager addTextPrinter:receiptData];
        [receiptData setString:@""];
        
        [ePOS2SDKManager addTextAlignPrinter:EPOS2_ALIGN_CENTER];
        [receiptData appendString:@"------------------------------\n"];
        [ePOS2SDKManager addTextPrinter:receiptData];
        [receiptData setString:@""];
        
        // Suffix
        [ePOS2SDKManager addTextSizePrinter:2 height:2];
        [receiptData appendString:@"TOTAL         ¥"];
        [receiptData appendString:[itemList_ createTotalAmountData]];
        [receiptData appendString:@"\n"];
        [ePOS2SDKManager addTextPrinter:receiptData];
        [receiptData setString:@""];
        
        [ePOS2SDKManager addTextAlignPrinter:EPOS2_ALIGN_LEFT];
        [ePOS2SDKManager addTextSizePrinter:1 height:1];
        [ePOS2SDKManager addFeedLinePrinter:1];
        [receiptData appendString:@"       DEPOSIT                    ¥"];
        [receiptData appendString:[NSString stringWithFormat:@"%ld\n",deposit]];
        [receiptData appendString:@"\n"];
        
        [receiptData appendString:@"       CHANGE                     ¥"];
        [receiptData appendString:[NSString stringWithFormat:@"%ld\n",change]];
        [receiptData appendString:@"\n"];
        
        [ePOS2SDKManager addTextPrinter:receiptData];
        [receiptData setString:@""];
        
        [ePOS2SDKManager addTextAlignPrinter:EPOS2_ALIGN_CENTER];
        [receiptData appendString:@"------------------------------\n"];
        [receiptData appendString:@"Purchased item total number\n"];
        [receiptData appendString:@"Sign Up and Save !\n"];
        [receiptData appendString:@"With Preferred Saving Card\n"];
        [ePOS2SDKManager addTextPrinter:receiptData];
        [receiptData setString:@""];
        
        [ePOS2SDKManager addFeedLinePrinter:2];
        [ePOS2SDKManager addBarcodePrinter];
        [ePOS2SDKManager addCutPrinter];
    }
    return YES;
}
- (void)onCChangerDepositEPOS2SDKManager:(EPOS2SDKManager *)EPOS2SDKManager code:(int)code status:(int)status amount:(long)amount data:(NSDictionary *)data
{
    int oposCode = 0;
    if(code != EPOS2_CCHANGER_CODE_SUCCESS){
        switch(code){
            case EPOS2_CCHANGER_CODE_ERR_OPOSCODE:
                oposCode = [ePOS2SDKManager getOposErrorCodeCashChanger];
                // Please add error handling
                break;
            case EPOS2_CCHANGER_CODE_BUSY:{
                [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
                    [self->ePOS2SDKManager endDepositCashChanger:(int)EPOS2_DEPOSIT_CHANGE];
                }];
                break;
            }
            default:
                break;
        }
    }else{
        switch(status){
            case EPOS2_CCHANGER_STATUS_BUSY:{
                // Please add proccessing
                break;
            }
            case EPOS2_CCHANGER_STATUS_PAUSE:{//pauseDeposit
                if(pauseDepositSemaphore != nil) {
                    dispatch_semaphore_signal(pauseDepositSemaphore);
                }
                break;
            }
            case EPOS2_CCHANGER_STATUS_END:{
                if(endDepositSemaphore != nil) {
                    dispatch_semaphore_signal(endDepositSemaphore);
                }
                break;
            }
            case EPOS2_CCHANGER_STATUS_ERR:{
                // Please add proccessing
                break;
            }
            default:{
                break;
            }
        }
    }
}

- (void) onCChangerDispenseEPOS2SDKManager:(EPOS2SDKManager  *)ePOS2SDKManager code:(int)code
{
    int oposCode = 0;
    if(code != EPOS2_CCHANGER_CODE_SUCCESS){
        switch(code){
            case EPOS2_CCHANGER_CODE_ERR_OPOSCODE:
                oposCode = [ePOS2SDKManager getOposErrorCodeCashChanger];
                // Please add error handling
                break;
            case EPOS2_CCHANGER_CODE_BUSY:{
                [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
                    [self->ePOS2SDKManager dispenseChangeCashChanger:(long)self->change];
                }];
                break;
            }
            default:
                break;
        }
    }else{
        // Please add processing
    }
}

@end
