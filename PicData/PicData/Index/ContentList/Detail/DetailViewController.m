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

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) NSMutableDictionary *heightDic;

@end

@implementation DetailViewController

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
    self.navigationItem.leftBarButtonItems = leftBarButtonItems;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"下载" style:UIBarButtonItemStyleDone target:self action:@selector(downloadThisContent:)];
}

- (void)backAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
    self.detailModel.currentUrl = self.detailModel.nextUrl;
    [self loadDetailData];
    [self loadNavigationItem];
}
- (void)loadDetailData {
    [MBProgressHUD showHUDAddedTo:self.view WithStatus:@"请稍等"];
    PDBlockSelf
    [PDRequest getWithURL:[NSURL URLWithString:self.detailModel.currentUrl relativeToURL:[NSURL URLWithString:self.sourceModel.HOST_URL]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

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
    self.contentLabel.text = self.detailModel.detailTitle;
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
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
                    contentModel.HOST_URL = self.sourceModel.HOST_URL;
                    contentModel.sourceTitle = self.sourceModel.title;
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

                    [contentModel insertTable];
//                    [JKSqliteModelTool saveOrUpdateModel:contentModel uid:SQLite_USER];
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
            PDBlockSelf
            cell.updateCellHeightBlock = ^(NSIndexPath * _Nonnull indexPath_, CGFloat height) {
                [weakSelf.heightDic setValue:@(height) forKey:[NSString stringWithFormat:@"%ld-%ld", (long)indexPath_.section, (long)indexPath_.row]];
                dispatch_async( dispatch_get_main_queue(), ^{
                    UITableViewCell  *existcell = [tableView cellForRowAtIndexPath:indexPath_];
                    if (existcell) {
                        // assign image to cell here
                        [tableView reloadRowsAtIndexPaths:@[indexPath_] withRowAnimation:UITableViewRowAnimationNone];
                    }
                });
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
            break;
    }
    
    return tCell;
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
        return UITableViewAutomaticDimension;
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
    return  section == 0 ? CGFLOAT_MIN : 25;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = UIColor.whiteColor;
    CGRect frame = CGRectMake(0, 0, tableView.mj_w, 25);
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
    [self.historyInfos addObject:@{@"url" : self.detailModel.currentUrl, @"title" : self.detailModel.detailTitle}];
    self.contentModel = model;
    [self loadNextDetailData];
}

- (void)contentCell:(PicContentCell *)contentCell downBtnClicked:(UIButton *)sender contentModel:(PicContentModel *)contentModel {
    [ContentParserManager tryToAddTaskWithSourceModel:self.sourceModel ContentModel:contentModel operationTips:^(BOOL isSuccess, NSString * _Nonnull tips) {
        [MBProgressHUD showInfoOnView:self.view WithStatus:tips afterDelay:0.5];
    }];
}

- (void)downloadThisContent:(UIBarButtonItem *)sender {
    [ContentParserManager tryToAddTaskWithSourceModel:self.sourceModel ContentModel:self.contentModel operationTips:^(BOOL isSuccess, NSString * _Nonnull tips) {
        [MBProgressHUD showInfoOnView:self.view WithStatus:tips afterDelay:0.5];
    }];
}

@end
