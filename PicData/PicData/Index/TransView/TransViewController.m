//
//  TransViewController.m
//  PicData
//
//  Created by CleverPeng on 2020/8/7.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "TransViewController.h"
#import "AddNetTaskVC.h"
#import "TransViewCell.h"

@interface TransViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *tasksMarray;

@property (nonatomic, strong) NSLock *lock;
@end

@implementation TransViewController

- (NSLock *)lock {
    if (nil == _lock) {
        _lock = [[NSLock alloc] init];
    }
    return _lock;
}

- (NSMutableArray *)tasksMarray {
    if (nil == _tasksMarray) {
        _tasksMarray = [NSMutableArray array];
    }
    return _tasksMarray;
}

- (void)viewDidLoad {
    [super viewDidLoad];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNoticeAboutAddNewTask:) name:NOTICECHEADDNEWTASK object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNoticeAboutAddNewDetailTask:) name:NOTICECHEADDNEWDETAILTASK object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNoticeAboutDownSuccessTask:) name:NOTICEPICDOWNLOADSUCCESS object:nil];
}

- (void)loadData {
    // 查询isAdded=1的模型
    [self.lock lock];
    NSArray *results = [PicContentModel queryTableWhere:[NSString stringWithFormat:@"where hasAdded = 1"]];
//    for (PicContentModel *contentModel in results) {
//        int count = [PicDownRecoreModel queryCountWhere:[NSString stringWithFormat:@"where contentUrl = \"%@\"", contentModel.href]];
//        contentModel.downloadedCount = count;
//    }
    [self.lock unlock];
    // [JKSqliteModelTool queryDataModel:[PicContentModel class] whereStr:[NSString stringWithFormat:@"hasAdded = 1"] uid:SQLite_USER];
    [self.tasksMarray addObjectsFromArray:results];

    [self.tableView reloadData];
}

- (void)loadNavigationItem {
    self.title = @"下载列表";
    // 下载
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTaskButtonClickAction:)];
    self.navigationItem.rightBarButtonItem = addItem;
}

- (void)loadMainView {
    [super loadMainView];

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];

    [tableView registerClass:[TransViewCell class] forCellReuseIdentifier:identifier];

    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tasksMarray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

static NSString *identifier = @"TransViewCell";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    TransViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.contentModel = self.tasksMarray[indexPath.section];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 108;
}

- (void)receiveNoticeAboutAddNewTask:(NSNotification *)notice {
    NSDictionary *userInfo = notice.userInfo;
    PicContentModel *contentModel = userInfo[@"contentModel"];
    NSLog(@"新增套图: %@, %@", contentModel.title, contentModel.href);

    [self.tasksMarray addObject:contentModel];

    [self.tableView insertSection:self.tasksMarray.count - 1 withRowAnimation:UITableViewRowAnimationBottom];
}

- (void)receiveNoticeAboutAddNewDetailTask:(NSNotification *)notice {
    NSDictionary *userInfo = notice.userInfo;
    PicContentModel *contentModel = userInfo[@"contentModel"];
    NSLog(@"新增套图:%@, 一共采集到:%d", contentModel.href, contentModel.totalCount);

    NSInteger count = self.tasksMarray.count;
    for (NSInteger index = 0; index < count; index ++) {
        PicContentModel *model = self.tasksMarray[index];
        if ([model.href isEqualToString:contentModel.href]) {
            TransViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
            [cell setTotalCount:contentModel.totalCount];
            break;
        }
    }
}

- (void)receiveNoticeAboutDownSuccessTask:(NSNotification *)notice {
    NSDictionary *userInfo = notice.userInfo;
    PicDownRecoreModel *recordModel = userInfo[@"recordModel"];
    NSLog(@"新增套图:%@, 下载: %@完成", recordModel.contentName, recordModel.title);

    NSInteger count = self.tasksMarray.count;
    for (NSInteger index = 0; index < count; index ++) {
        PicContentModel *model = self.tasksMarray[index];
        if ([model.href isEqualToString:recordModel.contentUrl]) {
            TransViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];

//            [self.lock lock];
//            NSArray *results = [PicContentModel queryTableWhere:[NSString stringWithFormat:@"where contentUrl = \"%@\"", recordModel.contentUrl]];
//            [self.lock unlock];
            // [JKSqliteModelTool queryDataModel:[PicDownRecoreModel class] whereStr:[NSString stringWithFormat:@"contentUrl = \"%@\"", recordModel.contentUrl] uid:SQLite_USER];
//            [cell setDownloadedCount:(int)results.count];
            break;
        }
    }
}

#pragma mark 创建网络下载任务
- (void)addTaskButtonClickAction:(UIBarButtonItem *)sender {
    AddNetTaskVC *addVC = [[AddNetTaskVC alloc] init];
    [self.navigationController pushViewController:addVC animated:YES];
}
@end
