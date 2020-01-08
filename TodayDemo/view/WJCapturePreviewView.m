//
//  WJCapturePreviewView.m
//  TodayDemo
//
//  Created by jalon on 2020/1/7.
//  Copyright © 2020 ore. All rights reserved.
//

#import "WJCapturePreviewView.h"

@implementation WJCapturePreviewView

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


@end
