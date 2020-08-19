//
//  TransViewController.m
//  PicData
//
//  Created by CleverPeng on 2020/8/7.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "TransViewController.h"
#import "AddNetTaskVC.h"

@interface TransViewController ()

@end

@implementation TransViewController

- (void)dealloc {
    NSLog(@"我要被释放了, %s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadNavigationItem];
    [self loadMainView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNoticeAboutAddNewTask:) name:NOTICECHEADDNEWTASK object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNoticeAboutAddNewDetailTask:) name:NOTICECHEADDNEWDETAILTASK object:nil];
}

- (void)loadNavigationItem {
    self.title = @"下载列表";
    // 下载
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTaskButtonClickAction:)];
    self.navigationItem.rightBarButtonItem = addItem;
}

- (void)loadMainView {
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)receiveNoticeAboutAddNewTask:(NSNotification *)notice {
    NSDictionary *userInfo = notice.userInfo;
    NSLog(@"新增套图: %@, %@", userInfo[@"contentTitle"], userInfo[@"contentHref"]);
}

- (void)receiveNoticeAboutAddNewDetailTask:(NSNotification *)notice {
    NSDictionary *userInfo = notice.userInfo;
    NSLog(@"新增套图:%@, 一共采集到:%@", userInfo[@"contentHref"], userInfo[@"contentCount"]);
}

#pragma mark 创建网络下载任务
- (void)addTaskButtonClickAction:(UIBarButtonItem *)sender {
    AddNetTaskVC *addVC = [[AddNetTaskVC alloc] init];
    [self.navigationController pushViewController:addVC animated:YES];
}
@end
