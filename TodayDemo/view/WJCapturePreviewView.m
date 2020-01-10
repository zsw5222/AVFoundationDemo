//
//  WJCapturePreviewView.m
//  TodayDemo
//
//  Created by jalon on 2020/1/7.
//  Copyright © 2020 ore. All rights reserved.
//

#import "WJCapturePreviewView.h"

@implementation WJCapturePreviewView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addGestures];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
     [self addGestures];
    
}

+(Class)layerClass{
    
    return AVCaptureVideoPreviewLayer.class;
}
- (void)setSession:(AVCaptureSession *)session{
    [(AVCaptureVideoPreviewLayer*)self.layer setSession:session];
}
- (AVCaptureSession *)session{
    return [(AVCaptureVideoPreviewLayer*)self.layer session];
}
- (CGPoint)captureDevicePointForPoint:(CGPoint)p{
    //屏幕上的坐标转化为摄像头上的坐标
    return [(AVCaptureVideoPreviewLayer*)self.layer captureDevicePointOfInterestForPoint:p];
}

- (void)addGestures{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFocus:)];
    [self addGestureRecognizer:tap];
    self.exclusiveTouch = YES;
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doublTapExpose:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    //双指点击
    UITapGestureRecognizer *doubleFignerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetFoucsAndExpose:)];
    doubleFignerTap.numberOfTouchesRequired = 2;
    [self addGestureRecognizer:doubleFignerTap];
    
}
#pragma mark - gestures method
- (void)tapFocus:(UIGestureRecognizer*)ges{
    NSLog(@"single tap---");
    CGPoint touchP = [ges locationInView:self];
    if ([self.delegate respondsToSelector:@selector(tapedToFoucuseAtPoint:)] && self.tapFoucusEnable) {
        [self.delegate tapedToFoucuseAtPoint:[self captureDevicePointForPoint:touchP]];
    }
    
}
- (void)doublTapExpose:(UIGestureRecognizer*)ges{
    NSLog(@"double tap---");
    CGPoint touchP = [ges locationInView:self];
    if ([self.delegate respondsToSelector:@selector(tapedToExposeAtPoint:)] && self.tapExposeEnable) {
        [self.delegate tapedToExposeAtPoint:[self captureDevicePointForPoint:touchP]];
    }
    
}
- (void)resetFoucsAndExpose:(UITapGestureRecognizer*)ges{
    
    if ([self.delegate respondsToSelector:@selector(tapedToResetFoucuseAndExpose)] ) {
        [self.delegate  tapedToResetFoucuseAndExpose];
    }
}

@end
