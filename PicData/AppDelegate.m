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
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    IndexViewController *indexVC = [[IndexViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:indexVC];
    [self.window setRootViewController:navi];
    [self.window makeKeyAndVisible];

    [self registerNotice];
    
    TRSessionConfiguration *configuraion = [[TRSessionConfiguration alloc] init];
    configuraion.allowsCellularAccess = YES;
    self.sessionManager = [[TRSessionManager alloc] initWithIdentifier:@"ViewController" configuration:configuraion];
    
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
