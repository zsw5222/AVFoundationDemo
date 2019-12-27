//
//  WJAVPlayerController.m
//  TodayDemo
//
//  Created by jalon on 2019/12/12.
//  Copyright © 2019 ore. All rights reserved.
//

#import "WJAVPlayerController.h"
#import <AVFoundation/AVFoundation.h>
#import "AVAsset+WJAsset.h"

@interface WJAVPlayerController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIView *playView;
@property (weak, nonatomic) IBOutlet UISlider *timeSlider;
@property (strong, nonatomic) AVPlayer* player;
@property (strong, nonatomic) AVPlayerLayer *playLayer;
@property (strong, nonatomic) AVAsset *asset;
@property (strong, nonatomic) id playEndObserver;
@property (strong, nonatomic) id playTimeObserver;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (assign,nonatomic) CGFloat lastPlayRate;

@end

@implementation WJAVPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatPlayer];
    
    [self addTimeObserver];
    
    [self playEndNotification];
    
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self.playEndObserver];
    self.playEndObserver = nil;
    
}

- (void)creatPlayer{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"Charlie The Unicorn" ofType:@"m4v"];
    NSURL *url = [NSURL fileURLWithPath:path];
    AVAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSArray *assetKeys = @[@"duration",@"tracks",@"commonMetadata"];
    //创建playeritem,并自动加载assetKeys中的属性
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset automaticallyLoadedAssetKeys:assetKeys];
    self.player = [AVPlayer playerWithPlayerItem:item];
    self.playLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playLayer.frame = self.playView.bounds;
    [self.playView.layer addSublayer:self.playLayer];
    self.asset = asset;
   
}
//播放进度监听
- (void)addTimeObserver{
    
    __weak typeof(self) wkself = self;
    
  self.playTimeObserver =  [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC) queue:nil usingBlock:^(CMTime time) {
     
        NSTimeInterval currentime = CMTimeGetSeconds(time);
     
        CGFloat slideV = currentime/CMTimeGetSeconds(wkself.player.currentItem.duration)*(wkself.timeSlider.maximumValue-wkself.timeSlider.minimumValue)  ;
        [wkself.timeSlider setValue:(slideV)];
      NSLog(@"playing----%f",currentime);
        
    }];
}
//播放完成
- (void)playEndNotification{
    __weak typeof(self) wkself = self;
    self.playEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"play end ------");

        [wkself stopPlay:nil];
    }];
 
}

//开始拖动
- (IBAction)sliderBegin:(UISlider *)sender {
    self.lastPlayRate = self.player.rate;
    [self.player pause];
    [self.player removeTimeObserver:self.playTimeObserver];
    
}

//结束拖动
- (IBAction)slideEnd:(UISlider *)sender {
    [self addTimeObserver];
    if (self.lastPlayRate > 0) {
        [self.player play];
    }

    
}

//拖动...
- (IBAction)timeChange:(UISlider *)sender {
    NSTimeInterval nowTime = sender.value/(sender.maximumValue-sender.minimumValue)*CMTimeGetSeconds(self.player.currentItem.duration);
    //取消之前拖动的seek操作，提升性能
    [self.player.currentItem cancelPendingSeeks];
    [self.player seekToTime:CMTimeMakeWithSeconds(nowTime, NSEC_PER_SEC)];
    
    
}
- (IBAction)playOrPause:(UIButton*)sender {
    if (!sender.isSelected) {
        if (self.player.status == AVPlayerStatusReadyToPlay) {//可以利用kvo 监听
//            self.titleLab.text = self.asset.title;
//            [self.player play];
            //设置播放速率 自动开启倍率播放
            [self.player setRate:2.0];
            sender.selected = YES;
           
        }
    }else{
        
        [self.player pause];
        sender.selected = NO;
    }
   
}
- (IBAction)stopPlay:(UIButton *)sender {
    [self.player setRate:0];
    [self.player seekToTime:kCMTimeZero];
    self.playBtn.selected = NO;
}


@end
