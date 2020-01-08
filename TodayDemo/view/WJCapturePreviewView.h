//
//  WJCapturePreviewView.h
//  TodayDemo
//
//  Created by jalon on 2020/1/7.
//  Copyright © 2020 ore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol  WJCapturePreviewDelegate <NSObject>

-(void)tapedToFoucuseAtPoint:(CGPoint)point;
-(void)tapedToExposeAtPoint:(CGPoint)point;
-(void)tapedToResetFoucuseAndExpose;
@end

@interface WJCapturePreviewView : UIView


@property(nonatomic,strong)AVCaptureSession *session;
@property(nonatomic,assign)BOOL tapFoucusEnable;
@property(nonatomic,assign)BOOL tapExposeEnable;

@end

NS_ASSUME_NONNULL_END
