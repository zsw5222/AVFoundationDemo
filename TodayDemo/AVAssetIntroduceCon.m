//
//  AVAssetIntroduceCon.m
//  TodayDemo
//
//  Created by jalon on 2019/12/9.
//  Copyright © 2019 ore. All rights reserved.
//

#import "AVAssetIntroduceCon.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AVMetadataItem+THAdditions.h"


@interface AVAssetIntroduceCon ()

@end

@implementation AVAssetIntroduceCon

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *url = [NSURL fileURLWithPath:@"path"];
    //return 子类对象AVURLAsset
    AVAsset *urlAsset =[AVAsset assetWithURL:url];
    //
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey:@(YES)};
    AVURLAsset *urlAsset2 = [[AVURLAsset alloc] initWithURL:url options:options];
    
    //异步查询属性状态
    NSArray *keys = @[@"tracks"];
    [urlAsset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        NSError *error;
        AVKeyValueStatus status = [urlAsset statusOfValueForKey:@"tracks" error:&error];
        switch (status) {
            case AVKeyValueStatusLoaded:
                //加载完成 从这里获取对应属性值
                break;
            case AVKeyValueStatusLoading:
                break;
            case AVKeyValueStatusFailed:
                break;
            case AVKeyValueStatusCancelled:
                break;
            default:
                break;
        }
    }];
   
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self testMetData];
}

- (void)interviewPhotoLib{
    PHPhotoLibrary *photoLib = [[PHPhotoLibrary alloc] init];
 

   
}
 
- (void)testMetData{
    NSURL* totoUrl = [[NSBundle mainBundle] URLForResource:@"Charlie The Unicorn" withExtension:@"m4v"];
    AVAsset *urlAsset =[AVAsset assetWithURL:totoUrl];
    NSMutableArray *metaItemsArr = [NSMutableArray array];
    for (NSString* formatkey in [urlAsset availableMetadataFormats]) {
        NSLog(@"formate===%@",formatkey);
        [metaItemsArr addObject:  [urlAsset metadataForFormat:formatkey]];
    }
    NSArray* metaItems = metaItemsArr[1];
    
    NSString* keySpace = AVMetadataKeySpaceiTunes;
    NSString* artistKey = AVMetadataiTunesMetadataKeyArtist;
    NSString* albumKey = AVMetadataiTunesMetadataKeyAlbum;
    
//    NSArray* artistItems = [AVMetadataItem metadataItemsFromArray:metaItems withKey:artistKey keySpace:keySpace];
    NSArray* albumItems = [AVMetadataItem metadataItemsFromArray:metaItems withKey:albumKey keySpace:keySpace];
    //ios8 以后建议通过标识符获取
    NSArray* artistItems  = [AVMetadataItem metadataItemsFromArray:metaItems filteredByIdentifier:AVMetadataIdentifieriTunesMetadataArtist];
    
    
    if (artistItems.count>0) {
        //通常只有一个,
        AVMetadataItem *artistItem = [artistItems firstObject];
        NSLog(@" ---artist--\n key===%@,keyString==%@,comomkey==%@,value==%@,identifier=%@ \n",artistItem.key,artistItem.keyString,artistItem.commonKey,artistItem.value,artistItem.identifier);
        
    }
    if (albumItems.count) {
        AVMetadataItem *albumItem = [albumItems firstObject];
        NSLog(@" ---albumItem--\n key===%@,comomkey==%@,value==%@ \n",albumItem.key,albumItem.commonKey,albumItem.value);
    }
    //
//    AVMutableMetadataItem
//    AVAssetExportSession:
     
//    AVTimedMetadataGroup
    
}

@end
