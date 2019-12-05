//
//  UIViewController+WH.m
//  TodayDemo
//
//  Created by jalon on 2019/12/4.
//  Copyright © 2019 ore. All rights reserved.
//

#import "UIViewController+WH.h"



@implementation UIViewController (WH)

- (void)showText:(NSString *)string sure:(nonnull void (^)(NSString * name_Nonnull))sb   cancel:(normal_block)cb{
    __block UITextField *nameTf = nil;
    UIAlertAction *act1 = [UIAlertAction actionWithTitle:@"sure" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (sb) {
            sb(nameTf.text);
        }
    }];
    UIAlertAction *act2 = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (cb) {
            cb();
        }
     }];
    UIAlertController *con = [UIAlertController alertControllerWithTitle:string message:nil preferredStyle:UIAlertControllerStyleAlert];
    [con addAction:act1];
    [con addAction:act2];
    [con addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        nameTf = textField;
    }];
    [self presentViewController:con animated:YES completion:nil];
     
 
}
@end
