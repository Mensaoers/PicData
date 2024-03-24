//
//  AppTool.h
//  PicData
//
//  Created by Garenge on 2021/1/5.
//  Copyright © 2021 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PicNetModel.h"

NS_ASSUME_NONNULL_BEGIN

#define NotificationNameClearedAllFiles @"NotificationNameClearedAllFiles"
#define NotificationNameInitHostModelsFailed @"NotificationNameInitHostModelsFailed"

@interface AppTool : NSObject

singleton_interface(AppTool)

@property (nonatomic, strong) NSString *HOST_URL;

@property (nonatomic, strong, nonnull) PicNetModel *currentHostModel;

@property (nonatomic, strong, readonly) NSArray <PicNetModel *> *hostModels;
@property (nonatomic, strong, readonly) NSArray <NSString *> *searchKeys;

/// 获取当前是否支持横屏
+ (BOOL)getCanChangeOrientation;

/// 设置当前是否支持横屏
+ (BOOL)setCanChangeOrientation:(BOOL)value;

/// 分享app中的文件,区分是iOS端或者mac端
+ (void)shareFileWithURLs:(NSArray <NSURL *>*)urls sourceView:(UIView *)sourceView completionWithItemsHandler:(UIActivityViewControllerCompletionWithItemsHandler)completionWithItemsHandler;
/// 调用系统分享
+ (void)shareWithActivityItems:(NSArray *)ctivityItems sourceView:(UIView *)sourceView completionWithItemsHandler:(nonnull UIActivityViewControllerCompletionWithItemsHandler)completionWithItemsHandler;

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

@property (nonatomic, strong) NSMutableArray *referTypes;

/// 自定义sdWebImageManager, 以实现不同的任务设置不同的header(部分网站需要提供"referer"的header设置)
/// SDWebImageDownloader只支持设置一次header, 内部创建的request都是使用这个header, 不利于加载各式各样的来源图片, 所以我们需要多个downloader, 也就是多个manager来管理(是否真的需要创建多个manager)
/// 还有一个点没考虑清楚的是SDImageLoadersManager这个类, 它持有一个loaders数组, 管理downloader, 并根据- (BOOL)canRequestImageForURL:(NSURL *)url options:(SDWebImageOptions)options context:(SDWebImageContext *)context判断是否使用该loader加载图片, 跟我的+ (SDWebImageManager *)sdWebImageManager:(NSString *)referer;类似
/// 能用sdk提供的尽量用sdk的, 后面有机会再研究研究
@property (nonatomic, strong) NSMutableDictionary<NSString *, PPSDWebImageManager *> *managers;
/// 根据referer获取或创建一个新的manager
+ (SDWebImageManager *)sdWebImageManager:(NSString *)referer sourceType:(int)sourceType;
/// 根据referer释放指定manager
+ (void)releaseSDWebImageManager:(nullable NSString *)referer;
+ (void)clearSDWebImageCache;

@end

NS_ASSUME_NONNULL_END
