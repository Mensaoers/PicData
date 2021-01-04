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
