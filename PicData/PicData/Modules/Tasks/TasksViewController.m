//
//  TasksViewController.m
//  PicData
//
//  Created by 鹏鹏 on 2022/3/10.
//  Copyright © 2022 garenge. All rights reserved.
//

#import "TasksViewController.h"

@interface PicProgressModel : NSObject

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSMutableArray <PicContentTaskModel *>*taskModels;

- (instancetype)initWithTitle:(NSString *)title;

+ (instancetype)ModelWithTitle:(NSString *)title;

@end

@implementation PicProgressModel

// TODO: 本地文件列表应该是对应任务列表 需要思考一下

- (NSMutableArray *)taskModels {
    if (nil == _taskModels) {
        _taskModels = [NSMutableArray array];
    }
    return _taskModels;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@%ld条", self.title, self.taskModels.count];
}

- (instancetype)initWithTitle:(NSString *)title {
    if (self = [super init]) {
        self.title = title;
        }
    return self;
}

+ (instancetype)ModelWithTitle:(NSString *)title {
    return [[PicProgressModel alloc] initWithTitle:title];
}

@end


@interface TasksViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic, assign) BOOL canRefresh;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray <PicProgressModel *>*progressModels;

@end

@implementation TasksViewController

- (NSMutableArray *)progressModels {
    if (nil == _progressModels) {
        _progressModels = [NSMutableArray arrayWithArray:@[
            [PicProgressModel ModelWithTitle:@"当前未开始任务"],
            [PicProgressModel ModelWithTitle:@"抓取中任务"],
            [PicProgressModel ModelWithTitle:@"正在下载中任务"],
            [PicProgressModel ModelWithTitle:@"已完成任务"],
        ]];
    }
    return _progressModels;
}

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

    [weakSelf loadDataList];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

//    [NSNotificationCenter.defaultCenter addObserver:[ContentParserManager sharedContentParserManager] selector:@selector(receiveNoticeCompleteATask:) name:NOTICECHECOMPLETEDOWNATASK object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

//    [NSNotificationCenter.defaultCenter removeObserver:self name:NOTICECHECOMPLETEDOWNATASK object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receiveNoticeCompleteATask:) name:NOTICECHECOMPLETEDOWNATASK object:nil];
}

- (void)loadNavigationItem {
    self.navigationItem.title = @"下载";

    UIBarButtonItem *arrangeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"arrow.clockwise"] style:UIBarButtonItemStyleDone target:self action:@selector(arrangeItemClickAction:)];
    self.navigationItem.rightBarButtonItem = arrangeItem;
}

- (void)loadMainView {
    [super loadMainView];

    self.canRefresh = YES;

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;

    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];

    PDBlockSelf
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadDataList];
    }];

    [tableView.mj_header beginRefreshing];
}

- (void)loadDataList {

    MJWeakSelf
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSInteger count = self.progressModels.count;
        for (NSInteger index = 0; index < count; index ++) {
            PicProgressModel *model = [self.progressModels objectAtIndex:index];
            [model.taskModels removeAllObjects];
            [model.taskModels addObjectsFromArray:[PicContentTaskModel queryTasksForStatus:(int)index]];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
            [weakSelf.tableView.mj_header endRefreshing];
        });
    });
}

- (void)arrangeItemClickAction:(UIBarButtonItem *)sender {

    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - notification
- (void)receiveNoticeCompleteATask:(NSNotification *)notification {
    [self loadDataList];
}

#pragma mark - delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.progressModels.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.progressModels[section].taskModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    // TODO: 任务列表UI美化, cell设计
    NSString *cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    PicContentTaskModel *taskModel = self.progressModels[indexPath.section].taskModels[indexPath.row];

    cell.textLabel.text = taskModel.title;

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.progressModels[section].description;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    PicContentTaskModel *taskModel = self.progressModels[indexPath.section].taskModels[indexPath.row];
    if (taskModel.status == 3) {
        // TODO: 点击跳转到本地预览
    }
}

@end
