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
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [self pushViewController:viewController animated:animated];
}

@end
