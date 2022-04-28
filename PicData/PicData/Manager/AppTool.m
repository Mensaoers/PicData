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
        NSArray *array = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:NSJSONReadingMutableContainers error:&jsError];
        if (nil == jsError) {
            _hostModels = [PicNetModel mj_objectArrayWithKeyValuesArray:array];
        }

        if (nil == _hostModels || _hostModels.count == 0) {
            PicNetModel *netModel = [PicNetModel new];
            netModel.title = @"https://www.tu963.cc";
            netModel.sourceType = 2;
            netModel.HOST_URL = @"https://www.tu963.cc";
            _hostModels = @[netModel];
        }
    }
    return _hostModels;
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
            [MBProgressHUD showInfoOnView:UIApplication.sharedApplication.keyWindow WithStatus:@"已经复制到粘贴板"];
            return;
        }

        NSString *filePath = urls.firstObject.path;
        NSString *release = @"release";
#ifdef DEBUG
        release = @"debug";
#endif
        NSString *bundleFile = [NSString stringWithFormat:@"PicData_macPlugin_%@.bundle", release];
        NSURL *bundleURL = [[[NSBundle mainBundle] builtInPlugInsURL] URLByAppendingPathComponent:bundleFile];
        if (!bundleURL) {
            return;
        }
        NSBundle *pluginBundle = [NSBundle bundleWithURL:bundleURL];
        NSString *className = @"Plugin";
        Class Plugin= [pluginBundle classNamed:className];
        //    Plugin *obj = [[Plugin alloc] init];
        SEL openSel = NSSelectorFromString(@"openFileOrDirWithPath:");
        if ([Plugin respondsToSelector:openSel]) {
            [Plugin performSelector:NSSelectorFromString(@"openFileOrDirWithPath:") withObject:filePath];
        }
        return;
#endif
    }

    UIViewController *topRootViewController = UIApplication.sharedApplication.keyWindow.rootViewController;

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:urls applicationActivities:nil];
    if (completionWithItemsHandler) {
        activityVC.completionWithItemsHandler = completionWithItemsHandler;
    } else {
        activityVC.completionWithItemsHandler = ^(UIActivityType __nullable activityType, BOOL completed, NSArray *__nullable returnedItems, NSError *__nullable activityError) {
            NSLog(@"调用分享的应用id :%@", activityType);
            if (completed) {
                NSLog(@"分享成功!");
            } else {
                NSLog(@"分享失败!");
            }
        };
    }

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

@end
