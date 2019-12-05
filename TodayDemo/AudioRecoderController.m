//
//  AudioRecoderController.m
//  TodayDemo
//
//  Created by jalon on 2019/12/3.
//  Copyright © 2019 ore. All rights reserved.
//

#import "AudioRecoderController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIViewController+WH.h"

@interface AudioRecoderController ()<AVAudioRecorderDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tabV;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (strong,nonatomic)NSTimer *timer;
@end

@implementation AudioRecoderController

- (void)viewDidLoad {
    [super viewDidLoad];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError*error;
    if (![session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error]) {
        NSLog(@"setcategory error==%@",error.localizedDescription);
    }
    if (![session setActive:YES error:&error]) {
        NSLog(@"setActive error==%@",error.localizedDescription);
    }
    
}

- (AVAudioRecorder *)recorder{
    if (!_recorder) {
        NSString * tmp = NSTemporaryDirectory();
        //caf 格式可以保存core audio支持的任何格式
        NSString* tmpFile = [tmp stringByAppendingPathComponent:@"tmpRecoder.caf"];
        NSURL* url = [NSURL fileURLWithPath:tmpFile];
        NSDictionary* settings = @{
            AVFormatIDKey:@(kAudioFormatAppleIMA4),
            AVSampleRateKey:@(44100.0f),
            AVNumberOfChannelsKey:@1,
            AVEncoderBitDepthHintKey:@16,
            AVEncoderAudioQualityKey:@(AVAudioQualityMedium)
        };
        NSError*error;
        _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
        if (_recorder) {
            _recorder.delegate = self;
            [_recorder prepareToRecord];
        }else{
            NSLog(@"_recorder error==%@",error);
        }
    }
    return _recorder;
}








- (IBAction)playbackClick:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        if (![self.recorder record]) {
            NSLog(@"start recorder fail !!!  ");
        }
            [self beginTime];
    }else{
        [self.recorder pause];
    }

}

- (IBAction)stopClick:(UIButton *)sender {
    [self.recorder stop];
    
}

#pragma mark --recorder delegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSLog(@"recoder succeess ---%@",recorder.url);
    [self showText:@"name" sure:^(NSString * name) {
        [self saveAudio:name];
    } cancel:^{
        
    }];
}
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    NSLog(@"audioRecorderEncodeErrorDidOccur--%@",error.localizedDescription);
   
}
#pragma mark -tab
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

- (void)saveAudio:(NSString*)name{
    NSString *home = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSTimeInterval timestamp = [NSDate timeIntervalSinceReferenceDate];
    NSString *saveName = [NSString stringWithFormat:@"%@-%f",name,timestamp];
    NSString *savePath = [home stringByAppendingPathComponent:saveName];
    NSURL *tmpUrl = self.recorder.url;
    if (tmpUrl) {
        NSFileManager *manager = [NSFileManager defaultManager];
        NSURL *destUrl = [NSURL fileURLWithPath:savePath];
        NSError *error;
        if (![manager copyItemAtURL:tmpUrl toURL:destUrl error:&error]) {
            NSLog(@"save fail---%@",error.localizedDescription);
        }else{
            [self upDateTab];
        }
        
    }
}

- (void)beginTime{
    
    [self.timer invalidate];
    __weak typeof(self) weakself = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:true block:^(NSTimer * _Nonnull timer) {
        int duration = weakself.recorder.currentTime;
        int second = duration%60;
        int minute = duration/60%60;
        int hour = duration/3600;
        weakself.timeLab.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hour,minute,second];
    }];
}

-(void)upDateTab{
    NSFileManager * manager = [NSFileManager defaultManager];
   
    NSURL*docUrl = [[manager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSArray*urls =  nil;
    for (NSURL*url in urls) {
        NSLog(@"path=======%@",url.absoluteString);
    }
}


@end
