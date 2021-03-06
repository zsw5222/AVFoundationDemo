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
#import <MediaPlayer/MediaPlayer.h>
#import "WJAVPlayerViewController.h"

@interface WJAVPlayerController ()<UITableViewDataSource>

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
@property (strong, nonatomic)AVAssetImageGenerator *imgGenerator;
@property (nonatomic,strong)NSArray *imgsArr;
@property (weak, nonatomic) IBOutlet UITableView *tabV;

 
@end

@implementation WJAVPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self creatPlayer];
    
    [self addTimeObserver];
    
    [self playEndNotification];
    
    [self addAirPlay];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self.playEndObserver];
    self.playEndObserver = nil;
    
}

- (void)creatPlayer{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"hubblecast.m4v" ofType:nil];
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
    
    [self creatThumbail];
    [self loadMediaSelection];

}
//生成截图
- (void)creatThumbail{
    
    self.imgGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.asset];
    //固定宽度 ，高度自动缩放
    self.imgGenerator.maximumSize = CGSizeMake(200, 0);
    
 
    
    CMTime duration = self.asset.duration;
    CMTimeValue perValue = duration.value/10;
    NSMutableArray *timesArr = [NSMutableArray array];
    for (int i = 0; i < 10 ; i++) {
        CMTime tmpT = CMTimeMake(perValue*i, duration.timescale);
        [timesArr addObject: [NSValue valueWithCMTime:tmpT]];
    }
   __block NSMutableArray *imgArr = [NSMutableArray array];
 
   [self.imgGenerator generateCGImagesAsynchronouslyForTimes:timesArr completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
       if (result == AVAssetImageGeneratorSucceeded) {
           UIImage *img = [UIImage imageWithCGImage:image];
           [imgArr addObject:img];
       }
       if (imgArr.count == timesArr.count) {
               self.imgsArr = imgArr;
           dispatch_async(dispatch_get_main_queue(), ^{
              [self.tabV reloadData];
           });
       

       }
    }];
    
}
//加载字幕
- (void)loadMediaSelection{
    NSArray*characts = self.asset.availableMediaCharacteristicsWithMediaSelectionOptions;
    for (NSString*c in characts) {
        NSLog(@"charact---%@",characts);
        AVMediaSelectionGroup *group = [self.asset mediaSelectionGroupForMediaCharacteristic:c];
        for (AVMediaSelectionOption *option in group.options) {
            NSLog(@"option name--%@",option.displayName);
        }
        AVMediaSelectionGroup *languageGroup = [self.asset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicLegible];
        AVMediaSelectionOption *optin =   languageGroup.options.firstObject;
        [self.player.currentItem selectMediaOption:optin inMediaSelectionGroup:languageGroup];
        
    }
}

- (void)addAirPlay{
    MPVolumeView *vv = [[MPVolumeView alloc] init];
    vv.frame = CGRectMake(20, 700, 200, 59);
    vv.showsVolumeSlider = NO;
    vv.showsRouteButton = YES;
    [self.view addSubview:vv];
   
}

#pragma mark--- tabview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.imgsArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:@"thumb"];
    UIImageView*imgV = [cell viewWithTag:123];
    imgV.image = self.imgsArr[indexPath.row];
    return cell;
    
}
- (IBAction)toPlayController:(id)sender {
//    UIViewController*con = [UIViewController new];
    WJAVPlayerViewController *con = [WJAVPlayerViewController new];
    
    [self.navigationController pushViewController: con animated:YES  ];
}

@end
