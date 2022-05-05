//
//  TasksViewController.m
//  PicData
//
//  Created by 鹏鹏 on 2022/3/10.
//  Copyright © 2022 garenge. All rights reserved.
//

#import "TasksViewController.h"
#import "PicProgressModel.h"
#import "TasksTCell.h"

@interface PicProgressHeaderLabel : UILabel

@property (nonatomic, assign) NSInteger index;

@end

@implementation PicProgressHeaderLabel

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
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receiveNoticeCompleteDownTask:) name:NotificationNameCompleteDownTask object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receiveNoticeCompleteScaneTask:) name:NotificationNameCompleteScaneTask object:nil];
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

    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 10;
    } else {
        // Fallback on earlier versions
    }

    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];

    PDBlockSelf
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadDataList];
    }];

    [tableView.mj_header beginRefreshing];
}

/** 刷新数据
 *  刷新时机:
 *  1. 回到本页面
 *  2. 下拉刷新
 *  3. 右侧导航按钮点击刷新
 *  4(5). 某套图状态变更, 1->2(扫描完成), 2->3(下载完成)
 */
- (void)loadDataList {

// TODO: 下载过程中, 发出通知, 下载了多少页, 可以在本页面显示下载进度(downloaded / totalCount)

    MJWeakSelf
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger count = self.progressModels.count;
        for (NSInteger index = 0; index < count; index ++) {
            PicProgressModel *model = [self.progressModels objectAtIndex:index];
            [model.taskModels removeAllObjects];
            [model.taskModels addObjectsFromArray:[PicContentTaskModel queryTasksForStatus:(int)index]];
        }

        [weakSelf.tableView reloadData];
        [weakSelf.tableView.mj_header endRefreshing];
    });
}

- (void)arrangeItemClickAction:(UIBarButtonItem *)sender {

    [self.tableView.mj_header beginRefreshing];
}

- (void)updateHeaderLabel:(PicProgressHeaderLabel *)contentLabel progressModel:(PicProgressModel *)progressModel {
    contentLabel.text = [NSString stringWithFormat:@"%@%@", progressModel.expand ? @"▼" : @"►", progressModel.description];
}

- (void)tapHeaderGestureAction:(UITapGestureRecognizer *)gesture {
    if ([gesture.view isKindOfClass:[PicProgressHeaderLabel class]]) {
        PicProgressHeaderLabel *contentLabel = (PicProgressHeaderLabel *)gesture.view;

        NSInteger section = contentLabel.index;
        PicProgressModel *progressModel = self.progressModels[section];

        progressModel.expand = !progressModel.expand;

        [self updateHeaderLabel:contentLabel progressModel:progressModel];

        if (progressModel.taskModels.count == 0) {
            return;
        }

        [self.tableView beginUpdates];
        [self.tableView reloadSection:section withRowAnimation:progressModel.expand ? UITableViewRowAnimationRight : UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
    }
}

#pragma mark - notification

- (void)receiveNoticeCompleteDownTask:(NSNotification *)notification {
    [self loadDataList];
}

- (void)receiveNoticeCompleteScaneTask:(NSNotification *)notification {
    [self loadDataList];
}

#pragma mark - delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.progressModels.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    PicProgressModel *progressModel = self.progressModels[section];
    if (progressModel.expand) {
        return progressModel.taskModels.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellIdentifier = @"TasksTCell";
    TasksTCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (nil == cell) {
        cell = [[TasksTCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    PicContentTaskModel *taskModel = self.progressModels[indexPath.section].taskModels[indexPath.row];

    cell.taskModel = taskModel;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

static CGFloat headerHeight = 35;
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return headerHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    ((UITableViewHeaderFooterView *)view).backgroundView.backgroundColor = [UIColor clearColor];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *headerIdentifier = @"HeaderFooterIdentifier";

    UITableViewHeaderFooterView *headerFooter = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
    if (nil == headerFooter) {
        headerFooter = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerIdentifier];
        headerFooter.contentView.backgroundColor = pdColor(205, 218, 223, 1);
    }

    PicProgressHeaderLabel *contentLabel = [headerFooter viewWithTag:9527];
    if (nil == contentLabel) {
        contentLabel = [[PicProgressHeaderLabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.mj_w, headerHeight)];
        contentLabel.font = [UIFont systemFontOfSize:15];
        contentLabel.textColor = [UIColor grayColor];
        contentLabel.userInteractionEnabled = YES;
        contentLabel.tag = 9527;
        [headerFooter.contentView addSubview:contentLabel];

        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeaderGestureAction:)];
        [contentLabel addGestureRecognizer:tapGesture];
    }
    contentLabel.index = section;

    PicProgressModel *progressModel = self.progressModels[section];

    [self updateHeaderLabel:contentLabel progressModel:progressModel];

    return headerFooter;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    PicContentTaskModel *taskModel = self.progressModels[indexPath.section].taskModels[indexPath.row];
    if (taskModel.status == 3) {
        // TODO: 点击跳转到本地预览
    }
}

@end
