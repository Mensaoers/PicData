//
//  TasksViewController.m
//  PicData
//
//  Created by 鹏鹏 on 2022/3/10.
//  Copyright © 2022 garenge. All rights reserved.
//

#import "TasksViewController.h"

@interface TasksViewController ()

@property (nonatomic, strong) NSMutableArray <PicContentTaskModel *> *dataList;

@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic, assign) BOOL canRefresh;

@end

@implementation TasksViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (!self.canRefresh) {
        return;
    }

    self.canRefresh = NO;
    MJWeakSelf
    // 2秒之内不重复刷新
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.canRefresh = YES;
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf loadDataList];
    });
}

- (NSMutableArray<PicContentTaskModel *> *)dataList {
    if (nil == _dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (void)loadNavigationItem {
    self.navigationItem.title = @"下载";

    UIBarButtonItem *arrangeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"ellipsis"] style:UIBarButtonItemStyleDone target:self action:@selector(arrangeItemClickAction:)];
    self.navigationItem.rightBarButtonItem = arrangeItem;
}

- (void)loadMainView {
    [super loadMainView];

    self.canRefresh = YES;

    UILabel *infoLabel = [[UILabel alloc] init];
    infoLabel.numberOfLines = 0;
    [self.view addSubview:infoLabel];
    self.infoLabel = infoLabel;

    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(20, 20, 20, 20));
    }];
}

- (void)loadDataList {

    [self.dataList removeAllObjects];
    [self.dataList addObjectsFromArray:[PicContentTaskModel queryAll]];

    NSInteger count0 = [PicContentTaskModel queryCountForTaskStatus:0];
    NSInteger count1 = [PicContentTaskModel queryCountForTaskStatus:1];
    NSInteger count2 = [PicContentTaskModel queryCountForTaskStatus:2];
    NSInteger count3 = [PicContentTaskModel queryCountForTaskStatus:3];

    MJWeakSelf
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.infoLabel.text = [NSString stringWithFormat:@"当前未开始任务%ld条\n抓取中任务%ld条\n正在下载中任务%ld条\n已完成任务%ld条", count0, count1, count2, count3];
    });
}

- (void)arrangeItemClickAction:(UIBarButtonItem *)sender {

    [self loadDataList];
}

@end
