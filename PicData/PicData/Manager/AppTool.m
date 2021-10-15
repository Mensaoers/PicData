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

NSString *const HOST_URL_4c4crt = @"https://w12.qqv16.vip:5561/";

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

        NSString *filePath = urls.firstObject.path;

#if TARGET_OS_MACCATALYST
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

+ (NSStringEncoding)getNSStringEncoding_GB_18030_2000 {
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    return enc;
}

+ (NSString *)getStringWithGB_18030_2000Code:(NSData *)data {
    return [[NSString alloc] initWithData:data encoding:[self getNSStringEncoding_GB_18030_2000]];
}

@end
