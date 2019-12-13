//
//  AudioPlayController.m
//  TodayDemo
//
//  Created by jalon on 2019/11/28.
//  Copyright © 2019 ore. All rights reserved.
//

#import "AudioPlayController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
 

@interface AudioPlayController ()<AVAudioPlayerDelegate>

@property(nonatomic,strong)AVAudioPlayer *player1;

@end

@implementation AudioPlayController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setSession];
    
    NSURL* totoUrl = [[NSBundle mainBundle] URLForResource:@"toto" withExtension:@"mp3"];
    NSError *error;
    self.player1 = [[AVAudioPlayer alloc] initWithContentsOfURL:totoUrl error:&error];
    if (error) {
        NSLog(@"player1 error==%@",error.localizedDescription);
    }
    //循环次数
    self.player1.numberOfLoops = -1;
    self.player1.enableRate = YES;
    [self.player1 prepareToPlay];
    self.player1.delegate = self;
    //播放打断
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioInterrut:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    //播放线路改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    //后台控制
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

- (IBAction)rateChange:(UISlider *)sender {
    NSLog(@"current rate==%f",sender.value);
    //0.5-2.0
    self.player1.rate = sender.value;
    
}

- (IBAction)panChange:(UISlider *)sender {
    //声道 -1.0-1.0
    self.player1.pan = sender.value;
    
}
- (IBAction)volumeChange:(UISlider *)sender {
    //0-1.0
    self.player1.volume = sender.value;
}

- (IBAction)start:(UIButton *)sender {
    [self.player1 play];
    
//    [self.player1 playAtTime:self.player1.deviceCurrentTime];
}

- (IBAction)stop:(id)sender {
    [self.player1 stop];
   
}

- (IBAction)pause:(id)sender {
    [self.player1 pause];
}
- (void)setSession{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    //When using this category, your app audio continues with the Silent switch set to silent or when the screen locks.
    //要实现后台播放还需在capabilities->background mode 勾选audio...
    if (![session setCategory:AVAudioSessionCategoryPlayback error:&error]) {
        NSLog(@"session set error--%@",error.localizedDescription);
    }
    if ( ![session setActive:YES error:&error]) {
        NSLog(@"session set error--%@",error.localizedDescription);
    }
    
}
#pragma mark -audio interrupt
-(void)audioInterrut:(NSNotification*)notifi{
    NSLog(@"播放中断----%@",notifi.userInfo);
    AudioSessionInterruptionType type = [notifi.userInfo[AVAudioSessionInterruptionTypeKey] unsignedIntValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        [self stop:nil];
    }
    if (type == AVAudioSessionInterruptionTypeEnded) {
        AVAudioSessionInterruptionOptions options = [notifi.userInfo[AVAudioSessionInterruptionOptionKey] unsignedIntValue];
        if (options == AVAudioSessionInterruptionOptionShouldResume) {
            NSLog(@"resume play------");
            [self start:nil];
          
           
        }
    }
}
//线路改变
- (void)handleRouteChange:(NSNotification*)notifi{
    NSLog(@"route change----%@",notifi.userInfo);
    NSDictionary*dict = notifi.userInfo;
    AVAudioSessionRouteChangeReason reson = [dict[AVAudioSessionRouteChangeReasonKey] unsignedIntValue];
    //旧设备不可用
    if (reson == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription *preRouteDescrp = dict[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription* prePortDescrp = preRouteDescrp.outputs[0];
        //耳机
        if ([prePortDescrp.portType isEqualToString:AVAudioSessionPortHeadphones] ) {
            NSLog(@"耳机断开，停止播放---");
            //停止播放
            [self stop:nil];
        }
    }
    
}
 
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"audioPlayerDidFinishPlaying----");
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    
    NSLog(@"audioPlayerDecodeErrorDidOccur==%@",error);
}
 
@end
