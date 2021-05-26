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

FOUNDATION_EXTERN NSString *const HOST_URL_4c4crt;

/// bugly app_id
+ (NSString *)app_id_bugly;

/// 获取当前是否支持横屏
+ (BOOL)getCanChangeOrientation;

/// 设置当前是否支持横屏
+ (BOOL)setCanChangeOrientation:(BOOL)value;

/// 分享app中的文件,区分是iOS端或者mac端
+ (void)shareFileWithURLs:(NSArray <NSURL *>*)urls sourceView:(UIView *)sourceView completionWithItemsHandler:(UIActivityViewControllerCompletionWithItemsHandler)completionWithItemsHandler;

@end

NS_ASSUME_NONNULL_END
