//
//  AppTool.m
//  PicData
//
//  Created by Garenge on 2021/1/5.
//  Copyright © 2021 garenge. All rights reserved.
//

#import "AppTool.h"

/// 是否可以旋转页面, 不可以
static BOOL canChangeOrientation = NO;

@implementation AppTool

/// web主地址
NSString *const HOST_URL_AITAOTU = @"https://www.aitaotu.com/";
/// wap主地址
NSString *const HOST_URL_M_AITAOTU = @"https://m.aitaotu.com/";
/// wap标签地址
NSString *const HOST_URL_M_AITAOTU_TAG = @"https://m.aitaotu.com/tag/";

/// 获取当前是否支持横屏
+ (BOOL)getCanChangeOrientation {
    return canChangeOrientation;
}

/// 设置当前是否支持横屏
+ (BOOL)setCanChangeOrientation:(BOOL)value {
    canChangeOrientation = value;
    return YES;
}

@end
