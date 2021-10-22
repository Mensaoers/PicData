//
//  BaseTabBarController.m
//  PicData
//
//  Created by Garenge on 2020/11/4.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "BaseTabBarController.h"

@interface BaseTabBarController ()

@end

@implementation BaseTabBarController

+ (void)initialize {
    //appearance方法返回一个导航栏的外观对象
    //修改了这个外观对象，相当于修改了整个项目中的外观
    UITabBar *tabBar = [UITabBar appearance];
    //设置导航栏背景颜色
    if (@available(iOS 15.0, *)) {
        UITabBarAppearance *appearence = [[UITabBarAppearance alloc] init];
        appearence.backgroundColor = [UIColor whiteColor];
        tabBar.standardAppearance = appearence;

#if !TARGET_OS_MACCATALYST
        tabBar.scrollEdgeAppearance = appearence;
#endif
    } else {
        [tabBar setBarTintColor:UIColor.whiteColor];
    }
    [tabBar setTintColor:ThemeColor];
    [tabBar setUnselectedItemTintColor:ThemeDisabledColor];

    UITabBarItem *tabBarItem = [UITabBarItem appearance];
    [tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: ThemeDisabledColor, NSFontAttributeName: [UIFont systemFontOfSize:12]} forState: UIControlStateNormal];

    [tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: ThemeColor, NSFontAttributeName: [UIFont systemFontOfSize:12]} forState: UIControlStateSelected];
}

@end
