//
//  TasksViewController.m
//  PicData
//
//  Created by 鹏鹏 on 2022/3/10.
//  Copyright © 2022 garenge. All rights reserved.
//

#import "TasksViewController.h"
#import "TasksContentView.h"
#import "PicProgressModel.h"
#import "TasksCollectionCell.h"
#import "LocalFileListVC.h"

@interface PicProgressHeaderLabel : UILabel

@property (nonatomic, assign) NSInteger index;

@end

@implementation PicProgressHeaderLabel

@end

@interface TasksViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic, strong) TasksContentView *collectionView;

@property (nonatomic, strong) NSMutableArray <PicProgressModel *>*progressModels;

@end

@implementation TasksViewController

static NSString *cellIdentifier = @"cellIdentifier";
static NSString *headerdentifier = @"headerdentifier";

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

    [self reCallLoadDataList:1];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receiveNoticeStartScaneTask:) name:NotificationNameStartScaneTask object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receiveNoticeCompleteScaneTask:) name:NotificationNameCompleteScaneTask object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receiveNoticeCompleteDownTask:) name:NotificationNameCompleteDownTask object:nil];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receiveNoticeCompleteDownPicture:) name:NotificationNameCompleteDownPicture object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receiveNoticeFailedDownPicture:) name:NotificationNameFailedDownPicture object:nil];
}

- (void)loadNavigationItem {
    self.navigationItem.title = @"下载";

    UIBarButtonItem *arrangeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"arrow.clockwise"] style:UIBarButtonItemStyleDone target:self action:@selector(arrangeItemClickAction:)];
    self.navigationItem.rightBarButtonItem = arrangeItem;
}

- (void)loadMainView {
    [super loadMainView];

    TasksContentView *collectionView = [TasksContentView collectionView:self.view.mj_w];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[TasksCollectionCell class] forCellWithReuseIdentifier:cellIdentifier];
    [collectionView registerClass:[CollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerdentifier];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;

    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];

    PDBlockSelf
    collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf reCallLoadDataList:0.1];
    }];

    [collectionView.mj_header beginRefreshing];
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

        [weakSelf.collectionView reloadData];
        [weakSelf.collectionView.mj_header endRefreshing];
    });
}

- (void)reCallLoadDataList:(NSInteger)afterDelay {
    // 子线程中延迟操作往往不起作用, 无效(在子线程中,默认是没有定时器的)
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadDataList) object:nil];
        [self performSelector:@selector(loadDataList) afterDelay:afterDelay];
    });
}

- (void)arrangeItemClickAction:(UIBarButtonItem *)sender {

    [self.collectionView.mj_header beginRefreshing];
}

- (void)updateHeaderLabel:(PicProgressHeaderLabel *)contentLabel progressModel:(PicProgressModel *)progressModel {
    contentLabel.text = [NSString stringWithFormat:@"  %@%@", progressModel.expand ? @"▼" : @"►", progressModel.description];
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

        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:section]];
    }
}

- (void)viewContentWithTaskModel:(PicContentTaskModel *)taskModel {
    // 点击跳转到本地预览
    PicSourceModel *sourceModel = [PicSourceModel queryTableWithUrl:taskModel.sourceHref].firstObject;
    if (nil == sourceModel) {
        [MBProgressHUD showInfoOnView:self.view WithStatus:@"未找到套图分类, 请到文件列表手动查看"];
        return;
    }

    LocalFileListVC *fileListVC = [[LocalFileListVC alloc] init];
    fileListVC.targetFilePath = [[PDDownloadManager sharedPDDownloadManager] getDirPathWithSource:sourceModel contentModel:taskModel];
    [self.navigationController pushViewController:fileListVC animated:YES];
}

#pragma mark - notification

- (void)receiveNoticeStartScaneTask:(NSNotification *)notification {
    [self reCallLoadDataList:1];
}

- (void)receiveNoticeCompleteDownTask:(NSNotification *)notification {
    [self reCallLoadDataList:1];
}

- (void)receiveNoticeCompleteScaneTask:(NSNotification *)notification {
    [self reCallLoadDataList:1];
}

- (void)receiveNoticeCompleteDownPicture:(NSNotification *)notification {
    PicContentTaskModel *taskModel = notification.userInfo[@"contentModel"];

    PicProgressModel *progressModel = [self.progressModels objectOrNilAtIndex:taskModel.status];
    if (progressModel) {
        NSInteger count = progressModel.taskModels.count;

        // 根据任务找到对应的cell, 刷新进度
        for (NSInteger index = 0; index < count; index ++) {
            PicContentTaskModel *taskModelT = progressModel.taskModels[index];
            if ([taskModelT.href isEqualToString:taskModel.href]) {

                dispatch_async(dispatch_get_main_queue(), ^{
                    TasksCollectionCell *cell = (TasksCollectionCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:taskModel.status]];
                    [cell updateProgress:taskModel];
                    taskModelT.downloadedCount = taskModel.downloadedCount;
                });
                break;
            }
        }
    }
}

- (void)receiveNoticeFailedDownPicture:(NSNotification *)notification {

}

#pragma mark - delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.progressModels.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    PicProgressModel *progressModel = self.progressModels[section];
    if (progressModel.expand) {
        return progressModel.taskModels.count;
    } else {
        return 0;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TasksCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    PicContentTaskModel *taskModel = self.progressModels[indexPath.section].taskModels[indexPath.row];
    cell.taskModel = taskModel;

    return cell;
}

static CGFloat headerHeight = 35;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(self.collectionView.mj_w, headerHeight);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        CollectionHeaderView *headerView = (CollectionHeaderView *)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerdentifier forIndexPath:indexPath];

        PicProgressHeaderLabel *contentLabel = [headerView viewWithTag:9527];
        if (nil == contentLabel) {
            contentLabel = [[PicProgressHeaderLabel alloc] initWithFrame:CGRectMake(0, 0, self.collectionView.mj_w, headerHeight)];
            contentLabel.font = [UIFont systemFontOfSize:15];
            contentLabel.textColor = [UIColor grayColor];
            contentLabel.backgroundColor = pdColor(205, 218, 223, 1);
            contentLabel.userInteractionEnabled = YES;
            contentLabel.tag = 9527;
            [headerView addSubview:contentLabel];

            [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(UIEdgeInsetsZero);
            }];

            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeaderGestureAction:)];
            [contentLabel addGestureRecognizer:tapGesture];
        }
        contentLabel.index = indexPath.section;

        PicProgressModel *progressModel = self.progressModels[indexPath.section];

        [self updateHeaderLabel:contentLabel progressModel:progressModel];

        return headerView;
    }
    return  nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    PicContentTaskModel *taskModel = self.progressModels[indexPath.section].taskModels[indexPath.row];
    [self viewContentWithTaskModel:taskModel];

}

- (nullable UIContextMenuConfiguration *)collectionView:(UICollectionView *)collectionView contextMenuConfigurationForItemAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point API_AVAILABLE(ios(13.0)) API_UNAVAILABLE(watchos, tvos) {

    PicContentTaskModel *taskModel = self.progressModels[indexPath.section].taskModels[indexPath.row];

    PDBlockSelf
    UIContextMenuConfiguration *configration = [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil actionProvider:^UIMenu * _Nullable(NSArray<UIMenuElement *> * _Nonnull suggestedActions) {

        NSMutableArray *actions = [NSMutableArray array];
        /// 右击
        /// 1. 取消/删除 下载
        /// 2. 查看套图
        if (taskModel.status != ContentTaskStatusFinishDownload) {
            // 取消
            UIAction *cancelDownload = [UIAction actionWithTitle:@"重新下载" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {

                [ContentParserManager.sharedContentParserManager cancelDownloadsByIdentifiers:@[taskModel.href]];
                taskModel.status = ContentTaskStatusNormal;
                taskModel.totalCount = 0;
                taskModel.downloadedCount = 0;
                [taskModel updateTable];
                [weakSelf reCallLoadDataList:0.5];
                [ContentParserManager prepareToDoNextTask];
            }];
            [actions addObject:cancelDownload];
        }

        // 删除
        UIAction *deleteDownload = [UIAction actionWithTitle:@"删除任务" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {

            [ContentParserManager.sharedContentParserManager cancelDownloadsByIdentifiers:@[taskModel.href]];
            [PicContentTaskModel deleteFromTableWithHref:taskModel.href];
            [weakSelf reCallLoadDataList:0.5];

            [weakSelf showAlertWithTitle:nil message:@"下载记录已删除, 是否需要删除本地文件?" confirmTitle:@"删除" confirmHandler:^(UIAlertAction * _Nonnull action) {

                PicSourceModel *sourceModel = [PicSourceModel queryTableWithUrl:taskModel.sourceHref].firstObject;
                if (nil == sourceModel) {
                    [MBProgressHUD showInfoOnView:self.view WithStatus:@"未找到套图分类, 请到文件列表手动删除"];
                    return;
                }

                NSString *targetFilePath = [[PDDownloadManager sharedPDDownloadManager] getDirPathWithSource:sourceModel contentModel:taskModel];
                NSError *rmError = nil;
                [[NSFileManager defaultManager] removeItemAtPath:targetFilePath error:&rmError];
                if (rmError) {
                    NSLog(@"TasksViewController: deleteContentFile: %@, error: %@", targetFilePath, rmError);
                }
            } cancelTitle:@"取消" cancelHandler:^(UIAlertAction * _Nonnull action) {

            }];
        }];
        [actions addObject:deleteDownload];

        UIAction *viewContent = [UIAction actionWithTitle:@"查看套图" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            [weakSelf viewContentWithTaskModel:taskModel];
        }];
        [actions addObject:viewContent];
        return [UIMenu menuWithTitle:@"下载记录右击菜单" children:actions];
    }];
    return configration;
}

@end
