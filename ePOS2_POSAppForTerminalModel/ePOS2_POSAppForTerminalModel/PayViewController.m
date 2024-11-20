//
//  PayViewController.m
//  ePOS2_POSAppForTerminalModel
//
//
#import "PayViewController.h"
#import "AppDelegate.h"
#import "ePOS2.h"

@interface PayViewController()
@end

@implementation PayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setDoneToolbar];
    _textDeposit.keyboardType = UIKeyboardTypeDecimalPad;
    _textTotalPay.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    itemList_ = appDelegate.eposPurchaseItemList;
    ePOS2SDKManager = appDelegate.ePOS2SDKManager;
    enableDisplay = appDelegate.enableDisplay;
    enableCashChanger = appDelegate.enableCashChanger;
    ePOS2SDKManager.delegate = self;
    queueForSDK = [[NSOperationQueue alloc] init];
    queueForSDK.maxConcurrentOperationCount = 1;
    
    _textTotalPay.text = [itemList_ createTotalAmountData];
    _textDeposit.text = @"0";
    
    total = [itemList_ getTotalAmountData];
    deposit = [_textDeposit.text longLongValue];
    change = deposit - total;
    if(change < 0){
        _buttonDone.enabled = NO;
    }else{
        self->_buttonDone.enabled = YES;
    }
    
    //LineDisplay
    if(enableDisplay) {
        NSString* displayData = @"";
        displayData = [ePOS2SDKManager formatDisplayData:@"Total" value:[self->itemList_ getTotalAmountData]];
        [queueForSDK addOperationWithBlock:^{
            [self->ePOS2SDKManager indicateDisplay:displayData];
        }];
    }
    
    //cashChanger
    if(enableCashChanger){
        _buttonCancel.enabled = NO;
        sumDepositCashChanger = 0;
        [queueForSDK addOperationWithBlock:^{
            [self->ePOS2SDKManager beginDepositCashChanger];
        }];
    }
    
    
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

- (void)setDoneToolbar
{
    UIToolbar *doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    doneToolbar.barStyle = UIBarStyleBlackTranslucent;
    
    [doneToolbar sizeToFit];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneKeyboard:)];
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects:space, doneButton, nil];
    [doneToolbar setItems:items animated:YES];
    _textDeposit.inputAccessoryView = doneToolbar;
}

- (void)doneKeyboard:(id)sender
{
    [_textDeposit resignFirstResponder];
    total = [itemList_ getTotalAmountData];
    deposit = [_textDeposit.text longLongValue];
    change = deposit - total;
    if(change < 0){
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self->_buttonDone.enabled = NO;
        }];
    }else{
        self->_buttonDone.enabled = YES;
    }
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

- (void)errAlert:(NSString *)title msg:(NSString *)msg
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        //close PayViewController
        UIViewController* previousViewController = [self presentingViewController];
        [previousViewController dismissViewControllerAnimated:NO completion:nil];
        
        //close OrdersViewController
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.ordersViewController.navigationController popViewControllerAnimated:YES];
        
    }]];
    
    [self presentViewController:alert animated:YES completion:^{
        //
    }];
}

- (IBAction)doneButtonDidPush:(id)sender{
    
    total = [itemList_ getTotalAmountData];
    deposit = [_textDeposit.text longLongValue];
    change = deposit - total;
    
    AppDelegate *appDelegate =(AppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.deposit = deposit;
    appDelegate.change = change;
    
}

- (void)onCChangerDepositEPOS2SDKManager:(EPOS2SDKManager *)ePOS2SDKManager code:(int)code status:(int)status amount:(long)amount data:(NSDictionary *)data
{
    int oposCode = 0;
    _buttonCancel.enabled = YES;
    if(code != EPOS2_CCHANGER_CODE_SUCCESS){
        switch(code){
            case EPOS2_CCHANGER_CODE_ERR_OPOSCODE:
                oposCode = [ePOS2SDKManager getOposErrorCodeCashChanger];
                // Please add error handling
                break;
            default:
                break;
        }
    }else{
        switch(status){
            case EPOS2_CCHANGER_STATUS_BUSY:{//beginDeposit, restartDeposit
                
                //Calculate deposit
                sumDepositCashChanger = amount;
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    self->_textDeposit.text  = [NSString stringWithFormat:@"%ld",self->sumDepositCashChanger];
                    self->total = [self->itemList_ getTotalAmountData];
                    self->deposit = [self->_textDeposit.text longLongValue];
                    self->change = self->deposit - self->total;
                    if(self->change < 0){
                        self->_buttonDone.enabled = NO;
                    }else{
                        self->_buttonDone.enabled = YES;
                    }
                }];
                break;
            }
            case EPOS2_CCHANGER_STATUS_PAUSE:{
                // Please add proccessing
                break;
            }
            case EPOS2_CCHANGER_STATUS_END:{
                // Please add proccessing
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


@end
