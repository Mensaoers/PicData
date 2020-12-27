//
//  AppDelegate.m
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "AppDelegate.h"
#import "IndexViewController.h"
#import "SettingViewController.h"
#import "LocalFileListVC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    BaseTabBarController *tabbarVC = [[BaseTabBarController alloc] init];
    
    // 主页
    IndexViewController *indexVC = [[IndexViewController alloc] init];
    BaseNavigationController *indexNavi = [[BaseNavigationController alloc] initWithRootViewController:indexVC];
    indexNavi.tabBarItem.selectedImage = [[UIImage imageNamed:@"home"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    indexNavi.tabBarItem.image = [[UIImage imageNamed:@"home_disabled"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    indexNavi.tabBarItem.title = @"首页";
    
    // 预览
    LocalFileListVC *viewerVC = [[LocalFileListVC alloc] init];
    BaseNavigationController *viewerNavi = [[BaseNavigationController alloc] initWithRootViewController:viewerVC];
    viewerNavi.tabBarItem.selectedImage = [[UIImage imageNamed:@"folder"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    viewerNavi.tabBarItem.image = [[UIImage imageNamed:@"folder_disabled"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    viewerNavi.tabBarItem.title = @"浏览";
    
    // 设置
    SettingViewController *settingVC = [[SettingViewController alloc] init];
    BaseNavigationController *settingNavi = [[BaseNavigationController alloc] initWithRootViewController:settingVC];
    settingNavi.tabBarItem.selectedImage = [[UIImage imageNamed:@"set"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    settingNavi.tabBarItem.image = [[UIImage imageNamed:@"set_disabled"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    settingNavi.tabBarItem.title = @"设置";
    
    tabbarVC.viewControllers = @[indexNavi, viewerNavi, settingNavi];
    
    
    [self.window setRootViewController:tabbarVC];
    [self.window makeKeyAndVisible];

    [self registerNotice];

    TRSessionConfiguration *configuraion = [[TRSessionConfiguration alloc] init];
    configuraion.allowsCellularAccess = YES;
    self.sessionManager = [[TRSessionManager alloc] initWithIdentifier:@"ViewController" configuration:configuraion];
    NSLog(@"%@", [PDDownloadManager sharedPDDownloadManager].sessionManager);
    
    [self.sessionManager totalCancel];

    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    [JQFMDB shareDatabase:@"picdata.sqlite" path:documentDir];

    [PDRequest requestToCheckVersion:YES onView:self.window completehandler:nil];
    return YES;
}

- (void)registerNotice {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNoticeOfDownloadPath:) name:NOTICECHECKDOWNLOADPATHKEY object:nil];
}

- (void)receiveNoticeOfDownloadPath:(NSNotification *)notification {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"下载路径设置有误, 请确认地址" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        [self.window.rootViewController.navigationController pushViewController:[SettingViewController new] animated:YES];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"稍后" style:UIAlertActionStyleCancel handler:nil]];
    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
    if (identifier == self.sessionManager.identifier) {
        self.sessionManager.completionHandler = completionHandler;
    }
}

@end
