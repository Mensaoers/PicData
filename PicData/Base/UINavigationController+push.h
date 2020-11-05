//
//  UINavigationController+push.h
//  PicData
//
//  Created by 鹏鹏 on 2020/11/5.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (push)

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated needHiddenTabBar:(BOOL)needHiddenTabBar;

@end

NS_ASSUME_NONNULL_END
