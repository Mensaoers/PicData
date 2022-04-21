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

singleton_interface(AppTool)

@property (nonatomic, strong) NSString *HOST_URL;

/// bugly app_id
+ (NSString *)app_id_bugly;

/// 获取当前是否支持横屏
+ (BOOL)getCanChangeOrientation;

/// 设置当前是否支持横屏
+ (BOOL)setCanChangeOrientation:(BOOL)value;

/// 分享app中的文件,区分是iOS端或者mac端
+ (void)shareFileWithURLs:(NSArray <NSURL *>*)urls sourceView:(UIView *)sourceView completionWithItemsHandler:(UIActivityViewControllerCompletionWithItemsHandler)completionWithItemsHandler;

/// 初始化监控
+ (void)setupPerformanceMonitor;
/// 反选监控状态 开/关
+ (void)inversePerformanceMonitorStatus;

@property (nonatomic, assign, readonly) BOOL isPerformanceMonitor;

+ (UIWindow *)getAppKeyWindow;

/// 获取中文编码
+ (NSStringEncoding)getNSStringEncoding_GB_18030_2000;
/// data转字符串 中文编码
+ (NSString *)getStringWithGB_18030_2000Code:(NSData *)data;
+ (NSString *)getStringWithUTF8Code:(NSData *)data;
+ (NSString *)getStringWithData:(NSData *)data dataEncoding:(NSStringEncoding)dataEncoding;

@end

NS_ASSUME_NONNULL_END
