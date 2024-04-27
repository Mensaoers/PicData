//
//  DetailViewController.m
//  PicData
//
//  Created by Garenge on 2020/4/20.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "DetailViewController.h"
#import "DetailViewModel.h"
#import "DetailViewContentCell.h"
#import "PicContentCell.h"
#import "LocalFileListVC.h"
#import "PicBrowserToolViewHandler.h"

@interface DetailViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, PicContentCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) DetailViewModel *detailModel;

@property (nonatomic, strong) NSMutableArray <NSDictionary *>*historyInfos;

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) NSMutableDictionary *heightDic;

@property (nonatomic, assign) CGFloat lastWidth;

@property (nonatomic, assign) BOOL headerExpanded;

@end

@implementation DetailViewController

#pragma mark - property

- (NSMutableDictionary *)heightDic {
    if (nil == _heightDic) {
        _heightDic = [NSMutableDictionary dictionary];
    }
    return _heightDic;
}

- (NSMutableArray<NSDictionary *> *)historyInfos {
    if (nil == _historyInfos) {
        _historyInfos = [NSMutableArray array];
    }
    return _historyInfos;
}

- (DetailViewModel *)detailModel {
    if (nil == _detailModel) {
        _detailModel = [[DetailViewModel alloc] init];
    }
    return _detailModel;
}

- (void)setContentModel:(PicContentModel *)contentModel {
    _contentModel = contentModel;
    self.detailModel.nextUrl = contentModel.href;
    self.detailModel.detailTitle = contentModel.title;
    self.detailModel.currentUrl = contentModel.href;
}

- (void)dealloc {
    [AppTool releaseSDWebImageManager:self.sourceModel.sourceType];
    [self willDealloc];
}

- (instancetype)init {
    if (self = [super init]) {
#if TARGET_OS_MACCATALYST
        self.headerExpanded = YES;
#else
        self.headerExpanded = NO;
#endif
    }
    return self;
}

#pragma mark - view

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)refreshRightNavigationItems {
    NSMutableArray *items = [NSMutableArray array];

    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"list.bullet"] style:UIBarButtonItemStyleDone target:self action:@selector(doMoreItemClickedAction:)];
    [items addObject:moreItem];

    NSArray *results = [PicContentTaskModel queryTableWithHref:self.contentModel.href];

    if (results.count == 0) {
        // 没有查到, 说明没有添加过
        UIBarButtonItem *downItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"square.and.arrow.down"] style:UIBarButtonItemStyleDone target:self action:@selector(doDownloadThisContent)];
        [items addObject:downItem];
    }

    if (self.detailModel.nextUrl.length > 0) {
        // 有下一页
        UIBarButtonItem *nextItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"arrow.right.square"] style:UIBarButtonItemStyleDone target:self action:@selector(loadNextDetailData)];
        [items addObject:nextItem];
    }

    self.navigationItem.rightBarButtonItems = items.copy;
}

- (void)loadNavigationItem {
    NSMutableArray *leftBarButtonItems = [NSMutableArray array];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(backAction:)];
    [leftBarButtonItems addObject:backItem];
    if (self.historyInfos.count > 0) {
        UIBarButtonItem *lastPageItem = [[UIBarButtonItem alloc] initWithTitle:@"上一页" style:UIBarButtonItemStyleDone target:self action:@selector(loadLastPageDetailData)];
        [leftBarButtonItems addObject:lastPageItem];
    }

#if TARGET_OS_MACCATALYST

    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"arrow.clockwise"] style:UIBarButtonItemStyleDone target:self action:@selector(refreshItemClickAction:)];
    [leftBarButtonItems addObject:refreshItem];

#endif

    self.navigationItem.leftBarButtonItems = leftBarButtonItems;

    [self refreshRightNavigationItems];
}

- (void)loadMainView {
    [super loadMainView];
    
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.textColor = UIColor.lightGrayColor;
    contentLabel.numberOfLines = 0;
    contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    contentLabel.text = self.contentModel.title;
    [self.view addSubview:contentLabel];
    self.contentLabel = contentLabel;
    
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8);
        make.right.mas_equalTo(-8);
        make.top.mas_equalTo(8);
    }];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];

    if (@available(iOS 15.0, *)) {
        tableView.sectionHeaderTopPadding = 0;
    } else {
        // Fallback on earlier versions
    }

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView = tableView;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentLabel.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottomMargin).with.offset(-10);
    }];
    
    tableView.tableFooterView = [UIView new];
    
    PDBlockSelf
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadDetailData];
    }];
}

- (void)refreshMainView {

    [self updateContentTitle:self.detailModel.detailTitle];
    [self refreshRightNavigationItems];
    [self.tableView reloadData];
    if (self.detailModel.contentImgsUrl.count > 0 && self.historyInfos.count > 0) {
        self.headerExpanded = NO;
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }
}

- (void)updateContentTitle:(NSString *)contentTitle {
    if (contentTitle.length > 0) {
        self.contentModel.title = contentTitle;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.contentLabel.text = contentTitle;
        });
    }
}

- (void)detailContentCell:(DetailViewContentCell *)contentCell refreshedAfterImgLoaded:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[DetailViewContentCell class]]) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if (self.view.mj_w == self.lastWidth) { return; }
    self.lastWidth = self.view.mj_w;

    // 方法重置, 在mac端拖动界面大小之后, 刷新tag列表, 重新布局
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resizeMainView) object:nil];
    [self performSelector:@selector(resizeMainView) afterDelay:0.5];

}

- (void)resizeMainView {

    NSIndexPath *indexPath = self.tableView.indexPathsForVisibleRows.firstObject;
    if (indexPath == nil) { return; }
    [self.heightDic removeAllObjects];
    [self.tableView reloadData];

}

#pragma mark - data

- (void)loadLastPageDetailData {
    NSDictionary *lastInfo = self.historyInfos.lastObject;
    if (nil != lastInfo) {
        [AppTool releaseSDWebImageManager:self.sourceModel.sourceType];
        self.detailModel.nextUrl = self.detailModel.currentUrl;
        self.detailModel.currentUrl = lastInfo[@"url"];
        self.detailModel.detailTitle = lastInfo[@"title"];
        [self loadDetailData];
        [self.historyInfos removeLastObject];

        NSArray *result = [PicContentModel queryTableWithHref:self.detailModel.currentUrl];
        if (result.count > 0) {
            self.contentModel = result[0];
        }
    }
    [self loadNavigationItem];
}

- (void)loadNextDetailData {
    [self.historyInfos addObject:@{@"url" : self.detailModel.currentUrl, @"title" : self.detailModel.detailTitle}];

    if (self.detailModel.nextUrl.length == 0) {
        [MBProgressHUD showInfoOnView:self.view WithStatus:@"到底了"];
        return;
    }
    [AppTool releaseSDWebImageManager:self.sourceModel.sourceType];
    self.detailModel.currentUrl = self.detailModel.nextUrl;
    [self loadDetailData];
    [self loadNavigationItem];
}

- (void)loadDetailData {
    [self.heightDic removeAllObjects];
    [MBProgressHUD showHUDAddedTo:self.view WithStatus:@"请稍等"];
    [self.tableView.mj_header endRefreshing];
    PDBlockSelf
    [PDRequest getWithURL:[NSURL URLWithString:self.detailModel.currentUrl relativeToURL:[NSURL URLWithString:self.sourceModel.HOST_URL]] isPhone:NO completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (nil == error) {
            // 获取字符串
            NSString *resultString = [ContentParserManager getHtmlStringWithData:data sourceType:weakSelf.sourceModel.sourceType];
            dispatch_async(dispatch_get_main_queue(), ^{

                // 解析数据
                [weakSelf parserDetailListHtmlDataType:resultString];
                [weakSelf refreshMainView];
                [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
            });
        } else {
            NSLog(@"获取%@数据错误:%@", weakSelf.sourceModel.url,  error);
            dispatch_async(dispatch_get_main_queue(), ^{

                if (nil == weakSelf) { return; }
                [weakSelf refreshMainView];
                [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"获取数据失败"];
            });
        }
    }];
}

- (void)parserDetailListHtmlDataType:(NSString *)htmlString {
    self.detailModel.suggesTitle = @"推荐列表";
    self.detailModel.nextUrl = self.detailModel.currentUrl;

    PDBlockSelf
    [ContentParserManager parseDetailWithHtmlString:htmlString href:self.contentModel.href sourceModel:self.sourceModel preNextUrl:self.detailModel.nextUrl needSuggest:YES completeHandler:^(NSArray<NSString *> * _Nonnull imageUrls, NSString * _Nonnull nextPage, NSArray<PicContentModel *> * _Nullable suggestArray, NSString * _Nullable contentTitle) {

        weakSelf.detailModel.contentImgsUrl = imageUrls;
        weakSelf.detailModel.nextUrl = nextPage;
        weakSelf.detailModel.suggesArray = suggestArray;

        if (contentTitle.length > 0 && weakSelf.detailModel.canUpdateTitle) {
            weakSelf.detailModel.detailTitle = contentTitle;
            weakSelf.detailModel.canUpdateTitle = NO;
            [weakSelf updateContentTitle:weakSelf.detailModel.detailTitle];
        }

    }];

}

#pragma mark - Action

- (void)headerViewTapGesAction:(UITapGestureRecognizer *)sender {
    self.headerExpanded = !self.headerExpanded;
    [self.tableView reloadSection:0 withRowAnimation:UITableViewRowAnimationTop];
}

- (void)refreshItemClickAction:(UIBarButtonItem *)sender {
    [self.tableView.mj_header beginRefreshing];
}

- (void)doMoreItemClickedAction:(UIBarButtonItem *)sender {

    __weak typeof(self) weakSelf = self;
    NSMutableArray *actions = [NSMutableArray array];
    [actions addObject:[UIAlertAction actionWithTitle:@"复制套图地址" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf shareThisContent_copy:weakSelf.view];
    }]];

    PicContentTaskModel *taskModel = [[PicContentTaskModel queryTableWithHref:self.contentModel.href] firstObject];
    if (taskModel) {
        [actions addObject:[UIAlertAction actionWithTitle:@"查看文件夹" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf shareThisContent_folder:taskModel];
        }]];
    }

    [actions addObject:[UIAlertAction actionWithTitle:@"下载该套图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf doDownloadThisContent];
    }]];

    [actions addObject:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [self showAlertWithTitle:@"操作" message:@"请选择你的操作" actions:actions];
}

- (void)backAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doDownloadThisContent {
    [ContentParserManager tryToAddTaskWithSourceModel:self.sourceModel ContentModel:self.contentModel operationTips:^(BOOL isSuccess, NSString * _Nonnull tips) {
        [MBProgressHUD showInfoOnView:self.view WithStatus:tips afterDelay:0.5];
        [self refreshRightNavigationItems];
    }];
}

- (void)downloadAllContents:(UIButton *)sender {
    for (PicContentModel *contentModel in self.detailModel.suggesArray) {
        [ContentParserManager tryToAddTaskWithSourceModel:self.sourceModel ContentModel:contentModel operationTips:^(BOOL isSuccess, NSString * _Nonnull tips) {
            [MBProgressHUD showInfoOnView:self.view WithStatus:tips afterDelay:0.5];
            [self refreshRightNavigationItems];
        }];
    }
}

- (void)shareThisContent_copy:(UIView *)sender {
    NSURL *baseURL = [NSURL URLWithString:self.sourceModel.HOST_URL];
    NSURL *url = [NSURL URLWithString:self.contentModel.href relativeToURL:baseURL];
    [AppTool shareFileWithURLs:@[url] sourceView:sender completionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        NSLog(@"调用分享的应用id :%@", activityType);
        if (completed) {
            NSLog(@"分享成功!");
        } else {
            NSLog(@"分享失败!");
        }
    }];
}

- (void)shareThisContent_folder:(PicContentTaskModel *)taskModel {
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

/// 查看单图, 由于图片都是自定义下载设置, 无法兼容预览库, 只能在下载完成一张之后, 再进行大图预览, 具体见AppTool的 + (SDWebImageManager *)sdWebImageManagerWithHeaderFields:(NSDictionary *)headerFields sourceType:(int)sourceType 方法
- (void)doViewBigPictureAtIndexPath:(nonnull NSIndexPath *)indexPath {

    DetailViewContentCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    if (nil == cell.conImgView.image) {
        return;
    }

    YBIBImageData *data = [YBIBImageData new];
    data.image = ^UIImage * _Nullable{
        return cell.conImgView.image;
    };
    data.projectiveView = cell.conImgView;

    YBImageBrowser *browser = [YBImageBrowser new];
    browser.dataSourceArray = @[data];
    browser.currentPage = 0;
    browser.supportedOrientations = UIInterfaceOrientationMaskPortrait;
    // 只有一个保存操作的时候，可以直接右上角显示保存按钮
    PicBrowserToolViewHandler *handler = PicBrowserToolViewHandler.new;
    browser.toolViewHandlers = @[handler];
    [browser show];
}

#pragma mark - delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.detailModel.suggesArray.count > 0) {
        return 2;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return self.detailModel.contentImgsUrl ? self.detailModel.contentImgsUrl.count : 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *tCell;

    switch (indexPath.section) {
        case 0: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"collect"];
            if (nil == cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"collect"];

                PicContentView *collectionView = [PicContentView collectionView:self.tableView.mj_w];
                collectionView.delegate = self;
                collectionView.dataSource = self;
                collectionView.scrollEnabled = NO;
                collectionView.tag = 9527;
                [cell.contentView addSubview:collectionView];

                [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
                }];
            }

            UICollectionView *collectionView = [cell.contentView viewWithTag:9527];
            [collectionView reloadData];

            tCell = cell;
        }
            break;
        case 1: {
            DetailViewContentCell *cell = (DetailViewContentCell *)[tableView dequeueReusableCellWithIdentifier:@"DetailViewContentCell"];
            if (nil == cell) {
                cell = [[DetailViewContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DetailViewContentCell"];
            }
            PDBlockSelf
            cell.updateCellHeightBlock = ^(NSIndexPath * _Nonnull indexPath_, CGFloat height, BOOL force) {
                NSString *key = [NSString stringWithFormat:@"%ld-%ld", (long)indexPath_.section, (long)indexPath_.row];
                if (weakSelf.heightDic[key] != nil && !force) { return; }

                [weakSelf.heightDic setValue:@(height) forKey: key];

                UITableViewCell  *existcell = [tableView cellForRowAtIndexPath:indexPath_];
                if (existcell) {
                    // assign image to cell here
                    @try {
                        [tableView reloadRowsAtIndexPaths:@[indexPath_] withRowAnimation:UITableViewRowAnimationNone];
                    } @catch (NSException *exception) {

                    } @finally {

                    }
                }
            };
            cell.indexpath = indexPath;
            cell.targetImageWidth = self.tableView.mj_w - 10;
            [cell setImageUrl:self.detailModel.contentImgsUrl[indexPath.row] refererUrl:[NSURL URLWithString:self.detailModel.currentUrl relativeToURL:[NSURL URLWithString:self.sourceModel.HOST_URL]].absoluteString sourceType:self.sourceModel.sourceType];
            
            tCell = cell;
        }
            break;
        default:
            tCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
            break;
    }

    return tCell;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (contextInfo != @"saveToAlbum") {
        return;
    }
    if (error) {
        [MBProgressHUD showInfoOnView:self.view WithStatus:@"保存失败"];
    } else {
        [MBProgressHUD showInfoOnView:self.view WithStatus:@"保存成功"];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self doViewBigPictureAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.headerExpanded && self.detailModel.suggesArray.count > 0) {

            NSInteger count = self.detailModel.suggesArray.count;
            CGSize size = [PicContentView contentViewSize:self.tableView.mj_w targetCount:count];
            return size.height + 20;
        } else {
            return CGFLOAT_MIN;
        }
    } else {
        NSNumber *height = [self.heightDic valueForKey:[NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row]];
        if (height && [height floatValue] > 0) {
            return [height floatValue];
        }
        // 默认高度200, 不然触发频繁请求, 会导致服务器卡死
        return 200;//UITableViewAutomaticDimension;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
//    return  section == 0 ? 40 : CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = pdColor(205, 218, 223, 1);
    CGRect frame = CGRectMake(0, 0, tableView.mj_w, 40);
    bgView.frame = frame;

    frame.origin.x = 8;
    frame.size.width -= 16;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textColor = pdColor(153, 153, 153, 1);
    [bgView addSubview:titleLabel];

    if (section == 0) {
        titleLabel.text = [NSString stringWithFormat:@"%@%@", self.headerExpanded ? @"点击收起" : @"点击展开", [self.detailModel.suggesTitle ?: @"" stringByAppendingString:self.headerExpanded ? @"▼" : @"►"]];
        if (titleLabel.text.length > 0) {
            // 添加一个全部下载按钮
            UIButton *downloadAllBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            downloadAllBtn.frame = CGRectMake(tableView.mj_w - 88, 0, 80, 40);
            [downloadAllBtn setTitle:@"全部下载" forState:UIControlStateNormal];
            [downloadAllBtn setTitleColor:ThemeColor forState:UIControlStateNormal];
            [downloadAllBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
            [downloadAllBtn addTarget:self action:@selector(downloadAllContents:) forControlEvents:UIControlEventTouchUpInside];
            [bgView addSubview:downloadAllBtn];
        }
    } else {
        titleLabel.text = @"图片";// self.detailModel.detailTitle ?: @"";
    }

    if (section == 0) {
        UITapGestureRecognizer *tapges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerViewTapGesAction:)];
        [bgView addGestureRecognizer:tapges];
    }

    return bgView;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 100;//((self.detailModel.suggesArray ? self.detailModel.suggesArray.count : 0) + 1) / 2.0 * ((self.view.mj_w - 30) / 2 * 360.0 / 250 + 50);
    } else {
        return 200;
    }
}

- (UIContextMenuConfiguration *)tableView:(UITableView *)tableView contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point {

    if (indexPath.section == 0) {
        return nil;
    }

    DetailViewContentCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if (nil == cell.conImgView.image) {
        [MBProgressHUD showInfoOnView:self.view WithStatus:@"不能操作空白图片"];
        return nil;
    }

    PDBlockSelf
    UIContextMenuConfiguration *configration = [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil actionProvider:^UIMenu * _Nullable(NSArray<UIMenuElement *> * _Nonnull suggestedActions) {

        NSMutableArray *actions = [NSMutableArray array];
        /// 右击
        /// 1. 查看大图
        /// 2. 直接分享
        /// 3. 保存到相册
        UIAction *viewBigPic = [UIAction actionWithTitle:@"查看大图" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {

            [weakSelf doViewBigPictureAtIndexPath:indexPath];
        }];
        [actions addObject:viewBigPic];

        // 删除

#if TARGET_OS_MACCATALYST

        UIAction *share = [UIAction actionWithTitle:@"复制图片" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            UIPasteboard.generalPasteboard.image = cell.conImgView.image;
            [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"图片已复制"];
        }];
        [actions addObject:share];
#else
        UIAction *share = [UIAction actionWithTitle:@"直接分享" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            [AppTool shareWithActivityItems:@[cell.conImgView.image] sourceView:cell.conImgView completionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
            }];
        }];
        [actions addObject:share];
#endif

        UIAction *viewContent = [UIAction actionWithTitle:@"保存到相册" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            [YBIBPhotoAlbumManager getPhotoAlbumAuthorizationSuccess:^{
                UIImageWriteToSavedPhotosAlbum(cell.conImgView.image, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), @"saveToAlbum");
            } failed:^{
                [weakSelf showAlertWithTitle:@"相册权限" message:@"获取相册权限失败, 请手动设置app权限" confirmTitle:@"去设置" confirmHandler:^(UIAlertAction * _Nonnull action) {
                    // 打开通知设置
                    NSLog(@"%@", UIApplicationOpenSettingsURLString);
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                    }];
                } cancelTitle:@"算了" cancelHandler:^(UIAlertAction * _Nonnull action) {

                }];
            }];
        }];
        [actions addObject:viewContent];

        NSMutableArray *contentActions = [NSMutableArray array];
        UIAction *copyContentHref = [UIAction actionWithTitle:@"复制套图地址" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            [weakSelf shareThisContent_copy:weakSelf.view];
        }];
        [contentActions addObject:copyContentHref];
        PicContentTaskModel *taskModel = [PicContentTaskModel queryTableWithHref:self.contentModel.href].firstObject;
        if (taskModel != nil) {
            UIAction *viewFolder = [UIAction actionWithTitle:@"查看文件夹" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
                [weakSelf shareThisContent_folder:taskModel];
            }];
            [contentActions addObject:viewFolder];
        }
        UIMenu *contentAction = [UIMenu menuWithTitle:@"你想对该套图做什么" children:contentActions];
        [actions addObject:contentAction];

        return [UIMenu menuWithTitle:@"你想对该图片做什么?" children:actions];
    }];
    return configration;
}

#pragma mark collection delegate / dataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.detailModel.suggesArray ? self.detailModel.suggesArray.count : 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PicContentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PicContentCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.delegate = self;
    cell.indexPath = indexPath;
    cell.contentModel = self.detailModel.suggesArray[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    PicContentModel *model = self.detailModel.suggesArray[indexPath.item];

    DetailViewController *detailVC = [[DetailViewController alloc] init];
    detailVC.sourceModel = self.sourceModel;
    detailVC.contentModel = model;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)contentCell:(PicContentCell *)contentCell downBtnClicked:(UIButton *)sender contentModel:(PicContentModel *)contentModel {
    [ContentParserManager tryToAddTaskWithSourceModel:self.sourceModel ContentModel:contentModel operationTips:^(BOOL isSuccess, NSString * _Nonnull tips) {
        [MBProgressHUD showInfoOnView:self.view WithStatus:tips afterDelay:0.5];
        [self refreshRightNavigationItems];
    }];
}

@end
