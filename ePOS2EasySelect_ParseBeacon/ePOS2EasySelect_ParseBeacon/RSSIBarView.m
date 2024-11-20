#import "RSSIBarView.h"

static const CGFloat MAX_RSSI_THREAD = -30;
static const CGFloat MIN_RSSI_THREAD = -100;
static const CGFloat RSSI_WIDTH = -70;         //  -1  *   (MIN_RSSI_THREAD - MAX_RSSI_THREAD);

@interface RSSIBarView () {
    CGColorRef rssiBarDrawColor_;
    NSInteger rssiLevel_;
    
}
@end

@implementation RSSIBarView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        rssiBarDrawColor_ = [UIColor lightGrayColor].CGColor;
        rssiLevel_ = 0;
    }
    return self;
}


- (void) setDrawInfo:(BOOL)enable rssiLevel:(NSInteger)rssiLevel
{
    if (enable) {
        rssiBarDrawColor_ =[UIColor blueColor].CGColor;
    }else{
        rssiBarDrawColor_ =[UIColor lightGrayColor].CGColor;
    }
    
    rssiLevel_ = rssiLevel;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.cornerRadius = 5;
    self.clipsToBounds = true;
    
    [self drawrssiBar];
}

- (void)drawrssiBar
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, rssiBarDrawColor_);
    
    if ( MIN_RSSI_THREAD >= rssiLevel_ || 0 == rssiLevel_) {
        ; // 0%
    }
    else if (MAX_RSSI_THREAD <= rssiLevel_ ) {
        // Fill 100%
        CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        CGContextFillRect(context, rect);
    }
    else {
        
        CGFloat widthRate = 1 - ( (rssiLevel_ - MAX_RSSI_THREAD) / RSSI_WIDTH );
        CGFloat fillWidth =  self.frame.size.width * widthRate ;
        CGRect rect = CGRectMake(0, 0, fillWidth, self.frame.size.height);
        CGContextFillRect(context, rect);
    }
    CGContextStrokePath(context);
}

@end
