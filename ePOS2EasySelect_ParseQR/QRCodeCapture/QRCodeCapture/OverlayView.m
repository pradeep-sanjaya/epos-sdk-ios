// -*- Mode: ObjC; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*-

/**
 * Copyright 2009 Jeff Verkoeyen
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  OverlayView.m
//
// history:
//    31 Aug 2014 : 
//			+ This file created by copying from zxing/zxing/iphone/ZXingWidget/Classes/OverlayView.m
//			+ Only the frame is displayed on the preview.
//			+ Set the frame color.
//

#import "OverlayView.h"


@interface OverlayView()
{
    UIColor *frameColor;
}
@end

const CGFloat qrFrameSizeJust = 150;

@implementation OverlayView
@synthesize cropRect;

////////////////////////////////////////////////////////////////////////////////////////////////////

- (id) initWithFrame:(CGRect)theFrame
{
  self = [super initWithFrame:theFrame];
  if( self ) {
      CGFloat qrFrameSize = qrFrameSizeJust;
      if (qrFrameSize > theFrame.size.width) {
          qrFrameSize = theFrame.size.width - 10;
      }
      
      if (qrFrameSize > theFrame.size.height) {
          qrFrameSize = theFrame.size.height - 10;
      }
     
     cropRect = CGRectMake((theFrame.size.width - qrFrameSize)/2,
                          (theFrame.size.height - qrFrameSize)/2,
                          qrFrameSize, qrFrameSize);
      
    frameColor = [UIColor redColor];

    self.backgroundColor = [UIColor clearColor];
  }
 
    return self;
}




////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) dealloc {
	[super dealloc];
}


- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context {
	CGContextBeginPath(context);
    CGContextSetLineWidth(context, 2.0f);
	CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
	CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
	CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
	CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
	CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y);
	CGContextStrokePath(context);
}

- (CGPoint)map:(CGPoint)point {
    CGPoint center;
    center.x = cropRect.size.width/2;
    center.y = cropRect.size.height/2;
    float x = point.x - center.x;
    float y = point.y - center.y;
    int rotation = 90;
    switch(rotation) {
    case 0:
        point.x = x;
        point.y = y;
        break;
    case 90:
        point.x = -y;
        point.y = x;
        break;
    case 180:
        point.x = -x;
        point.y = -y;
        break;
    case 270:
        point.x = y;
        point.y = -x;
        break;
    }
    point.x = point.x + center.x;
    point.y = point.y + center.y;
    return point;
}

#define kTextMargin 10

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	CGContextRef c = UIGraphicsGetCurrentContext();
    
	CGContextSetStrokeColor(c, CGColorGetComponents(frameColor.CGColor));
	CGContextSetFillColor(c, CGColorGetComponents(frameColor.CGColor));
	[self drawRect:cropRect inContext:c];
	
	CGContextSaveGState(c);

	CGContextRestoreGState(c);
	
}

- (void)setFrameColor:(UIColor*)color
{
    frameColor = color;
    [(UIView*)self setNeedsDisplay];
}

////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)layoutSubviews {
  [super layoutSubviews];
}

@end
