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
@property (strong, nonatomic) AVAudioPlayer *player;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (strong,nonatomic)NSTimer *timer;
@property (copy,nonatomic)NSArray *contentsArr;
@property (weak, nonatomic) IBOutlet UILabel *dbLab;

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
     [self upDateTab];
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
            //测量录音分贝
            _recorder.meteringEnabled = YES;
            _recorder.delegate = self;
            [_recorder prepareToRecord];
        }else{
            NSLog(@"_recorder error==%@",error);
        }
    }
    return _recorder;
}

- (void)measureDb{
    [self.recorder updateMeters];
    //-160db~0db
    CGFloat averageDb = [self.recorder averagePowerForChannel:0];
    CGFloat peakDb = [self.recorder peakPowerForChannel:0];
    self.dbLab.text = [NSString stringWithFormat:@"平均:%f--峰值:%f",averageDb,peakDb];
    
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
    return self.contentsArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    NSURL *url = self.contentsArr[indexPath.row];
    NSString*name = url.lastPathComponent;
    
    NSArray*separators = [name componentsSeparatedByString:@"-"];
    NSString *time = separators.lastObject;
    NSTimeInterval stamp =    [time doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:stamp];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    cell.textLabel.text= separators[0];
    cell.detailTextLabel.text = [format stringFromDate:date];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self playAudio:indexPath];
}


- (void)saveAudio:(NSString*)name{
    NSString *home = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSTimeInterval timestamp = [NSDate timeIntervalSinceReferenceDate];
    NSString *saveName = [NSString stringWithFormat:@"%@-%f.caf",name,timestamp];
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
        //测量db
        [weakself measureDb];
    }];
}

-(void)upDateTab{
    NSFileManager * manager = [NSFileManager defaultManager];
   
    NSURL*docUrl = [[manager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSError *error;
//    NSArray*fileNames = [manager contentsOfDirectoryAtPath:docUrl.path error:&error];
//    if (!error) {
//        for (NSString * name in fileNames) {
//            NSLog(@"file name----%@",name);
//        }
//    }else{
//        NSLog(@"get files error---%@",error.localizedDescription);
//    }
    NSArray *urls = [manager contentsOfDirectoryAtURL:docUrl includingPropertiesForKeys:[NSArray array] options:0 error:&error];
    if (!error) {
//        for (NSURL * u in urls) {
//            NSLog(@"url path ----%@",u.path);
//        }
    }else{
        NSLog(@"get urls error---%@",error.localizedDescription);
    }

    self.contentsArr =     [urls sortedArrayUsingComparator:^NSComparisonResult(NSURL*  _Nonnull obj1, NSURL*  _Nonnull obj2) {
        double   o1 = [[[obj1.lastPathComponent componentsSeparatedByString:@"-"] lastObject] doubleValue];
        double  o2 = [[[obj2.lastPathComponent componentsSeparatedByString:@"-"] lastObject] doubleValue];
        return o1<o2;
    }];;
    [self.tabV reloadData];
}

- (void)playAudio:(NSIndexPath* )indexPath{
    [self.player stop];
    
    NSURL *url = self.contentsArr[indexPath.row];
    NSError *error = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error) {
        NSLog(@"player fail ---%@",error.localizedDescription);
        return;
    }
    [self.player play];
    
}
@end
