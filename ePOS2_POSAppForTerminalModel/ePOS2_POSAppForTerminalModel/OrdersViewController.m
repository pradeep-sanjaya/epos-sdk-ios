//
//  OrdersViewController.m
//  ePOS2_Composite
//

#import <Foundation/Foundation.h>
#import "OrdersViewController.h"
#import "AppDelegate.h"

@interface OrdersViewController()
@end

@implementation OrdersViewController

static dispatch_semaphore_t pauseDepositSemaphore;

static const int64_t responseLimitTime = 15.0;

- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate *appDelegate =(AppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.ordersViewController = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self isMovingToParentViewController]){
        // Orders button was pressed.
        
        AppDelegate *appDelegate =(AppDelegate*) [[UIApplication sharedApplication] delegate];
        printerSeries_ = appDelegate.printerSeries;
        targetPrinter_ = appDelegate.targetPrinter;
        targetDisplay_ = appDelegate.targetDisplay;
        targetScanner_ = appDelegate.targetScanner;
        targetCashChanger_ = appDelegate.targetCashChanger;
        enableDisplay_ = appDelegate.enableDisplay;
        enableScanner_ = appDelegate.enableScanner;
        enableCashChanger_ = appDelegate.enableCashChanger;
        
        _buttonCheck.enabled = NO;
        _textApiLog.text = @"";
        _textApiLog.editable = NO;
        _textTotal.text = @"0";
        _textTotal.enabled = NO;
        
        ePOS2SDKManager = [[EPOS2SDKManager alloc] init];
        ePOS2SDKManager.delegate = self;
        queueForSDK = [[NSOperationQueue alloc] init];
        queueForSDK.maxConcurrentOperationCount = 1;
        
        itemList_ = [[EposPurchaseItemList alloc] init];
        
        [queueForSDK addOperationWithBlock:^{
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self beginProcess];
            }];
            
            BOOL result;
            
            //printer
            result = [self->ePOS2SDKManager initializePrinterObject:self->printerSeries_];
            if(!result){
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self endProcess];
                    [self errAlert:@"Faild to connect printer" msg:@"Please set printer's target"];
                }];
            }
            result = [self->ePOS2SDKManager connectPrinter:self->targetPrinter_];
            if(!result){
                [self finalizeAllDevices];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self endProcess];
                    [self errAlert:@"Faild to connect printer" msg:@"Please set printer's target"];
                }];
                
                return;
            }
            
            //LineDisplay
            if(self->enableDisplay_){
                result = [self->ePOS2SDKManager initializeDisplayObject];
                if(!result){
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self endProcess];
                        [self errAlert:@"Faild to connect LineDisplay" msg:@"Please set lineDisplay's target"];
                    }];
                }
                result = [self->ePOS2SDKManager connectLineDisplay:self->targetDisplay_];
                if(!result){
                    [self disconnectAllDevices];
                    [self finalizeAllDevices];
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self endProcess];
                        [self errAlert:@"Faild to connect LineDisplay" msg:@"Please set lineDisplay's target"];
                    }];
                    return;
                }
            }
            
            //Scanner
            if(self->enableScanner_){
                result = [self->ePOS2SDKManager initializeScannerObject];
                if(!result){
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self endProcess];
                        [self errAlert:@"Faild to connect Scanner" msg:@"Please set scanner's target"];
                    }];
                }
                result = [self->ePOS2SDKManager connectBarcodeScanner:self->targetScanner_];
                
                if(!result){
                    [self disconnectAllDevices];
                    [self finalizeAllDevices];
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self endProcess];
                        [self errAlert:@"Faild to connect Scanner" msg:@"Please set scanner's target"];
                    }];
                    return;
                }
            }
            
            //CashChanger
            if(self->enableCashChanger_){
                result = [self->ePOS2SDKManager initializeCashChangerObject];
                if(!result){
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self endProcess];
                        [self errAlert:@"Faild to connect CashChanger" msg:@"Please set cashChanger's target"];
                    }];
                }
                result = [self->ePOS2SDKManager connectCashChanger:self->targetCashChanger_];
                if(!result){
                    [self disconnectAllDevices];
                    [self finalizeAllDevices];
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self endProcess];
                        [self errAlert:@"Faild to connect CashChanger" msg:@"Please set cashChanger's target"];
                    }];
                    return;
                }
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self endProcess];
            }];
            
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
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        
        // back button was pressed.
        [queueForSDK addOperationWithBlock:^{
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self beginProcess];
            }];
            
            self->ePOS2SDKManager.delegate = nil;
            [self disconnectAllDevices];
            [self finalizeAllDevices];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self endProcess];
            }];
            
            
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)modalViewWillClose
{
    ePOS2SDKManager.delegate = self;
    [itemList_ clearItemCount];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self->_buttonCheck.enabled = NO;
        self->_textTotal.text = @"0";
    }];
    
}

- (IBAction)cancelButtonDidPush:(UIStoryboardSegue *) segue
{
    ePOS2SDKManager.delegate = self;
    

    if(self->enableCashChanger_){
        [queueForSDK addOperationWithBlock:^{

        pauseDepositSemaphore = dispatch_semaphore_create(0);
        dispatch_time_t dispatch_Timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * responseLimitTime);
        [self->ePOS2SDKManager pauseDepositCashChanger];
        if(dispatch_semaphore_wait(pauseDepositSemaphore, dispatch_Timeout) != 0){
            [self errAlert2:@"error" msg:@"Callback isn't called"];
        }
            
            
        [self->ePOS2SDKManager endDepositCashChanger:(int)EPOS2_DEPOSIT_REPAY];
        }];
    }
    
}

- (IBAction)eventButtonDidPush:(id)sender
{
    if(itemList_ == nil) {
        return;
    }
    
    NSString* itemCode = nil;
    switch (((UIView *)sender).tag) {
        case 2:
            // Pullover
            itemCode = NSLocalizedString(@"item1Code", nil);
            break;
        case 3:
            // Jeans
            itemCode = NSLocalizedString(@"item2Code", nil);
            break;
        case 4:
            // T-shirt
            itemCode = NSLocalizedString(@"item3Code", nil);
            break;
        case 5:
            // Parka
            itemCode = NSLocalizedString(@"item4Code", nil);
            break;
        case 6:
            // Sox
            itemCode = NSLocalizedString(@"item5Code", nil);
            break;
        case 7:
            // Jacket
            itemCode = NSLocalizedString(@"item6Code", nil);
            break;
        case 8:
            // Camisole
            itemCode = NSLocalizedString(@"item7Code", nil);
            break;
        case 9:
            // Skirt
            itemCode = NSLocalizedString(@"item8Code", nil);
            break;
        case 10:
            // Cut & Sewn
            itemCode = NSLocalizedString(@"item9Code", nil);
            break;
        case 11:
            // Leggings
            itemCode = NSLocalizedString(@"item10Code", nil);
            break;
        case 12:
            // Check
            //[self check];
            break;
        default:
            break;
    }
    
    if(itemCode != nil) {
        [itemList_ incrementItemCount:itemCode];
        
        if(enableDisplay_) {
            NSString* displayData = @"";
            NSString* itemName = [itemList_ getItemName:itemCode];
            long itemValue = (long)[self->itemList_ getItemValue:itemCode];
            
            displayData = [self->ePOS2SDKManager formatDisplayData:itemName value:itemValue];
            [queueForSDK addOperationWithBlock:^{
                [self->ePOS2SDKManager indicateDisplay:displayData];
            }];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self->_textTotal.text = [self->itemList_ createTotalAmountData];
            self->_buttonCheck.enabled = YES;
        }];
    }
}
-(IBAction)payButtonDidPush:(id)sender
{
    
    AppDelegate *appDelegate =(AppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.eposPurchaseItemList = self->itemList_;
    appDelegate.ePOS2SDKManager = self->ePOS2SDKManager;
    
}
- (void)onScanDataEPOS2SDKManager:(EPOS2SDKManager *)EPOS2SDKManager scanData:(NSString *)scanData
{
    if(scanData == nil) {
        return;
    }
    
    // register Item count;
    [itemList_ incrementItemCount:scanData];
    
    if(enableDisplay_) {
        NSString* displayData = @"";
        NSString* itemName = [itemList_ getItemName:scanData];
        long itemValue = (long)[self->itemList_ getItemValue:scanData];
        
        displayData = [self->ePOS2SDKManager formatDisplayData:itemName value:itemValue];
        [queueForSDK addOperationWithBlock:^{
            [self->ePOS2SDKManager indicateDisplay:displayData];
        }];
    }
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self->_textTotal.text = [self->itemList_ createTotalAmountData];
        self->_buttonCheck.enabled = YES;
    }];
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

- (void)onLogEPOS2SDKManager:(EPOS2SDKManager *)EPOS2SDKManager apiLog:(NSString *)apiLog
{
    if(apiLog !=nil){
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self->_textApiLog.text = [self->_textApiLog.text stringByAppendingString:apiLog];
        [self scrollText:self->_textApiLog];
    }];
    }
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
                    [self->ePOS2SDKManager endDepositCashChanger:(int)EPOS2_DEPOSIT_REPAY];
                }];
                break;
            }
                // Please add error handling
            default:
                break;
        }
    }else{
        switch(status){
            case EPOS2_CCHANGER_STATUS_BUSY:{
                // Please add proccessing
                break;
            }
            case EPOS2_CCHANGER_STATUS_PAUSE:{
                if(pauseDepositSemaphore != nil) {
                    dispatch_semaphore_signal(pauseDepositSemaphore);
                }
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
- (BOOL) disconnectAllDevices
{
    BOOL result = YES;
    
    if([ePOS2SDKManager disconnectPrinter] == NO){
        result = NO;
    };
    if(enableScanner_){
        if([ePOS2SDKManager disconnectBarcodeScanner] == NO){
            result = NO;
        };
    }
    if(enableDisplay_){
        if([ePOS2SDKManager disconnectLineDisplay] == NO){
            result = NO;
        };
    }
    if(enableCashChanger_){
        if([ePOS2SDKManager disconnectCashChanger] == NO){
            result = NO;
        };
    }
    
    return result;
}

- (void) finalizeAllDevices
{
    [ePOS2SDKManager finalizePrinterObject];
    if(enableScanner_){
        [ePOS2SDKManager finalizeScannerObject];
    }
    if(enableDisplay_){
        [ePOS2SDKManager finalizeDisplayObject];
    }
    if(enableCashChanger_){
        [ePOS2SDKManager finalizeCashChangerObject];
    }
}


//Indicator
- (void)beginProcess
{
    if (Nil != indicator) {
        indicator = nil;
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


- (void)errAlert:(NSString *)title msg:(NSString *)msg
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.navigationController popViewControllerAnimated:YES];
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


- (void)scrollText:(UITextView *)text
{
    NSRange range;
    range = text.selectedRange;
    range.location = text.text.length;
    text.selectedRange = range;
    text.scrollEnabled = YES;
    
    CGFloat scrollY = text.contentSize.height + text.font.pointSize - text.bounds.size.height;
    CGPoint scrollPoint;
    
    if (scrollY < 0) {
        scrollY = 0;
    }
    
    scrollPoint = CGPointMake(0.0, scrollY);
    
    [text setContentOffset:scrollPoint animated:YES];
}

@end
