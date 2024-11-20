#import "PassViewController.h"
#import "ReceiptControl.h"
#import "SlipControl.h"
#import "EndorseControl.h"
#import "MicrControl.h"

@implementation PassViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.hybridPrinter_ = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _switchReadMicr.on = YES;
    _switchPrintEndorse.on = YES;
    _switchPrintSlip.on = YES;
    _switchPrintReceipt.on = YES;
    
    _switchReadMicr.enabled = NO;
}

- (IBAction)eventButtonDidPush:(id)sender
{
    switch (((UIView *)sender).tag) {
        case 0:
            //1pass sequence
            [self updateButtonState:NO];
            
            [self runPrintSequence];
            break;

        default:
            break;
    }
}

- (void)updateButtonState:(BOOL)state
{
    _buttonStart.enabled = state;
    _switchPrintEndorse.enabled = state;
    _switchPrintSlip.enabled = state;
    _switchPrintReceipt.enabled = state;
}

- (void)runPrintSequence
{
    MicrControl *micrControl = nil;
    EndorseControl *endorseControl = nil;
    SlipControl *slipControl = nil;
    ReceiptControl *receiptControl = nil;
    enum DeviceControlType nextControl = DEVICE_CONTROL_NONE;
    
    _textReadMicr.text = @"";
    _textWarnings.text = @"";
    
    
    if(_switchPrintReceipt.on){
        receiptControl = [[ReceiptControl alloc] initWithPrinter:self.hybridPrinter_ ConnectTarget:self.connectTarget_];
        [receiptControl setNextControlType:nextControl];
        nextControl = DEVICE_CONTROL_RECEIPT;
    }
    
    if(_switchPrintSlip.on){
        slipControl = [[SlipControl alloc] initWithPrinter:self.hybridPrinter_ ConnectTarget:self.connectTarget_];
        [slipControl setNextControlType:nextControl];
        nextControl = DEVICE_CONTROL_SLIP;
    }
    
    if(_switchPrintEndorse.on){
        endorseControl = [[EndorseControl alloc] initWithPrinter:self.hybridPrinter_ ConnectTarget:self.connectTarget_];
        [endorseControl setNextControlType:nextControl];
        nextControl = DEVICE_CONTROL_ENDORSE;
    }
    
    if(_switchReadMicr.on){
        micrControl = [[MicrControl alloc] initWithPrinter:self.hybridPrinter_ ConnectTarget:self.connectTarget_];
        [micrControl setFirstControlType:DEVICE_CONTROL_MICR];
        [micrControl setNextControlType:nextControl];
        nextControl = DEVICE_CONTROL_MICR;
    }
    
    dispatch_queue_t printDispatchQueue;
    printDispatchQueue = dispatch_queue_create("com.epson.PassViewQueue", NULL);
    dispatch_async(printDispatchQueue, ^{
        BOOL result = YES;
        
        if(micrControl != nil){
            result = [micrControl startSequence];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(result){
                    _textReadMicr.text = [micrControl getMicrData];
                }
                _textWarnings.text =[micrControl getWarningText];
                
            });
        }
        
        if((endorseControl != nil) && result){
            result = [endorseControl startSequence];
            dispatch_async(dispatch_get_main_queue(), ^{
                _textWarnings.text =[endorseControl getWarningText];
            });
        }
        
        if((slipControl != nil) && result){
            result = [slipControl startSequence];
            dispatch_async(dispatch_get_main_queue(), ^{
                _textWarnings.text =[slipControl getWarningText];
            });

        }
        
        if((receiptControl != nil) && result){
            result = [receiptControl startSequence];
            dispatch_async(dispatch_get_main_queue(), ^{
                _textWarnings.text =[receiptControl getWarningText];
            });
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateButtonState:YES];
        });
    });
}

@end
