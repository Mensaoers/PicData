//
//  MBProgressHUD+LZPShow.m
//  ThinkDrive_For_iPhone
//
//  Created by istLZP on 2017/12/18.
//  Copyright © 2017年 Richinfo. All rights reserved.
//

#import "MBProgressHUD+LZPShow.h"

@implementation MBProgressHUD (LZPShow)

+ (void)showInfoOnView:(UIView *)view WithStatus:(NSString *)status {
    [self showInfoOnView:view WithStatus:status afterDelay:1.f];
}

+ (void)showInfoOnView:(UIView *)view WithStatus:(NSString *)status afterDelay:(NSTimeInterval)delay {
    [MBProgressHUD hideHUDForView:view animated:YES];
    MBProgressHUD *hud = [self showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.square = NO;
    hud.label.text = status;
    [hud hideAnimated:YES afterDelay:delay];
}


+ (void)showHUDAddedTo:(UIView *)view WithStatus:(NSString *)status {
    [MBProgressHUD hideHUDForView:view animated:YES];
    MBProgressHUD *hud = [self showHUDAddedTo:view animated:YES];
    hud.square = YES;
    hud.alpha = 0.7;
    hud.label.text = status;
}

+ (void)showProgressOnView:(UIView *)view WithStatus:(NSString *)status progress:(CGFloat)progress {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.label.text = @"status";
    hud.progress = progress;
    if (progress == 1) {
        [hud hideAnimated:YES];
    }
}

@end
