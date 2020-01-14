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
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface WJCaptureDeviceController ()<WJCapturePreviewDelegate,AVCaptureFileOutputRecordingDelegate>

@property(nonatomic,strong)AVCaptureSession* capSession;
@property(nonatomic,strong)AVCaptureDeviceInput* activeDeviceInput;
@property(nonatomic,strong)AVCaptureStillImageOutput* stillImgOutPut;
@property(nonatomic,strong)AVCaptureMovieFileOutput* movieFileOutPut;
@property(nonatomic,strong)dispatch_queue_t videoQueue;
@property (weak, nonatomic) IBOutlet WJCapturePreviewView *capView;

@property (weak, nonatomic) IBOutlet UIImageView *tmpImgV;

@property (strong, nonatomic)NSURL* outPutUrl;

@end


@implementation WJCaptureDeviceController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.capView.tapExposeEnable = YES;
    self.capView.tapFoucusEnable = YES;
    self.capView.delegate = self;
    
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
        [seesion addOutput:output];
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
            //会阻塞当前线程 开始失败通知 AVCaptureSessionRuntimeErrorNotification.
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
#pragma mark -CapturePreviewDelegate
- (void)tapedToFoucuseAtPoint:(CGPoint)point{
    NSLog(@"focus---");
    AVCaptureDevice *device = [self activeCamera];
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError*err;
        if ( [device lockForConfiguration:&err]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            
            [device unlockForConfiguration];
        }else{
            NSLog(@"lock error --%@",err);
        }
    }
  
}
 

//自动曝光
- (void)tapedToExposeAtPoint:(CGPoint)point{
     NSLog(@"expose---");
    AVCaptureDevice *device = [self activeCamera];
    AVCaptureExposureMode exposeModel = AVCaptureExposureModeContinuousAutoExposure;
    if (device.isExposurePointOfInterestSupported && [device isExposureModeSupported:exposeModel]) {
        NSError*err;
        if ( [device lockForConfiguration:&err]) {
            device.exposurePointOfInterest = point;
            device.exposureMode = exposeModel;
            //监听adjustingExposure 找到最合适的曝光点
            [device addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:nil];
             
            
            [device unlockForConfiguration];
        }else{
            NSLog(@"lock error --%@",err);
        }
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"adjustingExposure"]) {
        AVCaptureDevice *device = [self activeCamera];
        if (!device.adjustingExposure && [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            //移除监听
            [device removeObserver:self forKeyPath:@"adjustingExposure"];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                if ( [device lockForConfiguration:&error]) {
                    //锁定
                    device.exposureMode = AVCaptureExposureModeLocked;
                    [device unlockForConfiguration];
                }else{
                    NSLog(@"lock error--%@",error);
                }
            });
 
        }
        
    }
}
//恢复自动对焦和曝光
- (void)tapedToResetFoucuseAndExpose{
    
    AVCaptureDevice *device = [self activeCamera];
    CGPoint interstPoint = CGPointMake(0.5, 0.5);
    
    BOOL canResetFocus  =  device.focusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus];
    BOOL canResetExpose  =  device.exposurePointOfInterestSupported && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure] ;
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        NSLog(@"重置--");
        if (canResetFocus) {
            device.focusPointOfInterest = interstPoint;
            device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
        if (canResetExpose) {
            device.exposurePointOfInterest = interstPoint;
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        }
        [device unlockForConfiguration];
    }else{
        NSLog(@"reset error--%@",error);
    }
    
}
#pragma mark- 闪光灯
- (IBAction)flashSwitch:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.isSelected) {
        [self setTorchhMode:AVCaptureTorchModeOn];
    }else{
        [self setTorchhMode:AVCaptureTorchModeOff];
    }
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode{
    AVCaptureDevice *device = [self activeCamera];
    if ([device isFlashModeSupported:flashMode]) {
        NSError*error;
        if ([device lockForConfiguration:&error]) {
             [device setFlashMode:flashMode];
           
            [device unlockForConfiguration];
        }
        
    }
 
}
- (void)setTorchhMode:(AVCaptureTorchMode)torchMode{
    AVCaptureDevice *device = [self activeCamera];
    if ([device isTorchModeSupported:torchMode]) {
        NSError*error;
        if ([device lockForConfiguration:&error]) {
             [device setTorchMode:torchMode];
            [device unlockForConfiguration];
        }
    }
}
#pragma mark -拍照

- (IBAction)takePhoto:(id)sender {
    

    
    AVCaptureConnection *connection = [self.stillImgOutPut connectionWithMediaType:AVMediaTypeVideo];
    //拍出来的照片方向
    connection.videoOrientation = [self getCaptureImgOritension];
 
    [self.stillImgOutPut captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        if (imageDataSampleBuffer) {
            NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            [self writeToAlbum: [UIImage imageWithData:data]];
        }
    }];
}

- (void)writeToAlbum:(id)image{
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized ) {
        
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
        }];
    }

    PHPhotoLibrary *lib = [PHPhotoLibrary sharedPhotoLibrary];
    
    [lib performChanges:^{
        
        PHAssetCollection *collection = [[PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil] firstObject];
        
        PHAssetCollectionChangeRequest *assetCollectRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
          PHAssetChangeRequest *assetRequest =  nil;
        if ([image isKindOfClass:[UIImage class]]) {
          assetRequest = [PHAssetChangeRequest  creationRequestForAssetFromImage:image];
        }else if([image isKindOfClass:[NSURL class]]){
           assetRequest = [PHAssetChangeRequest  creationRequestForAssetFromVideoAtFileURL:(NSURL*)image];
        }
      
        
        PHObjectPlaceholder *placeHolder = [assetRequest placeholderForCreatedAsset];
      
        
        [assetCollectRequest addAssets:@[placeHolder]];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([image isKindOfClass:[UIImage class]]) {
                    self.tmpImgV.image = image;
                }
              
            });
              
        }
    }];

    
}
#pragma mark - 录制

- (IBAction)recordClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self startRecroding];
    }else{
        [self stopRecording];
    }
    
}


- (void)startRecroding{
    
    self.movieFileOutPut.movieFragmentInterval = CMTimeMakeWithSeconds(10, NSEC_PER_SEC);
    
    if (!self.movieFileOutPut.isRecording) {
        AVCaptureConnection *connection = [self.movieFileOutPut connectionWithMediaType:AVMediaTypeVideo];
        if ([connection isVideoOrientationSupported]) {
            connection.videoOrientation = [self getCaptureImgOritension];
        }else{
             NSLog(@"不支持 videoOrientation");
        }
        if ([self.activeDeviceInput.device.activeFormat isVideoStabilizationModeSupported:AVCaptureVideoStabilizationModeAuto]) {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;;
        }else{
            NSLog(@"不支持 AVCaptureVideoStabilizationModeAuto");
        }
        if ([self.activeDeviceInput.device isSmoothAutoFocusSupported]) {
            NSError*error;
            [self.activeDeviceInput.device lockForConfiguration:&error];
            if (!error) {
                self.activeDeviceInput.device.smoothAutoFocusEnabled = YES;
                [self.activeDeviceInput.device unlockForConfiguration];
                
            }else{
                NSLog(@"set smoothAutoFocusEnabled error--%@",error);
            }
            
        }
        self.outPutUrl = [self getMoviewOutUrl];
        [self.movieFileOutPut startRecordingToOutputFileURL:self.outPutUrl recordingDelegate:self];
        
    }
    
}
- (void)stopRecording{
    if ([self.movieFileOutPut isRecording]) {
        [self.movieFileOutPut stopRecording];
    }
}
- (NSURL*)getMoviewOutUrl{
    
    NSString *tmp = NSTemporaryDirectory();
    NSString* filepath = [tmp stringByAppendingString:@"mymovie.mov"];
    return [NSURL fileURLWithPath:filepath];
 
}
#pragma mark-AVCaptureFileOutput delegate
- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error{
    NSLog(@"--stop recording---");
    //保存到相册
    [self writeToAlbum:outputFileURL];
}


//根据界面方向
- (AVCaptureVideoOrientation)getCaptureImgOritension{
    
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
         case UIDeviceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
        case UIDeviceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeRight;
        default:
            return AVCaptureVideoOrientationLandscapeLeft;
            break;
    }
}

@end
