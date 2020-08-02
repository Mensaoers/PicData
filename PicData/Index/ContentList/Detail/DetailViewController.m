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

@interface DetailViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, PicContentCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) DetailViewModel *detailModel;

@property (nonatomic, strong) NSMutableArray <NSDictionary *>*historyInfos;

@end

@implementation DetailViewController

- (void)dealloc {
    NSLog(@"啊, 我被释放了%s", __func__);
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.contentModel.title;
    [self refreshLeftBarButtons];
    [self loadMainView];
    [self.tableView.mj_header beginRefreshing];
}

- (void)refreshLeftBarButtons {
    NSMutableArray *leftBarButtonItems = [NSMutableArray array];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(backAction:)];
    [leftBarButtonItems addObject:backItem];
    if (self.historyInfos.count > 0) {
        UIBarButtonItem *lastPageItem = [[UIBarButtonItem alloc] initWithTitle:@"上一页" style:UIBarButtonItemStyleDone target:self action:@selector(loadLastPageDetailData)];
        [leftBarButtonItems addObject:lastPageItem];
    }
    self.navigationItem.leftBarButtonItems = leftBarButtonItems;
}

- (void)backAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadMainView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    tableView.tableFooterView = [UIView new];
    
    PDBlockSelf
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadDetailData];
    }];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"下载" style:UIBarButtonItemStyleDone target:self action:@selector(downloadThisContent:)];

}

- (void)loadLastPageDetailData {
    NSDictionary *lastInfo = self.historyInfos.lastObject;
    if (nil != lastInfo) {
        self.detailModel.nextUrl = self.detailModel.currentUrl;
        self.detailModel.currentUrl = lastInfo[@"url"];
        self.detailModel.detailTitle = lastInfo[@"title"];
        [self loadDetailData];
        [self.historyInfos removeLastObject];
    }
    [self refreshLeftBarButtons];
}

- (void)loadNextDetailData {
    self.detailModel.currentUrl = self.detailModel.nextUrl;
    [self loadDetailData];
    [self refreshLeftBarButtons];
}
- (void)loadDetailData {
    [MBProgressHUD showHUDAddedTo:self.view WithStatus:@"请稍等"];
    PDBlockSelf
    [PDRequest getWithURL:[NSURL URLWithString:self.detailModel.currentUrl relativeToURL:[NSURL URLWithString:HOST_URL]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (nil == error) {
                // 获取字符串
            NSString *resultString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            dispatch_async(dispatch_get_main_queue(), ^{

                    // 解析数据
                [weakSelf parserDetailListHtmlData:resultString];
                [weakSelf refreshMainView];
                [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
            });
        } else {
            NSLog(@"获取%@数据错误:%@", weakSelf.sourceModel.url,  error);
            dispatch_async(dispatch_get_main_queue(), ^{

                [weakSelf parserDetailListHtmlData:@""];
                [weakSelf refreshMainView];
                [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"获取数据失败"];
            });
        }
    }];
}

- (void)refreshMainView {
    self.navigationItem.title = self.detailModel.detailTitle;
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self.tableView.mj_header endRefreshing];
}

- (void)parserDetailListHtmlData:(NSString *)htmlString {
    self.detailModel.suggesTitle = @"推荐";
    if (htmlString.length > 0) {
        
        OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];
        //        OCGumboElement *root = document.rootElement;
        NSMutableArray *urls = [NSMutableArray array];
        
        OCQueryObject *liResults = document.Query(@".tal");
        if (liResults.count > 0) {
            OCGumboElement *liE = [liResults firstObject];
            OCQueryObject *aEs = liE.Query(@"a");
            for (OCGumboElement *aE in aEs) {
                NSString *href = aE.attr(@"href");
                if (href.length > 0 && [href.lastPathComponent containsString:@"_"]) {
                    self.detailModel.nextUrl = href;
                }
                
                OCQueryObject *imgEs = aE.Query(@"img");
                if (imgEs.count > 0) {
                    OCGumboElement *imgE = imgEs.firstObject;
                    NSString *src = imgE.attr(@"src");
                    if (src.length > 0) {
                                                src = [src stringByReplacingOccurrencesOfString:@"img.aitaotu.cc:8089" withString:@"wapimg.aitaotu.cc:8090"];
//                        src = [src stringByReplacingOccurrencesOfString:@"wapimg.aitaotu.cc:8090" withString:@"img.aitaotu.cc:8089"];
                        [urls addObject:src];
                        
                    }
                }
            }
        } else {
            OCQueryObject *picResults = document.Query(@".big-pic");
            if (picResults.count > 0) {
                OCGumboElement *divE = [picResults firstObject];
                OCQueryObject *aEs = divE.Query(@"a");
                for (OCGumboElement *aE in aEs) {
                    NSString *href = aE.attr(@"href");
                    if (href.length > 0 && [href.lastPathComponent containsString:@"_"]) {
                        self.detailModel.nextUrl = href;
                    }
                    
                    OCQueryObject *imgEs = aE.Query(@"img");
                    if (imgEs.count > 0) {
                        OCGumboElement *imgE = imgEs.firstObject;
                        NSString *src = imgE.attr(@"src");
                        if (src.length > 0) {
                                                        src = [src stringByReplacingOccurrencesOfString:@"img.aitaotu.cc:8089" withString:@"wapimg.aitaotu.cc:8090"];
//                            src = [src stringByReplacingOccurrencesOfString:@"wapimg.aitaotu.cc:8090" withString:@"img.aitaotu.cc:8089"];
                            [urls addObject:src];
                            
                        }
                    }
                }
            }
        }
        
        self.detailModel.contentImgsUrl = [urls copy];
        
        
        // 推荐
        NSMutableArray *suggesM = [NSMutableArray array];
        OCQueryObject *tjResults = document.Query(@".ts-c-tj-l");
        if (tjResults.count == 0) {
            tjResults = document.Query(@".ts-tj-c");
        }
        if (tjResults.count > 0) {
            OCGumboElement *tjE = tjResults.firstObject;
            OCQueryObject *dtEs = tjE.Query(@"dd");
            for (OCGumboElement *dtE in dtEs) {
                OCGumboElement *aE = dtE.Query(@"a").firstObject;
                if (aE) {
                    PicContentModel *contentModel = [[PicContentModel alloc] init];
                    
                    NSString *url = aE.attr(@"href");
                    if (url.length > 0) {
                        // url
                        contentModel.href = url;
                    }
                    
                    OCQueryObject *imgEs = dtE.Query(@"img");
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
                    
                    [suggesM addObject:contentModel];
                }
            }
        }
        
        self.detailModel.suggesArray = [suggesM copy];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.detailModel.contentImgsUrl ? self.detailModel.contentImgsUrl.count : 0;
    } else {
        return 1;
    }
}

- (void)detailContentCell:(DetailViewContentCell *)contentCell refreshedAfterImgLoaded:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[DetailViewContentCell class]]) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
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

            tCell = cell;
        }
            break;
        case 1: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"collect"];
            if (nil == cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"collect"];
                
                UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
                layout.itemSize = CGSizeMake((self.view.mj_w - 30) / 2, (self.view.mj_w - 30) / 2 * 360.0 / 250 + 40);
                layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
                layout.minimumLineSpacing = 10;
                layout.minimumInteritemSpacing = 10;
                UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
                [collectionView registerClass:[PicContentCell class] forCellWithReuseIdentifier:@"PicContentCell"];
                collectionView.delegate = self;
                collectionView.dataSource = self;
                collectionView.backgroundColor = [UIColor whiteColor];
                collectionView.scrollEnabled = NO;
                [cell.contentView addSubview:collectionView];
                collectionView.tag = 9527;
                
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
            break;
    }
    
    return tCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self.historyInfos addObject:@{@"url" : self.detailModel.currentUrl, @"title" : self.detailModel.detailTitle}];
        [self loadNextDetailData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return UITableViewAutomaticDimension;
    } else {
        return ((self.detailModel.suggesArray ? self.detailModel.suggesArray.count : 0) + 1) / 2.0 * ((self.view.mj_w - 30) / 2 * 360.0 / 250 + 50);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *titleLabel = [[UILabel alloc] init];

    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textColor = pdColor(153, 153, 153, 1);

    if (section == 0) {
        titleLabel.text = self.detailModel.detailTitle ?: @"";
    } else {
        titleLabel.text = self.detailModel.suggesTitle ?: @"";
    }

    return titleLabel;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 200;
    } else {
        return ((self.detailModel.suggesArray ? self.detailModel.suggesArray.count : 0) + 1) / 2.0 * ((self.view.mj_w - 30) / 2 * 360.0 / 250 + 50);
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
    [self.historyInfos addObject:@{@"url" : self.detailModel.currentUrl, @"title" : self.detailModel.detailTitle}];
    self.contentModel = model;
    [self loadNextDetailData];
}

- (void)contentCell:(PicContentCell *)contentCell downBtnClicked:(UIButton *)sender contentModel:(PicContentModel *)contentModel {
    if (contentModel.hasAdded) {
        [MBProgressHUD showInfoOnView:self.view WithStatus:@"任务已存在" afterDelay:0.5];
    } else {
        contentModel.hasAdded = YES;
        [[ContentParserManager sharedContentParserManager] parserWithSourceModel:self.sourceModel ContentModel:contentModel needDownload:YES];
        [MBProgressHUD showInfoOnView:self.view WithStatus:@"任务已添加" afterDelay:0.5];
    }
}

- (void)downloadThisContent:(UIButton *)sender {

    if (self.contentModel.hasAdded) {
        [MBProgressHUD showInfoOnView:self.view WithStatus:@"任务已存在" afterDelay:0.5];
    } else {
        self.contentModel.hasAdded = YES;
        [[ContentParserManager sharedContentParserManager] parserWithSourceModel:self.sourceModel ContentModel:self.contentModel needDownload:YES];
        [MBProgressHUD showInfoOnView:self.view WithStatus:@"任务已添加" afterDelay:0.5];
    }
}

@end
