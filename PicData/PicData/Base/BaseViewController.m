//
//  BaseViewController.m
//  PicData
//
//  Created by Garenge on 2020/11/4.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)dealloc {
    NSLog(@"%s 被释放了?", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self loadNavigationItem];
    [self loadMainView];
}

- (void)loadNavigationItem {
    
}

- (void)loadMainView {
    self.view.backgroundColor = [UIColor whiteColor];
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
