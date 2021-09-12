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
        [weakSelf loadContentData];
    }];
}

- (void)loadNavigationItem {
    self.navigationItem.title = self.sourceModel.title;

    UIBarButtonItem *allDownItem = [[UIBarButtonItem alloc] initWithTitle:@"全部下载" style:UIBarButtonItemStyleDone target:self action:@selector(downloadAllContents:)];
    self.navigationItem.rightBarButtonItem = allDownItem;
}

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

- (void)loadContentData {

    if (self.loadDataBlock) {

        [self.dataList removeAllObjects];
        [self.dataList addObjectsFromArray:self.loadDataBlock()];
        [self.collectionView reloadData];
        [self.collectionView.mj_header endRefreshing];
        return;
    }

    [MBProgressHUD showHUDAddedTo:self.view WithStatus:@"请稍等"];
    
    PDBlockSelf
    [PDRequest getWithURL:[NSURL URLWithString:self.sourceModel.url] isPhone:self.sourceModel.sourceType != 3 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        PDBlockStrongSelf
        if (nil == error) {
            // 获取字符串
            NSString *resultString;
            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            resultString = [[NSString alloc] initWithData:data encoding:enc];

            NSString *targetPath = [[[PDDownloadManager sharedPDDownloadManager] getDirPathWithSource:weakSelf.sourceModel contentModel:nil] stringByAppendingPathComponent:@"htmlContent.txt"];
            [data writeToFile:targetPath atomically:YES];

//            NSLog(@"获取%@数据成功:%@", self.typeModel.value, resultString);
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"获取数据成功"];
                // 解析数据
                NSString *urlsString = [weakSelf parserContentListHtmlData:resultString];
                
                
                NSString *itemUrlsPath = [[[PDDownloadManager sharedPDDownloadManager] getDirPathWithSource:weakSelf.sourceModel contentModel:nil] stringByAppendingPathComponent:@"urls.txt"];
                [[urlsString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:itemUrlsPath atomically:YES];
                [weakSelf.collectionView reloadData];
                [weakSelf.collectionView.mj_header endRefreshing];
            });
        } else {
            NSLog(@"获取%@数据错误:%@", strongSelf.sourceModel.url,  error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"获取数据失败"];
                [weakSelf parserContentListHtmlData:@""];
                [weakSelf.collectionView reloadData];
                [weakSelf.collectionView.mj_header endRefreshing];
            });
        }
    }];
}

- (NSString *)parserContentListHtmlData:(NSString *)htmlString {
    
    [self.dataList removeAllObjects];
    if (htmlString.length > 0) {
        
        OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];

        NSArray *results = [self parserContentListWithType:document];
        [self.dataList addObjectsFromArray:[results copy]];
    }
    
    NSMutableString *urlsS = [NSMutableString string];
    NSURL *baseURL = [NSURL URLWithString:self.sourceModel.HOST_URL];
    for (PicContentModel *contentModel in self.dataList) {
        [urlsS appendFormat:@"\n%@", [NSURL URLWithString:contentModel.href relativeToURL:baseURL].absoluteString];
    }
    return urlsS;
}

- (NSArray *)parserContentListWithType:(OCGumboDocument *)document {
//    OCQueryObject *itemResults = document.Query(@".ulPic");
//    if (itemResults.count == 0) {
//        return @[];
//    }
//    OCGumboElement *divElement = itemResults.firstObject;
//    NSMutableArray *contentModels = [NSMutableArray array];
//    for (OCGumboElement *element in divElement.childNodes) {
//        OCQueryObject *aEs = element.Query(@"a");
//        if (aEs.count == 0) {
//            continue;
//        }
//
//        PicContentModel *contentModel = [[PicContentModel alloc] init];
//        contentModel.HOST_URL = self.sourceModel.HOST_URL;
//        contentModel.sourceTitle = self.sourceModel.title;
//        OCGumboElement *aE = aEs.firstObject;
//        NSString *url = aE.attr(@"href");
//        if (url.length > 0) {
//            // url
//            contentModel.href = url;
//        }
//
//        OCQueryObject *imgEs = aE.Query(@"img");
//        if (imgEs.count == 0) {
//            continue;
//        }
//        OCGumboElement *imgE = imgEs.firstObject;
//        NSString *imgSrc = imgE.attr(@"src");
//        if (imgSrc.length > 0) {
//            // imgSrc
//            contentModel.thumbnailUrl = imgSrc;
//        }
//
//        NSString *alt = imgE.attr(@"alt");
//        if (alt.length > 0) {
//            // alt
//            contentModel.title = alt;
//        }
//
//        [contentModel insertTable];
//        [contentModels addObject:contentModel];
//    }
//
//    return [contentModels copy];

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

#pragma mark PicContentCellDelegate

- (void)contentCell:(PicContentCell *)contentCell downBtnClicked:(UIButton *)sender contentModel:(PicContentModel *)contentModel {
    [ContentParserManager tryToAddTaskWithSourceModel:self.sourceModel ContentModel:contentModel operationTips:^(BOOL isSuccess, NSString * _Nonnull tips) {
        [MBProgressHUD showInfoOnView:self.view WithStatus:tips afterDelay:1];
    }];
}

@end
