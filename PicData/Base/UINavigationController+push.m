//
//  UINavigationController+push.m
//  PicData
//
//  Created by 鹏鹏 on 2020/11/5.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "UINavigationController+push.h"

@implementation UINavigationController (push)

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated needHiddenTabBar:(BOOL)needHiddenTabBar {
    if (needHiddenTabBar) {
        if (self.viewControllers.count >= 1) {
            viewController.hidesBottomBarWhenPushed = YES;
        }
    }
    [self pp_pushViewController:viewController animated:animated];
}

- (void)pp_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self pushViewController:viewController animated:animated needHiddenTabBar:NO];
}

@end
