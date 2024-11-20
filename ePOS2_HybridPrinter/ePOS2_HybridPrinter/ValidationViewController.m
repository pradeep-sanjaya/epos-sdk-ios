#import "ValidationViewController.h"
#import "ValidationControl.h"

@implementation ValidationViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.hybridPrinter_ = nil;
    }
    return self;
}

- (IBAction)eventButtonDidPush:(id)sender
{
    switch (((UIView *)sender).tag) {
        case 0:
            //validation sequence
            [self updateButtonState:NO];
            
            [self runPrintSequence];
            break;
            
        default:
            break;
    }
}

- (void)runPrintSequence
{
    ValidationControl *validationControl = nil;
    _textWarnings.text = @"";
    
    validationControl = [[ValidationControl alloc] initWithPrinter:self.hybridPrinter_ ConnectTarget:self.connectTarget_];
    
    dispatch_queue_t printDispatchQueue;
    printDispatchQueue = dispatch_queue_create("com.epson.ValidationViewQueue", NULL);
    dispatch_async(printDispatchQueue, ^{
        BOOL result = YES;
        if(validationControl != nil){
            [validationControl setFirstControlType:DEVICE_CONTROL_VALIDATION];
            [validationControl setNextControlType:DEVICE_CONTROL_NONE];
                
            result = [validationControl startSequence];

            dispatch_async(dispatch_get_main_queue(), ^{
                _textWarnings.text =[validationControl getWarningText];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateButtonState:YES];
        });
    });

}

- (void)updateButtonState:(BOOL)state
{
    _buttonValidation.enabled = state;
}

@end
