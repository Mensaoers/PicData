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

+(void)load
{
    // hook：钩子函数
    Method method1 = class_getInstanceMethod(self, @selector(pushViewController:animated:));

    Method method2 = class_getInstanceMethod(self, @selector(pp_pushViewController:animated:));
    method_exchangeImplementations(method1, method2);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) wkself = self;
    self.delegate = wkself;
    self.interactivePopGestureRecognizer.delegate = wkself;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *viewController = [super popViewControllerAnimated:animated];
    __weak typeof(self) wkself = self;
    self.delegate = wkself;
    return viewController;
}

@end
