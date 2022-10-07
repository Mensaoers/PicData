//
//  BaseViewController.m
//  PicData
//
//  Created by Garenge on 2020/11/4.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "BaseViewController.h"
#import "FloatingWindowView.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)willDealloc {
    NSLog(@"%@ dealloc 被释放了?", NSStringFromClass(self.class));
}
- (void)dealloc {
    [self willDealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self loadNavigationItem];
    [self loadMainView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [FloatingWindowView shareInstance].areaActFrame = self.view.bounds;
}

- (void)loadNavigationItem {
    
}

- (void)loadMainView {
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark 设置浮窗
- (void)setupFloating {
    [[FloatingWindowView shareInstance] isHidden:NO];

    [FloatingWindowView shareInstance].ClickAction = ^{

        BaseTabBarController *tabBarVC = (BaseTabBarController *)[AppTool getAppKeyWindow].rootViewController;
        [tabBarVC setSelectedIndex:0];
        BaseNavigationController *indexNavi = (BaseNavigationController *)tabBarVC.selectedViewController;

        NSArray *viewControllers = indexNavi.viewControllers;
        BOOL jumped = NO;
        for (UIViewController *viewController in viewControllers) {
            if ([viewController isKindOfClass:[AddNetTaskVC class]]) {
                // 弹过了, 不弹了
                jumped = YES;
                break;
            }
        }
        if (!jumped) {
            [indexNavi pushViewController:[[AddNetTaskVC alloc] init] animated:YES];
        }
    };
}

#pragma mark 执行自定义方法
- (void)performSelfFuncWithString:(NSString *)funcString withObject:(nullable id)object {
    if ([self respondsToSelector:NSSelectorFromString(funcString)]) {
        SEL selector = NSSelectorFromString(funcString);
        IMP imp = [self methodForSelector:selector];
        void (*func)(id, SEL, id) = (void *)imp;
        func(self, selector, object);
    }
}

@end
