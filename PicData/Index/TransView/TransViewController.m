//
//  TransViewController.m
//  PicData
//
//  Created by CleverPeng on 2020/8/7.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "TransViewController.h"

@interface TransViewController ()

@end

@implementation TransViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"下载列表";
    [self loadMainView];
}

////可选实现协议的方法 传入标题和图片
// - (NSDictionary *)floatViewConfig{
//   return @{@"name":@"下载列表",@"icon":@"float_image"};
//}

- (void)loadMainView {
    self.view.backgroundColor = [UIColor whiteColor];
}
@end
