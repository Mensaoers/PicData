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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    /// mac端拖拽之后, 界面重新适配
    self.collectionView.wholeWidth = self.view.mj_w;
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

    UIBarButtonItem *allDownItem = [[UIBarButtonItem alloc] initWithTitle:@"全部下载" style:UIBarButtonItemStyleDone target:self action:@selector(downloadAllContents:)];
    self.navigationItem.rightBarButtonItem = allDownItem;
}

- (void)loadContentData:(NSURL *)url isReload:(BOOL)isReload {

    NSLog(@"列表URL: %@", url.absoluteString);
    [MBProgressHUD showHUDAddedTo:self.view WithStatus:@"请稍等"];
    
    PDBlockSelf
    [PDRequest getWithURL:url isPhone:NO completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        PDBlockStrongSelf
        if (nil == error) {
            // 获取字符串
            NSString *resultString = [AppTool getStringWithGB_18030_2000Code:data];

            NSString *targetPath = [[[PDDownloadManager sharedPDDownloadManager] getDirPathWithSource:weakSelf.sourceModel contentModel:nil] stringByAppendingPathComponent:@"htmlContent.txt"];
            [data writeToFile:targetPath atomically:YES];

//            NSLog(@"获取%@数据成功:%@", self.typeModel.value, resultString);
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                if (isReload) {
                    [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"获取数据成功"];
                }
                // 解析数据
                NSString *urlsString = [weakSelf parserContent:url ListHtmlData:resultString isReload:isReload];

                NSString *itemUrlsPath = [[[PDDownloadManager sharedPDDownloadManager] getDirPathWithSource:weakSelf.sourceModel contentModel:nil] stringByAppendingPathComponent:@"urls.txt"];
                [[urlsString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:itemUrlsPath atomically:YES];
                [weakSelf.collectionView reloadData];
                [weakSelf.collectionView.mj_header endRefreshing];
                [weakSelf.collectionView.mj_footer endRefreshing];
            });
        } else {
            NSLog(@"获取%@数据错误:%@", strongSelf.sourceModel.url,  error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"获取数据失败"];
                [weakSelf parserContent:url ListHtmlData:@"" isReload:isReload];
                [weakSelf.collectionView reloadData];
                [weakSelf.collectionView.mj_header endRefreshing];
                [weakSelf.collectionView.mj_footer endRefreshing];
            });
        }
    }];
}

- (NSString *)parserContent:(NSURL *)url ListHtmlData:(NSString *)htmlString isReload:(BOOL)isReload {
    
    if (isReload) {
        [self.dataList removeAllObjects];
    }
    if (htmlString.length > 0) {
        
        OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];

        NSArray *results = [self parserContentListWithDocument:document];
        [self.dataList addObjectsFromArray:[results copy]];

        OCGumboElement *nextE = document.QueryClass(@"next-page").firstObject;
        if (nextE) {
            OCGumboElement *aE = nextE.QueryElement(@"a").firstObject;
            NSString *nextPage = aE.attr(@"href");
            self.nextPageURL = [NSURL URLWithString:[nextPage stringByAddingPercentEscapesUsingEncoding:[AppTool getNSStringEncoding_GB_18030_2000]] relativeToURL:url];
        } else {
            self.nextPageURL = nil;
        }
    }
    
    NSMutableString *urlsS = [NSMutableString string];
    NSURL *baseURL = [NSURL URLWithString:self.sourceModel.HOST_URL];
    for (PicContentModel *contentModel in self.dataList) {
        [urlsS appendFormat:@"\n%@", [NSURL URLWithString:contentModel.href relativeToURL:baseURL].absoluteString];
    }
    return urlsS;
}

- (NSArray *)parserContentListWithDocument:(OCGumboDocument *)document {

    OCQueryObject *articleEs = document.QueryElement(@"article");

    NSMutableArray *articleContents = [NSMutableArray array];
    for (OCGumboElement *articleE in articleEs) {

        OCGumboElement *headerE = articleE.QueryElement(@"header").firstObject;
        NSString *type = headerE.QueryElement(@"a").first().text();
        OCGumboElement *h2E = headerE.QueryElement(@"h2").firstObject;
        OCGumboElement *h2aE = h2E.QueryElement(@"a").firstObject;
        NSString *title = h2aE.text();
        NSString *href = h2aE.attr(@"href");
        NSString *thumbnailUrl = articleE.QueryClass(@"thumb-span").first().QueryElement(@"img").first().attr(@"src");

        PicContentModel *contentModel = [[PicContentModel alloc] init];
        contentModel.href = href;
        contentModel.sourceTitle = self.sourceModel.title;
        contentModel.HOST_URL = self.sourceModel.HOST_URL;
        contentModel.title = title;
        contentModel.thumbnailUrl = thumbnailUrl;
        [articleContents addObject:contentModel];
    }

    return [articleContents copy];
}

- (void)downloadAllContents:(UIBarButtonItem *)sender {
    for (PicContentModel *contentModel in self.dataList) {
        [ContentParserManager tryToAddTaskWithSourceModel:self.sourceModel ContentModel:contentModel operationTips:^(BOOL isSuccess, NSString * _Nonnull tips) {
            [MBProgressHUD showInfoOnView:self.view WithStatus:tips afterDelay:0.5];
        }];
    }
}

#pragma mark collectionView delegate

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

#pragma mark PicContentCellDelegate

- (void)contentCell:(PicContentCell *)contentCell downBtnClicked:(UIButton *)sender contentModel:(PicContentModel *)contentModel {
    [ContentParserManager tryToAddTaskWithSourceModel:self.sourceModel ContentModel:contentModel operationTips:^(BOOL isSuccess, NSString * _Nonnull tips) {
        [MBProgressHUD showInfoOnView:self.view WithStatus:tips afterDelay:1];
    }];
}

@end
