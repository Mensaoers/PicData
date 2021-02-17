//
//  AppTool.h
//  PicData
//
//  Created by Garenge on 2021/1/5.
//  Copyright © 2021 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppTool : NSObject

/// web主地址
FOUNDATION_EXTERN NSString *const HOST_URL_AITAOTU;
/// wap主地址
FOUNDATION_EXTERN NSString *const HOST_URL_M_AITAOTU;
/// wap标签地址
FOUNDATION_EXTERN NSString *const HOST_URL_M_AITAOTU_TAG;

/// 蒲公英appKey
+ (NSString *)app_key_pgy;
/// bugly app_id
+ (NSString *)app_id_bugly;

/// 获取当前是否支持横屏
+ (BOOL)getCanChangeOrientation;

/// 设置当前是否支持横屏
+ (BOOL)setCanChangeOrientation:(BOOL)value;

@end

NS_ASSUME_NONNULL_END
