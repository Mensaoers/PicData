//
//  AppTabBarController.m
//  PicData
//
//  Created by Garenge on 2020/11/4.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "AppTabBarController.h"
#import "HomeViewController.h"
#import "SettingViewController.h"
#import "LocalFileListVC.h"
#import "TasksViewController.h"

@interface AppTabBarController ()

@end

@implementation AppTabBarController

+ (void)initialize {
    //appearance方法返回一个导航栏的外观对象
    //修改了这个外观对象，相当于修改了整个项目中的外观
    UITabBar *tabBar = [UITabBar appearance];
    //设置导航栏背景颜色
    if (@available(iOS 15.0, *)) {
        UITabBarAppearance *appearence = [[UITabBarAppearance alloc] init];
        appearence.backgroundColor = [UIColor whiteColor];
        tabBar.standardAppearance = appearence;
        tabBar.scrollEdgeAppearance = appearence;
    } else {
        [tabBar setBarTintColor:UIColor.whiteColor];
    }
//    if (@available(macCatalyst 17.0, *)) {
//        tabBar.traitOverrides.horizontalSizeClass = UIUserInterfaceSizeClassCompact;
//    } else {
//            // Fallback on earlier versions
//    }
    [tabBar setTintColor:ThemeColor];
    [tabBar setUnselectedItemTintColor:ThemeDisabledColor];

    UITabBarItem *tabBarItem = [UITabBarItem appearance];
    [tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: ThemeDisabledColor, NSFontAttributeName: [UIFont systemFontOfSize:12]} forState: UIControlStateNormal];

    [tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: ThemeColor, NSFontAttributeName: [UIFont systemFontOfSize:12]} forState: UIControlStateSelected];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)prepare {

    if (@available(macCatalyst 18.0, *)) {
        self.mode = UITabBarControllerModeTabSidebar;
    } else {
            // Fallback on earlier versions
    }
    
    if (@available(macCatalyst 17.0, *)) {
        self.traitOverrides.horizontalSizeClass = UIUserInterfaceSizeClassCompact;
    } else {
            // Fallback on earlier versions
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNoticeOfDownloadPath:) name:NOTICECHECKDOWNLOADPATHKEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationThatInitHostModelsFailed:) name:NotificationNameInitHostModelsFailed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationThatClearedAllFiles:) name:NotificationNameClearedAllFiles object:nil];

    // 主页
    HomeViewController *indexVC = [[HomeViewController alloc] init];
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

    // 下载
    TasksViewController *tasksVC = [[TasksViewController alloc] init];
    BaseNavigationController *tasksNavi = [[BaseNavigationController alloc] initWithRootViewController:tasksVC];
    tasksNavi.tabBarItem.selectedImage = [[UIImage imageNamed:@"downloaded"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tasksNavi.tabBarItem.image = [[UIImage imageNamed:@"download_disabled"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tasksNavi.tabBarItem.title = @"下载";

    // 设置
    SettingViewController *settingVC = [[SettingViewController alloc] init];
    BaseNavigationController *settingNavi = [[BaseNavigationController alloc] initWithRootViewController:settingVC];
    settingNavi.tabBarItem.selectedImage = [[UIImage imageNamed:@"set"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    settingNavi.tabBarItem.image = [[UIImage imageNamed:@"set_disabled"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    settingNavi.tabBarItem.title = @"设置";

    self.viewControllers = @[indexNavi, viewerNavi, tasksNavi, settingNavi];
}

- (void)receiveNoticeOfDownloadPath:(NSNotification *)notification {

    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlertWithTitle:@"提醒" message:@"下载路径设置有误, 请确认地址" confirmTitle:@"去设置" confirmHandler:^(UIAlertAction * _Nonnull action) {
            [self setSelectedIndex:3];
        } cancelTitle:@"稍后" cancelHandler:nil];
    });
}

- (void)notificationThatInitHostModelsFailed:(NSNotification *)notification {

    [self showAlertWithTitle:nil message:@"初始化域名模组失败, 无法使用APP" confirmTitle:@"退出" confirmHandler:^(UIAlertAction * _Nonnull action) {
        // TODO: 所有的杀死应用, 改为发送一个通知, 统一退出
        abort();
    }];
}

- (void)notificationThatClearedAllFiles:(NSNotification *)notification {
    BaseNavigationController *navi = self.viewControllers[1];
    [navi popToRootViewControllerAnimated:YES];
}
@end
