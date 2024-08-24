//
//  MBProgressHUD+LZPShow.h
//  ThinkDrive_For_iPhone
//
//  Created by istLZP on 2017/12/18.
//  Copyright © 2017年 Richinfo. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (LZPShow)
+ (void)showInfoOnView:(UIView *)view WithStatus:(NSString *)status;
+ (void)showInfoOnView:(UIView *)view WithStatus:(NSString *)status afterDelay:(NSTimeInterval)delay;
+ (void)showHUDAddedTo:(UIView *)view WithStatus:(NSString *)status;
+ (MBProgressHUD *)showProgressOnView:(UIView *)view WithStatus:(NSString *)status progress:(CGFloat)progress;
@end
