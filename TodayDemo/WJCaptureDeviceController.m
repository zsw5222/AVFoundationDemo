//
//  WJCaptureDeviceController.m
//  TodayDemo
//
//  Created by jalon on 2020/1/3.
//  Copyright © 2020 ore. All rights reserved.
//

#import "WJCaptureDeviceController.h"
#import <AVFoundation/AVFoundation.h>
#import "WJCapturePreviewView.h"

@interface WJCaptureDeviceController ()

@property(nonatomic,strong)AVCaptureSession* capSession;
@property(nonatomic,strong)AVCaptureDeviceInput* activeDeviceInput;
@property(nonatomic,strong)AVCaptureStillImageOutput* stillImgOutPut;
@property(nonatomic,strong)AVCaptureMovieFileOutput* movieFileOutPut;
@property(nonatomic,strong)dispatch_queue_t videoQueue;
@property (weak, nonatomic) IBOutlet WJCapturePreviewView *capView;


@end

@implementation WJCaptureDeviceController

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self creatSession]) {
        self.capView.session = self.capSession;
        [self startSession];
    }
}




- (BOOL)creatSession{
    AVCaptureSession *seesion = [[AVCaptureSession alloc] init];
    seesion.sessionPreset = AVCaptureSessionPresetHigh;
    self.capSession = seesion;
    
    AVCaptureDevice *capdevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput* deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:capdevice error:&error];
    if (error) {
        NSLog(@"error--%@",error);
        return false;
    }
    self.activeDeviceInput = deviceInput;
    
    if ([seesion canAddInput:deviceInput]) {
        [seesion addInput:deviceInput];
    }
    //麦克风
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    if ([seesion canAddInput:audioInput]) {
        [seesion addInput:audioInput];
    }
    
    //ios 10 and later
//    AVCapturePhotoOutput* photoOut = [[AVCapturePhotoOutput alloc] init];
    
    AVCaptureStillImageOutput *output = [[AVCaptureStillImageOutput alloc] init];
    output.outputSettings = @{AVVideoCodecKey:AVVideoCodecTypeJPEG};
    if ([seesion canAddOutput:output]) {
        [seesion canAddOutput:output];
    }
    self.stillImgOutPut = output;
    
    //movie output
    AVCaptureMovieFileOutput *movOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([seesion canAddOutput:movOutput]) {
        [seesion addOutput:movOutput];
    }
    self.movieFileOutPut = movOutput;
    
    //
    self.videoQueue = dispatch_queue_create("com.xx.wj", NULL);
    return true;
    
}
- (void)startSession{
    if (![self.capSession isRunning]) {
        dispatch_async(self.videoQueue, ^{
            [self.capSession startRunning];
        });
    }
}
- (void)stopSession{
    
 if ( [self.capSession isRunning]) {
     dispatch_async(self.videoQueue, ^{
          [self.capSession stopRunning];
     });
  }
   
}

/// 返回前置或后置摄像头
- (AVCaptureDevice*)cameraWithPosition:(AVCaptureDevicePosition)p{
//  ios 10 and laster use  AVCaptureDeviceDiscoverySession
  
    NSArray* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice*device in devices) {
        if (device.position == p) {
            return device;
        }
    }
    return nil;
    
}
//返回当前摄像头
-(AVCaptureDevice*)activeCamera{
    return self.activeDeviceInput.device;
}
//返回未使用的摄像头
- (AVCaptureDevice*)inactiveCamera{
    AVCaptureDevice *device;
    if ([self cameraCount]>1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            return [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        if ([self activeCamera].position == AVCaptureDevicePositionFront) {
            return [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

//返回摄像头数量
- (NSUInteger)cameraCount{
    
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    
}
- (BOOL)canSwitchCamera{
    return [self cameraCount]>1;
}

#pragma mark- 切换镜头
- (IBAction)switchCamera:(id)sender {
    if (![self canSwitchCamera]) {
        return;
    }
    NSError *error;
    AVCaptureDevice *inactiveCamera = [self inactiveCamera];
    AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:inactiveCamera error:&error];
    if (newInput) {
        [self.capSession beginConfiguration];
        //先移除
        [self.capSession removeInput:self.activeDeviceInput];
        if ([self.capSession canAddInput:newInput]) {
            [self.capSession addInput:newInput];
            self.activeDeviceInput = newInput;
        }else{
            [self.capSession addInput:self.activeDeviceInput];
        }
        
        
        [self.capSession commitConfiguration];
        
    }else{
        NSLog(@"switchCamera error--%@",error);
    }
 
}



@end
