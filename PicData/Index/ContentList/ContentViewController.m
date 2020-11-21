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
    self.navigationItem.title = self.sourceModel.title;
    [self.collectionView.mj_header beginRefreshing];
}


- (void)loadMainView {
    [super loadMainView];
    
    PicContentView *collectionView = [PicContentView collectionView];
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
    [MBProgressHUD showHUDAddedTo:self.view WithStatus:@"请稍等"];
    
    PDBlockSelf
    [PDRequest getWithURL:[NSURL URLWithString:self.sourceModel.url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (nil == error) {
            // 获取字符串
            NSString *resultString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
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
            NSLog(@"获取%@数据错误:%@", weakSelf.sourceModel.url,  error);
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
//        OCGumboElement *root = document.rootElement;

        if (self.sourceModel.sourceType == 1) {
            NSArray *results = [self parserContentListWithType1:document];
            [self.dataList addObjectsFromArray:[results copy]];
        } else if (self.sourceModel.sourceType == 2) {
            NSArray *results = [self parserContentListWithType2:document];
            [self.dataList addObjectsFromArray:[results copy]];
        } else if (self.sourceModel.sourceType == 3) {
            NSArray *results = [self parserContentListWithType3:document];
            [self.dataList addObjectsFromArray:[results copy]];
        }
    }
    
    NSMutableString *urlsS = [NSMutableString string];
    NSURL *baseURL = [NSURL URLWithString:self.sourceModel.HOST_URL];
    for (PicContentModel *contentModel in self.dataList) {
        [urlsS appendFormat:@"\n%@", [NSURL URLWithString:contentModel.href relativeToURL:baseURL].absoluteString];
    }
    return urlsS;
}

- (NSArray *)parserContentListWithType1:(OCGumboDocument *)document {
    OCQueryObject *itemResults = document.Query(@".zt-l-rows-l");
    if (itemResults.count == 0) {
        return @[];
    }
    OCGumboElement *divElement = itemResults.firstObject;
    NSMutableArray *contentModels = [NSMutableArray array];
    for (OCGumboElement *element in divElement.childNodes) {
        OCQueryObject *aEs = element.Query(@"a");
        if (aEs.count == 0) {
            continue;
        }

        PicContentModel *contentModel = [[PicContentModel alloc] init];
        contentModel.HOST_URL = self.sourceModel.HOST_URL;
        contentModel.sourceTitle = self.sourceModel.title;
        OCGumboElement *aE = aEs.firstObject;
        NSString *url = aE.attr(@"href");
        if (url.length > 0) {
            // url
            contentModel.href = url;
        }

        OCQueryObject *imgEs = aE.Query(@"img");
        if (imgEs.count == 0) {
            continue;
        }
        OCGumboElement *imgE = imgEs.firstObject;
        NSString *imgSrc = imgE.attr(@"data-original");
        if (imgSrc.length > 0) {
            // imgSrc
            contentModel.thumbnailUrl = imgSrc;
        }

        NSString *alt = imgE.attr(@"alt");
        if (alt.length > 0) {
            // alt
            contentModel.title = alt;
        }

        [contentModel insertTable];
//        [JKSqliteModelTool saveOrUpdateModel:contentModel uid:SQLite_USER];
        [contentModels addObject:contentModel];
    }

    return [contentModels copy];
}

- (NSArray *)parserContentListWithType2:(OCGumboDocument *)document {
    OCQueryObject *itemResults = document.Query(@".container");
    if (itemResults.count == 0) {
        return @[];
    }
    OCGumboElement *divElement = itemResults.firstObject;
    NSMutableArray *contentModels = [NSMutableArray array];
    for (OCGumboElement *element in divElement.childNodes) {
        OCQueryObject *aEs = element.Query(@"a");
        if (aEs.count == 0) {
            continue;
        }

        PicContentModel *contentModel = [[PicContentModel alloc] init];
        contentModel.HOST_URL = self.sourceModel.HOST_URL;
        contentModel.sourceTitle = self.sourceModel.title;
        OCGumboElement *aE = aEs.firstObject;
        NSString *url = aE.attr(@"href");
        if (url.length > 0) {
            // url
            contentModel.href = url;
        }

        OCQueryObject *imgEs = aE.Query(@"img");
        if (imgEs.count == 0) {
            continue;
        }
        OCGumboElement *imgE = imgEs.firstObject;
        NSString *imgSrc = imgE.attr(@"data-original");
        if (imgSrc.length > 0) {
            // imgSrc
            contentModel.thumbnailUrl = imgSrc;
        }

        NSString *alt = imgE.attr(@"alt");
        if (alt.length > 0) {
            // alt
            contentModel.title = alt;
        }

        [contentModel insertTable];
//        [JKSqliteModelTool saveOrUpdateModel:contentModel uid:SQLite_USER];
        [contentModels addObject:contentModel];
    }

    return [contentModels copy];
}

- (NSArray *)parserContentListWithType3:(OCGumboDocument *)document {
    OCQueryObject *itemResults = document.Query(@"#mainbodypul");
    if (itemResults.count == 0) {
        return @[];
    }
    OCGumboElement *divElement = itemResults.firstObject;
    NSMutableArray *contentModels = [NSMutableArray array];
    for (OCGumboElement *element in divElement.childNodes) {
        OCQueryObject *aEs = element.Query(@"a");
        if (aEs.count == 0) {
            continue;
        }

        PicContentModel *contentModel = [[PicContentModel alloc] init];
        contentModel.HOST_URL = self.sourceModel.HOST_URL;
        contentModel.sourceTitle = self.sourceModel.title;
        OCGumboElement *aE = aEs.firstObject;
        NSString *url = aE.attr(@"href");
        if (url.length > 0) {
            // url
            contentModel.href = url;
        }

        OCQueryObject *imgEs = aE.Query(@"img");
        if (imgEs.count == 0) {
            continue;
        }
        OCGumboElement *imgE = imgEs.firstObject;
        NSString *imgSrc = imgE.attr(@"data-original");
        if (imgSrc.length > 0) {
            // imgSrc
            contentModel.thumbnailUrl = imgSrc;
        }

        NSString *alt = imgE.attr(@"alt");
        if (alt.length > 0) {
            // alt
            contentModel.title = alt;
        }

        [contentModel insertTable];
//        [JKSqliteModelTool saveOrUpdateModel:contentModel uid:SQLite_USER];
        [contentModels addObject:contentModel];
    }

    return [contentModels copy];
}

#pragma mark PicContentCellDelegate

- (void)contentCell:(PicContentCell *)contentCell downBtnClicked:(UIButton *)sender contentModel:(PicContentModel *)contentModel {
    [ContentParserManager tryToAddTaskWithSourceModel:self.sourceModel ContentModel:contentModel needDownload:YES operationTips:^(BOOL isSuccess, NSString * _Nonnull tips) {
        [MBProgressHUD showInfoOnView:self.view WithStatus:tips afterDelay:0.5];
    }];
}

@end
