//
//  WJCaptureDeviceController.m
//  TodayDemo
//
//  Created by jalon on 2020/1/3.
//  Copyright © 2020 ore. All rights reserved.
//

#import "WJCaptureDeviceController.h"
#import <AVFoundation/AVFoundation.h>

@interface WJCaptureDeviceController ()

@end

@implementation WJCaptureDeviceController

- (void)viewDidLoad {
    [super viewDidLoad];

    
}
- (void)creat{
    AVCaptureDevice *capdevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput* deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:capdevice error:&error];
}

@end
