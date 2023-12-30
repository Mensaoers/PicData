//
//  AppTool.m
//  PicData
//
//  Created by Garenge on 2021/1/5.
//  Copyright © 2021 garenge. All rights reserved.
//

#import "AppTool.h"

#define KHOSTURLKEY @"KHOSTURLKEY"

/// 是否可以旋转页面, 不可以
static BOOL canChangeOrientation = NO;

@implementation AppTool

singleton_implementation(AppTool)

- (NSMutableArray *)referTypes {
    if (nil == _referTypes) {
        _referTypes = [NSMutableArray array];
    }
    return _referTypes;
}

- (NSString *)HOST_URL {
    return [AppTool sharedAppTool].currentHostModel.HOST_URL;
}

@synthesize currentHostModel = _currentHostModel;

- (PicNetModel *)currentHostModel {
    if (nil == _currentHostModel) {

        NSString *host_url = [self getHost_url];
        for (PicNetModel *netModel in [self hostModels]) {
            if ([netModel.HOST_URL isEqualToString:host_url]) {
                _currentHostModel = netModel;
            }
        }

        if (nil == _currentHostModel) {
            _currentHostModel = [self hostModels].firstObject;
            [self saveHost_url:_currentHostModel.HOST_URL];
        }
    }
    return _currentHostModel;
}

- (void)setCurrentHostModel:(PicNetModel *)currentHostModel {
    _currentHostModel = currentHostModel;

    [self saveHost_url:currentHostModel.HOST_URL];
}

- (NSString *)getHost_url {
    NSString *host_url = [[NSUserDefaults standardUserDefaults] valueForKey:KHOSTURLKEY];
    NSLog(@"获取到HOST: %@", host_url);
    return host_url;
}

- (BOOL)saveHost_url:(NSString *)host_url {
    NSLog(@"保存HOST: %@", host_url);
    [[NSUserDefaults standardUserDefaults] setValue:host_url forKey:KHOSTURLKEY];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

@synthesize hostModels = _hostModels;
- (NSArray<PicNetModel *> *)hostModels {
    if (nil == _hostModels) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"PicNet" ofType:@"json"];
        NSError *jsError = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:NSJSONReadingMutableContainers error:&jsError];
        NSArray *array = dictionary[@"hosts"];
        _searchKeys = [dictionary[@"searchKeys"] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
        if (nil == jsError && array.count > 0) {
            NSArray *hostModels = [PicNetModel mj_objectArrayWithKeyValuesArray:array];
            NSMutableArray *hostModelsM = [NSMutableArray array];
            for (PicNetModel *model in hostModels) {
                if (!model.prepared) { continue; }
                [hostModelsM addObject:model];

                if (model.referer.length > 0) {
                    [self.referTypes addObject:@(model.sourceType)];
                }
            }
            _hostModels = hostModelsM.copy;
        }

        if (nil == _hostModels || _hostModels.count == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNameInitHostModelsFailed object:nil];
        }
    }
    return _hostModels;
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

/// 分享app中的文件,区分是iOS端或者mac端
+ (void)shareFileWithURLs:(NSArray <NSURL *>*)urls sourceView:(UIView *)sourceView completionWithItemsHandler:(nonnull UIActivityViewControllerCompletionWithItemsHandler)completionWithItemsHandler {

    if (urls.count == 0) {
        return;
    }

    if (urls.count == 1) {

#if TARGET_OS_MACCATALYST
        NSString *url = urls.firstObject.absoluteString;

        if ([url hasPrefix:@"https://"] || [url hasPrefix:@"http://"]) {
            [UIPasteboard generalPasteboard].string = url;
            [MBProgressHUD showInfoOnView:[AppTool getAppKeyWindow] WithStatus:@"已经复制到粘贴板"];
            return;
        }

        NSString *filePath = urls.firstObject.path;

        [[PPCatalystHandle sharedPPCatalystHandle] openFileOrDirWithPath:filePath];
        return;
#endif
    }

    [self shareWithActivityItems:urls sourceView:sourceView completionWithItemsHandler:completionWithItemsHandler];
}

/// 调用系统分享
+ (void)shareWithActivityItems:(NSArray *)ctivityItems sourceView:(UIView *)sourceView completionWithItemsHandler:(nonnull UIActivityViewControllerCompletionWithItemsHandler)completionWithItemsHandler {

//    UIViewController *topRootViewController = [AppTool getAppKeyWindow].rootViewController;
    /** 划重点
     *  imageBrowser是加载在keyWindow上的, 遮挡住控制器keyWindow.rootViewController
     *  控制器弹出新的界面都没有imageBrowser的界面高, 都会被遮挡
     *  也就是说, 我们哪怕获取了顶层控制器, present:activityVC的时候, 也会被预览图遮住
     *  所以我们新建一个临时的window, 设置一个空白的控制器tmpViewController
     *  用这个临时控制器去弹出分享视图activityVC
     */

    UIViewController *topRootViewController = UIApplication.sharedApplication.windows.firstObject.rootViewController;
    UIWindow *tmpWindow;

    if ([ctivityItems.firstObject isKindOfClass:[NSURL class]]) {
        NSURL *urlObjc = ctivityItems.firstObject;
        NSArray *targetPathExtension = @[@"jpg", @"jpeg", @"png"];
        if ([targetPathExtension containsObject:urlObjc.absoluteString.lastPathComponent.pathExtension]) {
            topRootViewController = [[UIViewController alloc] init];
            tmpWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            topRootViewController.view.backgroundColor = [UIColor clearColor];
            tmpWindow.windowLevel = UIWindowLevelAlert - 1;
            tmpWindow.rootViewController = topRootViewController;
            [tmpWindow makeKeyAndVisible];
        }
    }

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:ctivityItems applicationActivities:nil];
    activityVC.completionWithItemsHandler = ^(UIActivityType __nullable activityType, BOOL completed, NSArray *__nullable returnedItems, NSError *__nullable activityError) {
        [tmpWindow resignKeyWindow];
        NSLog(@"调用分享的应用id :%@", activityType);
        if (completed) {
            NSLog(@"分享成功!");
        } else {
            NSLog(@"分享失败!");
        }
        PPIsBlockExecute(completionWithItemsHandler, activityType, completed, returnedItems, activityError);
    };

    if ([[UIDevice currentDevice].model isEqualToString:@"iPhone"]) {
        [topRootViewController presentViewController:activityVC animated:YES completion:nil];
    } else if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
        UIPopoverPresentationController *popover = activityVC.popoverPresentationController;
        if (popover) {
            popover.sourceView = sourceView;
            popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
        }
        [topRootViewController presentViewController:activityVC animated:YES completion:nil];
    } else {
        //do nothing
    }
}

+ (void)setupPerformanceMonitor {
    [[GDPerformanceMonitor sharedInstance] startMonitoring];

    [[GDPerformanceMonitor sharedInstance] setAppVersionHidden:YES];
    [[GDPerformanceMonitor sharedInstance] setDeviceVersionHidden:YES];

    [[GDPerformanceMonitor sharedInstance] configureWithConfiguration:^(UILabel *textLabel) {
        textLabel.font = [UIFont systemFontOfSize:15];
        [textLabel setBackgroundColor:[UIColor blackColor]];
        [textLabel setTextColor:[UIColor whiteColor]];
        [textLabel.layer setBorderColor:[[UIColor blackColor] CGColor]];
    }];

    AppTool.sharedAppTool.isPerformanceMonitor = YES;
}

- (void)setIsPerformanceMonitor:(BOOL)isPerformanceMonitor {
    _isPerformanceMonitor = isPerformanceMonitor;

    if (isPerformanceMonitor) {
        [[GDPerformanceMonitor sharedInstance] startMonitoring];
    } else {
        [[GDPerformanceMonitor sharedInstance] hideMonitoring];
    }
}

+ (void)inversePerformanceMonitorStatus {
    AppTool.sharedAppTool.isPerformanceMonitor = !AppTool.sharedAppTool.isPerformanceMonitor;
}

+ (UIWindow *)getAppKeyWindow {
    UIWindow *foundWindow = nil;
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in windows) {
        if (window.isKeyWindow) {
            foundWindow = window;
            break;
        }
    }
    return foundWindow;
}

+ (NSStringEncoding)getNSStringEncoding_GB_18030_2000 {
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    return enc;
}

+ (NSString *)getStringWithGB_18030_2000Code:(NSData *)data {
    return [self getStringWithData:data dataEncoding:[self getNSStringEncoding_GB_18030_2000]];
}
+ (NSString *)getStringWithUTF8Code:(NSData *)data {
    return [self getStringWithData:data dataEncoding:NSUTF8StringEncoding];
}
+ (NSString *)getStringWithData:(NSData *)data dataEncoding:(NSStringEncoding)dataEncoding {
    return [[NSString alloc] initWithData:data encoding:dataEncoding];
}

#pragma mark - SDWebImage

- (NSMutableDictionary<NSString *, PPSDWebImageManager *> *)managers {
    if (nil == _managers) {
        _managers = [NSMutableDictionary dictionary];
    }
    return _managers;
}

+ (SDWebImageManager *)sdWebImageManager:(NSString *)referer sourceType:(int)sourceType {
    
    NSDictionary *headerFields = @{
        @"referer": referer,
        @"User-Agent" : @"Mozilla/5.0 (Macintosh; Intel Mac OS X 11_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.66 Safari/537.36",
    };
    
    return [self sdWebImageManagerWithHeaderFields:headerFields sourceType:sourceType];
}
+ (SDWebImageManager *)sdWebImageManagerWithHeaderFields:(NSDictionary *)headerFields sourceType:(int)sourceType {

    if (nil == headerFields || headerFields.count == 0 || ![AppTool.sharedAppTool.referTypes containsObject:@(sourceType)]) {
        return [SDWebImageManager sharedManager];
    }

    NSString *sourceTypeKey = [NSString stringWithFormat:@"%d", sourceType];
    PPSDWebImageManager *manager = AppTool.sharedAppTool.managers[sourceTypeKey];

    if (nil == manager) {
        // 默认的cache
        id<SDImageCache> cache = [[SDWebImageManager class] defaultImageCache];
        if (!cache) {
            cache = [SDImageCache sharedImageCache];
        }

        // 自定义的loader
        SDWebImageDownloader *loader = [[SDWebImageDownloader alloc] initWithConfig:SDWebImageDownloaderConfig.defaultDownloaderConfig];
        for (NSString *key in headerFields.allKeys) {
//            [loader setValue:referer forHTTPHeaderField:@"Referer"];
            [loader setValue:headerFields[key] forHTTPHeaderField:key];
        }

        manager = [[PPSDWebImageManager alloc] initWithCache:cache loader:loader];

        AppTool.sharedAppTool.managers[sourceTypeKey] = manager;
    }

    return manager;
}

+ (void)releaseSDWebImageManager:(NSString *)referer {
    PPSDWebImageManager *manager = AppTool.sharedAppTool.managers[referer];
    if (manager) {
        [manager cancelAll];
        [manager.imageCache clearWithCacheType:SDImageCacheTypeAll completion:nil];
    }
    AppTool.sharedAppTool.managers[referer] = nil;
    NSLog(@"AppTool.sharedAppTool.managers: %@", AppTool.sharedAppTool.managers.allKeys);
}

+ (void)clearSDWebImageCache {
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    [[SDImageCache sharedImageCache] clearWithCacheType:SDImageCacheTypeAll completion:nil];
}

@end
