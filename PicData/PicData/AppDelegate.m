//
//  AppDelegate.m
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "AppDelegate.h"
#import <FirebaseCore/FirebaseCore.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)setUpMainTab {
    AppTabBarController *tabbarVC = [[AppTabBarController alloc] init];
    [tabbarVC prepare];

    [self.window setRootViewController:tabbarVC];
    [self.window makeKeyAndVisible];
}

- (void)setupDownloadManager {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [ContentParserManager prepareForAppLaunch];
    });

    // TODO: APP后台下载的问题, 目前移除了下载SDK, 后台下载已经不现实了
}

- (void)setupDataBase {
    [PDDownloadManager prepareDatabase];
}

- (void)setupIQKeyboardManager {
    IQKeyboardManager.sharedManager.shouldResignOnTouchOutside = YES;
    IQKeyboardManager.sharedManager.enable = YES;
}

- (void)setupGDPerformanceMonitor {
    [AppTool setupPerformanceMonitor];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    self.window.windowScene.sizeRestrictions.minimumSize = CGSizeMake(400, 600);
    self.window.windowScene.sizeRestrictions.maximumSize = CGSizeMake(800, 600);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.window.windowScene.sizeRestrictions.maximumSize = CGSizeMake(9999, 9999);
    });

    [self setupIQKeyboardManager];

    [self setupGDPerformanceMonitor];

    // 设置主页
    [self setUpMainTab];

    // 设置手势
    [self setupGestureLock];

    // 注册通知
    [self registerNotice];

    // 数据库初始化
    [self setupDataBase];

    // 下载模块初始化
    [self setupDownloadManager];
    
    [FIRApp configure];

    // 检查更新
    dispatch_after(2, dispatch_get_main_queue(), ^{
        [PDRequest requestToCheckVersion:YES onView:self.window completehandler:nil];

        [[SocketManager sharedSocketManager] connect];
    });

    /// 设置屏幕常亮
    application.idleTimerDisabled = YES;

    return YES;
}

- (void)setupGestureLock {
    [[TKGestureLockManager sharedInstance] saveGesturesPassword:@"8416"];
//#if TARGET_OS_MACCATALYST
//    [[TKGestureLockManager sharedInstance] updateGestureLock:NO];
//#else
//
//// #if DEBUG 只要是xcode直接跑的都是debug(杀死应用重启也还是调试)
//    BOOL isDebugged = AmIBeingDebugged();
//    if (isDebugged) {
//        [[TKGestureLockManager sharedInstance] updateGestureLock:NO];
//    } else {
//        [[TKGestureLockManager sharedInstance] updateGestureLock:YES];
//        [[TKGestureLockManager sharedInstance] saveGesturesPassword:@"8416"];
//    }
//
//#endif
}

- (void)registerNotice {

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveGestureUnlockFaild:) name:TKGestureLockNotice_unlockFailed object:nil];
}

- (void)receiveGestureUnlockFaild:(NSNotification *)notification {
    abort();
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[TKGestureLockManager sharedInstance] showGestureLockWindow];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[TKGestureLockManager sharedInstance] showGestureLockWindow];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[TKGestureLockManager sharedInstance] showGestureLockWindow];
}

/// 屏幕旋转相关
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if ([AppTool getCanChangeOrientation]) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

@end
