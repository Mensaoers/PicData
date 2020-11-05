//
//  BaseNavigationController.m
//  PicData
//
//  Created by Garenge on 2020/11/4.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()<UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@end

@implementation BaseNavigationController

+ (void)initialize {
    //appearance方法返回一个导航栏的外观对象
    //修改了这个外观对象，相当于修改了整个项目中的外观
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    //设置导航栏背景颜色
    [navigationBar setBarTintColor:UIColor.whiteColor];
    [navigationBar setTintColor:ThemeColor];

    UIFont *font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
    NSDictionary *dic = @{NSFontAttributeName:font,
                          NSForegroundColorAttributeName: ThemeColor};
    navigationBar.titleTextAttributes =dic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) wkself = self;
    self.delegate = wkself;
    self.interactivePopGestureRecognizer.delegate = wkself;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count >= 1) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *viewController = [super popViewControllerAnimated:animated];
    __weak typeof(self) wkself = self;
    self.delegate = wkself;
    return viewController;
}

@end
