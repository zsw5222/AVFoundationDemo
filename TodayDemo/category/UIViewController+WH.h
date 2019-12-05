//
//  UIViewController+WH.h
//  TodayDemo
//
//  Created by jalon on 2019/12/4.
//  Copyright © 2019 ore. All rights reserved.
//
 
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^normal_block)(void)  ;
@interface UIViewController (WH)
- (void)showText:(NSString*)string sure:(void(^)(NSString* name))sb  cancel:(normal_block)cb;
@end

NS_ASSUME_NONNULL_END
