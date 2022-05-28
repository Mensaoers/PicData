//
//  ContentViewController.m
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "ContentViewController.h"
#import "PicContentCell.h"
#import "ContentParserManager.h"
#import "DetailViewController.h"

@interface ContentViewController () <UICollectionViewDelegate, UICollectionViewDataSource,PicContentCellDelegate>

@property (nonatomic, strong) PicContentView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, strong) NSURL *nextPageURL;

@end

@implementation ContentViewController

- (instancetype)initWithSourceModel:(PicSourceModel *)sourceModel {
    if (self = [super init]) {
        self.sourceModel = sourceModel;
    }
    return self;
}

- (NSMutableArray *)dataList {
    if (nil == _dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView.mj_header beginRefreshing];
}

- (void)loadMainView {
    [super loadMainView];
    
    PicContentView *collectionView = [PicContentView collectionView:self.view.mj_w];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [self.view addSubview:collectionView];
    
    self.collectionView = collectionView;
    
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    PDBlockSelf
    collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{

        [weakSelf loadContentData:[NSURL URLWithString:weakSelf.sourceModel.url] isReload:YES];
    }];

    collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{

        if (weakSelf.nextPageURL) {
            [weakSelf loadContentData:weakSelf.nextPageURL isReload:NO];
        } else {
            [weakSelf.collectionView.mj_footer endRefreshing];
        }
    }];
}

- (void)loadNavigationItem {
    self.navigationItem.title = self.sourceModel.title;

#if TARGET_OS_MACCATALYST

    NSMutableArray *leftBarButtonItems = [NSMutableArray array];
    if (self.navigationController.viewControllers.count >= 2) {
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(backAction:)];
        [leftBarButtonItems addObject:backItem];
    }

    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"arrow.clockwise"] style:UIBarButtonItemStyleDone target:self action:@selector(refreshItemClickAction:)];
    [leftBarButtonItems addObject:refreshItem];
    self.navigationItem.leftBarButtonItems = leftBarButtonItems;

#endif

    UIBarButtonItem *allDownItem = [[UIBarButtonItem alloc] initWithTitle:@"全部下载" style:UIBarButtonItemStyleDone target:self action:@selector(downloadAllContents:)];
    self.navigationItem.rightBarButtonItem = allDownItem;
}

#pragma mark - Data

- (void)loadContentData:(NSURL *)url isReload:(BOOL)isReload {

    NSLog(@"列表URL: %@", url.absoluteString);
    [MBProgressHUD showHUDAddedTo:self.view WithStatus:@"请稍等"];
    
    PDBlockSelf
    [PDRequest getWithURL:url isPhone:NO completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        PDBlockStrongSelf

        BOOL isSuccess = NO;

        if (nil == error) {
            // 获取字符串
            NSString *resultString = [ContentParserManager getHtmlStringWithData:data sourceType:weakSelf.sourceModel.sourceType];

            NSString *targetPath = [[[PDDownloadManager sharedPDDownloadManager] getDirPathWithSource:weakSelf.sourceModel contentModel:nil] stringByAppendingPathComponent:@"htmlContent.txt"];
            [data writeToFile:targetPath atomically:YES];

            [weakSelf parserContent:url ListHtmlData:resultString isReload:isReload];
            isSuccess = YES;

        } else {
            [weakSelf parserContent:url ListHtmlData:@"" isReload:isReload];
            NSLog(@"获取%@数据错误:%@", strongSelf.sourceModel.url, error);
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (nil == weakSelf) { return; }
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if (isSuccess) {
                if (isReload) {
                    [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"获取数据成功"];
                }
            } else {
                [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"获取数据失败"];
            }

            // 解析数据
            [weakSelf.collectionView reloadData];
            [weakSelf.collectionView.mj_header endRefreshing];
            [weakSelf.collectionView.mj_footer endRefreshing];
        });
    }];
}

- (void)parserContent:(NSURL *)url ListHtmlData:(NSString *)htmlString isReload:(BOOL)isReload {
    
    if (isReload) {
        [self.dataList removeAllObjects];
    }

    MJWeakSelf
    [ContentParserManager parseContentListWithHtmlString:htmlString sourceModel:self.sourceModel completeHandler:^(NSArray * _Nonnull contentList, NSURL * _Nullable nextPageURL) {
        [weakSelf.dataList addObjectsFromArray:contentList];
        weakSelf.nextPageURL = nextPageURL;
    }];
    
    NSMutableString *urlsS = [NSMutableString string];
    NSURL *baseURL = [NSURL URLWithString:self.sourceModel.HOST_URL];
    for (PicContentModel *contentModel in self.dataList) {
        [urlsS appendFormat:@"\n%@", [NSURL URLWithString:contentModel.href relativeToURL:baseURL].absoluteString];
    }

    NSString *itemUrlsPath = [[[PDDownloadManager sharedPDDownloadManager] getDirPathWithSource:self.sourceModel contentModel:nil] stringByAppendingPathComponent:@"urls.txt"];
    [[urlsS dataUsingEncoding:NSUTF8StringEncoding] writeToFile:itemUrlsPath atomically:YES];
}

#pragma mark - Action

- (void)backAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refreshItemClickAction:(UIBarButtonItem *)sender {
    [self.collectionView.mj_header beginRefreshing];
}

- (void)downloadAllContents:(UIBarButtonItem *)sender {
    for (PicContentModel *contentModel in self.dataList) {
        [ContentParserManager tryToAddTaskWithSourceModel:self.sourceModel ContentModel:contentModel operationTips:^(BOOL isSuccess, NSString * _Nonnull tips) {
            [MBProgressHUD showInfoOnView:self.view WithStatus:tips afterDelay:0.5];
        }];
    }
}

#pragma mark - collectionView delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PicContentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PicContentCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.delegate = self;
    cell.indexPath = indexPath;
    cell.contentModel = self.dataList[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    DetailViewController *detailVC = [[DetailViewController alloc] init];
    detailVC.sourceModel = self.sourceModel;
    detailVC.contentModel = self.dataList[indexPath.item];
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - PicContentCellDelegate

- (void)contentCell:(PicContentCell *)contentCell downBtnClicked:(UIButton *)sender contentModel:(PicContentModel *)contentModel {
    [ContentParserManager tryToAddTaskWithSourceModel:self.sourceModel ContentModel:contentModel operationTips:^(BOOL isSuccess, NSString * _Nonnull tips) {
        [MBProgressHUD showInfoOnView:self.view WithStatus:tips afterDelay:1];
    }];
}

@end
