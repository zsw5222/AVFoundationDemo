//
//  AVPlayerViewController.m
//  TodayDemo
//
//  Created by jalon on 2020/1/2.
//  Copyright © 2020 ore. All rights reserved.
//

#import "WJAVPlayerViewController.h"
#import <AVKit/AVKit.h>

@interface WJAVPlayerViewController ()

@end

@implementation WJAVPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSString* path = [[NSBundle mainBundle] pathForResource:@"hubblecast.m4v" ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
 
    AVPlayer* player = [AVPlayer  playerWithURL:url];
    AVPlayerViewController *vcon = [[AVPlayerViewController alloc] init];
    vcon.player = player;
    vcon.view.frame = CGRectMake(0,40 , self.view.bounds.size.width, 300);
    [self.view addSubview:vcon.view];
    [self addChildViewController:vcon];
    [player play];

    
}

 

@end
