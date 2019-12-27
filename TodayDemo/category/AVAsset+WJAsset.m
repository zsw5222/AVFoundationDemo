//
//  AVAsset+WJAsset.m
//  TodayDemo
//
//  Created by jalon on 2019/12/25.
//  Copyright © 2019 ore. All rights reserved.
//

#import "AVAsset+WJAsset.h"

 

@implementation AVAsset (WJAsset)
- (NSString *)title{
    NSString* tit = @"";
    AVKeyValueStatus status = [self statusOfValueForKey:@"commonMetadata" error:nil];
    if (status == AVKeyValueStatusLoaded) {
        NSArray<AVMetadataItem*>  * metaItems = [AVMetadataItem metadataItemsFromArray:self.commonMetadata filteredByIdentifier:AVMetadataCommonIdentifierTitle];
        if (metaItems.count>0) {
            tit = (NSString*)metaItems.firstObject.value;
        }
    }else{
        NSLog(@"属性未加载");
    }
    return tit;
}
@end
