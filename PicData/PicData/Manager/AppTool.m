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

/// 蒲公英appKey
+ (NSString *)app_key_pgy {
    return @"de806dcb2f8f3f74c1f04ce6a18b610c";
}
/// bugly app_id
+ (NSString *)app_id_bugly {
    return @"8eb9d79660";
}

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
