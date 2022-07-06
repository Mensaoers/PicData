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
                        return _detailModel;;
}

- (void)setContentModel:(PicContentModel *)contentModel {
    _contentModel = contentModel;
    self.detailModel.nextUrl = contentModel.href;
    self.detailModel.detailTitle = contentModel.title;
    self.detailModel.currentUrl = contentModel.href;
}

#pragma mark - view

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView.mj_header beginRefreshing];
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

    NSMutableArray *items = [NSMutableArray array];

    UIBarButtonItem *downItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"square.and.arrow.down"] style:UIBarButtonItemStyleDone target:self action:@selector(downloadThisContent:)];
    [items addObject:downItem];

    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"square.and.arrow.up"] style:UIBarButtonItemStyleDone target:self action:@selector(shareThisContent:)];
    [items addObject:shareItem];

    self.navigationItem.rightBarButtonItems = items.copy;
}

- (void)loadMainView {
    [super loadMainView];
    
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.textColor = UIColor.lightGrayColor;
    contentLabel.numberOfLines = 0;
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

    [self.tableView reloadData];
    if (self.detailModel.contentImgsUrl.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }

    [self.tableView.mj_header endRefreshing];
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

#pragma mark - data

- (void)loadLastPageDetailData {
    NSDictionary *lastInfo = self.historyInfos.lastObject;
    if (nil != lastInfo) {
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
    if (self.detailModel.nextUrl.length == 0) {
        [MBProgressHUD showInfoOnView:self.view WithStatus:@"到底了"];
        return;
    }
    self.detailModel.currentUrl = self.detailModel.nextUrl;
    [self loadDetailData];
    [self loadNavigationItem];
}

- (void)loadDetailData {
    [MBProgressHUD showHUDAddedTo:self.view WithStatus:@"请稍等"];
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

                [weakSelf refreshMainView];
                [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"获取数据失败"];
            });
        }
    }];
}

- (void)parserDetailListHtmlDataType:(NSString *)htmlString {
    self.detailModel.suggesTitle = @"推荐";
    self.detailModel.nextUrl = self.detailModel.currentUrl;

    PDBlockSelf
    [ContentParserManager parseDetailWithHtmlString:htmlString sourceModel:self.sourceModel preNextUrl:self.detailModel.nextUrl needSuggest:YES completeHandler:^(NSArray<NSString *> * _Nonnull imageUrls, NSString * _Nonnull nextPage, NSArray<PicContentModel *> * _Nullable suggestArray, NSString * _Nullable contentTitle) {

        weakSelf.detailModel.contentImgsUrl = imageUrls;
        weakSelf.detailModel.nextUrl = nextPage;
        weakSelf.detailModel.suggesArray = suggestArray;

        if (contentTitle.length > 0) {
            weakSelf.detailModel.detailTitle = contentTitle;
            [weakSelf updateContentTitle:weakSelf.detailModel.detailTitle];
        }

    }];

}

#pragma mark - Action

- (void)refreshItemClickAction:(UIBarButtonItem *)sender {
    [self.tableView.mj_header beginRefreshing];
}

- (void)backAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)downloadThisContent:(UIBarButtonItem *)sender {
    [ContentParserManager tryToAddTaskWithSourceModel:self.sourceModel ContentModel:self.contentModel operationTips:^(BOOL isSuccess, NSString * _Nonnull tips) {
        [MBProgressHUD showInfoOnView:self.view WithStatus:tips afterDelay:0.5];
    }];
}

- (void)downloadAllContents:(UIButton *)sender {
    for (PicContentModel *contentModel in self.detailModel.suggesArray) {
        [ContentParserManager tryToAddTaskWithSourceModel:self.sourceModel ContentModel:contentModel operationTips:^(BOOL isSuccess, NSString * _Nonnull tips) {
            [MBProgressHUD showInfoOnView:self.view WithStatus:tips afterDelay:0.5];
        }];
    }
}

- (void)shareThisContent:(UIButton *)sender {
    PDBlockSelf
    NSMutableArray *actions = [NSMutableArray array];
    [actions addObject:[UIAlertAction actionWithTitle:@"复制地址" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *baseURL = [NSURL URLWithString:weakSelf.sourceModel.HOST_URL];
        NSURL *url = [NSURL URLWithString:weakSelf.contentModel.href relativeToURL:baseURL];
        [AppTool shareFileWithURLs:@[url] sourceView:sender completionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
            NSLog(@"调用分享的应用id :%@", activityType);
            if (completed) {
                NSLog(@"分享成功!");
            } else {
                NSLog(@"分享失败!");
            }
        }];
    }]];

    PicContentTaskModel *taskModel = [[PicContentTaskModel queryTableWithHref:self.contentModel.href] firstObject];
    if (taskModel) {
        [actions addObject:[UIAlertAction actionWithTitle:@"查看文件夹" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            // 点击跳转到本地预览
            PicSourceModel *sourceModel = [PicSourceModel queryTableWithUrl:taskModel.sourceHref].firstObject;
            if (nil == sourceModel) {
                [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"未找到套图分类, 请到文件列表手动查看"];
                return;
            }

            LocalFileListVC *fileListVC = [[LocalFileListVC alloc] init];
            fileListVC.targetFilePath = [[PDDownloadManager sharedPDDownloadManager] getDirPathWithSource:sourceModel contentModel:taskModel];
            [weakSelf.navigationController pushViewController:fileListVC animated:YES];
        }]];
    }

    [actions addObject:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];

    [self showAlertWithTitle:nil message:@"分享" actions:actions];

}

#pragma mark - delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.detailModel.suggesArray.count > 0) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.detailModel.contentImgsUrl ? self.detailModel.contentImgsUrl.count : 0;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *tCell;

    switch (indexPath.section) {
        case 0: {
            DetailViewContentCell *cell = (DetailViewContentCell *)[tableView dequeueReusableCellWithIdentifier:@"DetailViewContentCell"];
            if (nil == cell) {
                cell = [[DetailViewContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DetailViewContentCell"];
            }

            cell.indexpath = indexPath;
            cell.url = self.detailModel.contentImgsUrl[indexPath.row];
            PDBlockSelf
            cell.updateCellHeightBlock = ^(NSIndexPath * _Nonnull indexPath_, CGFloat height) {
                [weakSelf.heightDic setValue:@(height) forKey:[NSString stringWithFormat:@"%ld-%ld", (long)indexPath_.section, (long)indexPath_.row]];
                dispatch_async( dispatch_get_main_queue(), ^{
                    UITableViewCell  *existcell = [tableView cellForRowAtIndexPath:indexPath_];
                    if (existcell) {
                        // assign image to cell here
                        @try {
                            [tableView reloadRowsAtIndexPaths:@[indexPath_] withRowAnimation:UITableViewRowAnimationNone];
                        } @catch (NSException *exception) {

                        } @finally {

                        }
                    }
                });
            };
            cell.longPressBlock = ^(DetailViewContentCell * _Nonnull cell) {

                NSLog(@"==== long press action");
                if (nil == cell.conImgView.image) {
                    [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"不能操作空白图片"];
                    return;
                }

                NSMutableArray *actions = [NSMutableArray array];
                [actions addObject:[UIAlertAction actionWithTitle:@"查看大图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

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
                }]];
                [actions addObject:[UIAlertAction actionWithTitle:@"直接分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [AppTool shareWithActivityItems:@[cell.conImgView.image] sourceView:cell.conImgView completionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {

                    }];
                }]];
                [actions addObject:[UIAlertAction actionWithTitle:@"保存到相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [YBIBPhotoAlbumManager getPhotoAlbumAuthorizationSuccess:^{
                        UIImageWriteToSavedPhotosAlbum(cell.conImgView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), @"saveToAlbum");
                    } failed:^{
                        [weakSelf showAlertWithTitle:@"相册权限" message:@"获取相册权限失败, 请手动设置app权限" confirmTitle:@"去设置" confirmHandler:^(UIAlertAction * _Nonnull action) {
                            // 打开通知设置
                            NSLog(@"%@", UIApplicationOpenSettingsURLString);
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                            }];
                        } cancelTitle:@"算了" cancelHandler:^(UIAlertAction * _Nonnull action) {

                        }];
                    }];
                }]];
                [actions addObject:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

                }]];

                [weakSelf showAlertWithTitle:nil message:@"你想对该图片做什么?" actions:actions];
            };
            tCell = cell;
        }
            break;
        case 1: {
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
    if (indexPath.section == 0) {
        [self.historyInfos addObject:@{@"url" : self.detailModel.currentUrl, @"title" : self.detailModel.detailTitle}];
        [self loadNextDetailData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSNumber *height = [self.heightDic valueForKey:[NSString stringWithFormat:@"%ld-%ld", (long)indexPath.section, (long)indexPath.row]];
        if (height && [height floatValue] > 0) {
            return [height floatValue];
        }
        // 默认高度200, 不然触发频繁请求, 会导致服务器卡死
        return 200;//UITableViewAutomaticDimension;
    } else {
        if (self.detailModel.suggesArray.count > 0) {
            NSInteger count = self.detailModel.suggesArray.count;
            CGFloat width = self.tableView.mj_w;
            CGFloat height = ceil((count) / (self.view.mj_w / [PicContentView itemWidth:width])) * ([PicContentView itemHeight:width] + 10);
            return height;
        } else {
            return 0;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return  section == 0 ? CGFLOAT_MIN : 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = UIColor.whiteColor;
    CGRect frame = CGRectMake(0, 0, tableView.mj_w, 40);
    bgView.frame = frame;

    frame.origin.x = 8;
    frame.size.width -= 16;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textColor = pdColor(153, 153, 153, 1);
    [bgView addSubview:titleLabel];

    if (section == 0) {
        titleLabel.text = @"图片";// self.detailModel.detailTitle ?: @"";
    } else {
        titleLabel.text = self.detailModel.suggesTitle ?: @"";
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
    }

    return bgView;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 200;
    } else {
        return 100;//((self.detailModel.suggesArray ? self.detailModel.suggesArray.count : 0) + 1) / 2.0 * ((self.view.mj_w - 30) / 2 * 360.0 / 250 + 50);
    }
}

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
    }];
}

@end
