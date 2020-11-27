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

@end
