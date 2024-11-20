// -*- mode:objc; c-basic-offset:2; indent-tabs-mode:nil -*-
/**
 * Copyright 2009-2012 ZXing authors All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  QRCodeCapture.m
//
// history:
//    31 Aug 2014 : 
//			+ This file was created by copying from ZXingWidgetController.m
//			+ Changed to simplified the I/F.  
//
//     8 Oct 2014:
//          + Support for iOS8
//            - AVCaptureVideoDataOutput queue have been changed.
//            - Memory have been freed by NSAutoreleasePool.
//          + Target image was cropped before decode.


#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <sys/types.h>
#import <sys/sysctl.h>

#import "QRCodeCapture.h"
#import "OverlayView.h"

#import <ZXingWidget/Classes/Decoder.h>
#import <ZXingWidget/Classes/TwoDDecoderResult.h>
#import <ZXingWidget/Classes/QRCodeReader.h>

typedef enum : NSInteger{
    DisConnecting= 0,
    Connecting,
    Capturing,
} CurrentSessionState;

#define CROP_RECT_MARGIN    (10*2)

@interface QRCodeCapture () <DecoderDelegate
#if HAS_AVFF
                                , AVCaptureVideoDataOutputSampleBufferDelegate
#endif
>
{
    CurrentSessionState currentSessionState;
    dispatch_queue_t _captureSessionQueue;

    NSSet *readers;
    BOOL    isNeedSkipCaptureBuffer;    // YES: skip analyzing
    BOOL    nowDecoding;               // YES: don't dealloc
#if HAS_AVFF
    AVCaptureSession *captureSession;
    AVCaptureVideoPreviewLayer *prevLayer;
#endif
    OverlayView *prevFrame;
}
@end

@implementation QRCodeCapture

- (id)init
{
    self = [super init];
    if(self){
        currentSessionState = DisConnecting;
        QRCodeReader* qrcodeReader = [[QRCodeReader alloc] init];
        readers= [[NSSet alloc] initWithObjects:qrcodeReader,nil];
        [qrcodeReader release];
        
        prevFrame = nil;    // initialize
        
        _captureSessionQueue = dispatch_queue_create("capture_session_queue", DISPATCH_QUEUE_SERIAL);
        
        isNeedSkipCaptureBuffer = NO;
        nowDecoding = NO;
    }
    return self;
}

- (void)dealloc
{
    
    // wait for end of decod
    while (nowDecoding) {
         [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }

    [self disConnectCaptureSettion];
    
    [readers release];
    readers = nil;
#if HAS_AVFF
    [captureSession release];
    captureSession = nil;
#endif
    
    [prevFrame release];
    prevFrame = nil;
    
    if (_captureSessionQueue) {
        dispatch_release(_captureSessionQueue);
        _captureSessionQueue = nil;
    }
    
    [super dealloc];
}

//----------------------------------------------------------------------------//
#pragma mark - DecoderDelegate
//----------------------------------------------------------------------------//
- (void)decoder:(Decoder *)decoder didDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset withResult:(TwoDDecoderResult *)twoDResult {

    NSString* resultString = [[twoDResult text] copy];

    isNeedSkipCaptureBuffer = YES;

#ifdef DEBUG
    NSLog(@"QRCodeCapture result: %@", resultString);
#endif
    if ([_delegate respondsToSelector:@selector(didScanResult:)]) {
        [_delegate didScanResult:resultString];
    }
    [resultString release];
    decoder.delegate = nil;
    isNeedSkipCaptureBuffer = NO;
 
}

//----------------------------------------------------------------------------//
#pragma mark - AVFoundation
//----------------------------------------------------------------------------//
- (BOOL)connectCaptureSettion {
    
    if(currentSessionState != DisConnecting){
        return NO;
    }
    
#if HAS_AVFF
    
    // only back camera
    AVCaptureDevice* inputDevice = [self videoDeviceWithPosition:AVCaptureDevicePositionBack];
    if(!inputDevice){
        return NO;
    }
    
    // set focus if supported
    if([inputDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]){
        if ([inputDevice lockForConfiguration:NULL] == YES) {
            [inputDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [inputDevice unlockForConfiguration];
        }
    }
    
    NSError* error = nil;
    AVCaptureDeviceInput *captureInput =
    [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    
    if( error || (!captureInput) ){
        return NO;
    }
    
    AVCaptureVideoDataOutput *captureOutput = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    
    //
    // change queue to "capture_session_queue" from main
    //
    //[captureOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    [captureOutput setSampleBufferDelegate:self queue:_captureSessionQueue];
    
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [captureOutput setVideoSettings:videoSettings];
    captureSession = [[AVCaptureSession alloc] init];
    if(!captureSession){
        return NO;
    }
    
    captureSession.sessionPreset = AVCaptureSessionPresetMedium;
    
    [captureSession addInput:captureInput];
    [captureSession addOutput:captureOutput];
    
#endif
    
    currentSessionState = Connecting;
    return YES;
}

- (AVCaptureDevice*)videoDeviceWithPosition:(AVCaptureDevicePosition)pos
{
    for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if([device position] == pos){
            return device;
        }
    }
    return nil;
}

- (void)startCapture:(UIView*)targetView scanDelegate:(id<QRCodeCaptureDelegate>)scanDelegate
{
    if(currentSessionState != Connecting){
        return;
    }
#if HAS_AVFF
    _delegate = scanDelegate;
    if (!prevLayer) {
        prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    }
    prevLayer.frame = targetView.bounds;
    prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [targetView.layer addSublayer: prevLayer];
    
    if(!prevFrame){
        prevFrame = [[[OverlayView alloc] initWithFrame:targetView.bounds] autorelease];
    }
    [targetView addSubview: prevFrame];
    [captureSession startRunning];
    
#endif
    
    currentSessionState = Capturing;
    isNeedSkipCaptureBuffer = NO;
}

- (void)stopCapture
{
    if(currentSessionState != Capturing){
        return;
    }

    isNeedSkipCaptureBuffer = YES;

#if HAS_AVFF
    [captureSession stopRunning];
    [prevLayer removeFromSuperlayer];
    prevLayer = nil;
    _delegate = nil;
#endif
    
    if (prevFrame != nil ){
        [prevFrame removeFromSuperview];
        prevFrame = nil;
    }

    currentSessionState = Connecting;
}

- (void)disConnectCaptureSettion {
    
    if(currentSessionState == DisConnecting){
        return;
    }
    
    if(currentSessionState == Capturing){
        [self stopCapture];
    }
    isNeedSkipCaptureBuffer = YES;
   
    // wait for end of decod
    while (nowDecoding) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }

#if HAS_AVFF
    AVCaptureInput* input = [captureSession.inputs objectAtIndex:0];
    [captureSession removeInput:input];
    AVCaptureVideoDataOutput* output = (AVCaptureVideoDataOutput*)[captureSession.outputs objectAtIndex:0];
    [captureSession removeOutput:output];
    [captureSession release];
    captureSession = nil;
    
#endif
    if (prevFrame != nil ){
        [prevFrame removeFromSuperview];
        prevFrame = nil;
    }
   currentSessionState = DisConnecting;
}

//----------------------------------------------------------------------------//
#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
//----------------------------------------------------------------------------//
#if HAS_AVFF
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    // skip analyze
    if(isNeedSkipCaptureBuffer == YES){
        return;
    }
    
    // already starting analyze other image frame
    if (nowDecoding == YES) {
        return;
    }
    
    //  lock this analysis process
    nowDecoding = YES;
    
    // for autorelease
    NSAutoreleasePool* mainpool = [[NSAutoreleasePool alloc] init];
    
    // Decode Image from startCapture to stopCapture
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    /*Lock the image buffer*/
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    /*Get information about the image*/
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // NSLog(@"wxh: %lu x %lu", width, height);
    
    uint8_t* baseAddress = (uint8_t*)CVPixelBufferGetBaseAddress(imageBuffer);
    void* free_me = 0;
    if (true) { // iOS bug?
        uint8_t* tmp = baseAddress;
        unsigned long bytes = bytesPerRow*height;
        free_me = baseAddress = (uint8_t*)malloc(bytes);
        baseAddress[0] = 0xdb;
        memcpy(baseAddress,tmp,bytes);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext =
    CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace,
                          kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst);
    
    CGImageRef capture = CGBitmapContextCreateImage(newContext);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    free(free_me);
    
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    
    //
    // create croped image
    //
    height = CGImageGetHeight(capture);
    width = CGImageGetWidth(capture);
    
    CGRect cropRect = [prevFrame cropRect];
    
   // - iOS always takes videos in landscape
    CGRect screen = UIScreen.mainScreen.bounds;
    float tmp = screen.size.width;
    screen.size.width = screen.size.height;
    screen.size.height = tmp;
    
    UIImage* scrn;
    
     if ((cropRect.size.height == 0) ||
        (cropRect.size.width == 0) ||
        (screen.size.width == 0)) {
        // none crop
        scrn = [[[UIImage alloc] initWithCGImage:capture] autorelease];
    }else{
        // crop
        float scale = width/screen.size.width;
        
        cropRect.size.width = cropRect.size.width * scale + CROP_RECT_MARGIN;
        cropRect.size.height = cropRect.size.height * scale + CROP_RECT_MARGIN;
        
        if (cropRect.size.width > width) {
            cropRect.size.width = width;
        }
        if (cropRect.size.height > height) {
            cropRect.size.height = height;
        }
        
        cropRect.origin.x = (width-cropRect.size.width)/2;
        cropRect.origin.y = (height-cropRect.size.height)/2;
        
        CGImageRef cropedImage = CGImageCreateWithImageInRect(capture, cropRect);
        
        scrn = [[[UIImage alloc] initWithCGImage:cropedImage] autorelease];
        
        CGImageRelease(cropedImage);
    }
    
    CGImageRelease(capture);
    
    Decoder* d = [[Decoder alloc] init];
    d.readers = readers;
    d.delegate = self;

    [d decodeImage:scrn];

    [d release];
     
    [mainpool release];

    nowDecoding = NO;
    
}
#endif


//----------------------------------------------------------------------------//
#pragma mark - Overlay View Method
//----------------------------------------------------------------------------//
- (void)setFrameColor:(UIColor*)color
{
    [prevFrame setFrameColor:color];
}

@end
