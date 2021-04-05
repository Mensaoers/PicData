//
//  ClassifyPage.m
//  PicData
//
//  Created by Garenge on 2020/7/18.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "ClassifyPage.h"
#import "PicClassifyTableView.h"
#import "ContentViewController.h"

@interface ClassifyPage () <PicClassifyTableViewActionDelegate>

@property (nonatomic, strong) PicClassifyTableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation ClassifyPage

- (NSArray *)dataArray {
    if (nil == _dataArray) {
        _dataArray = @[];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView.mj_header beginRefreshing];
}

- (void)loadNavigationItem {
    self.navigationItem.title = @"标签";
}

- (void)loadMainView {
    [super loadMainView];
    
    PicClassifyTableView *tableView = [[PicClassifyTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.actionDelegate = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    PDBlockSelf
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadData_list];
    }];
}

- (void)loadData_list {
    __weak typeof(self) weakSelf = self;
    [PDRequest getWithURL:[NSURL URLWithString:HOST_URL_M_AITAOTU_TAG] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [weakSelf.tableView.mj_header endRefreshing];
        if (nil == error) {
            NSLog(@"获取分类列表成功");
            NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *filePath = [[[PDDownloadManager sharedPDDownloadManager] getDirPathWithSource:nil contentModel:nil] stringByAppendingPathComponent:@"classify.txt"];
            [data writeToFile:filePath atomically:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"获取成功"];
                // 解析数据
                weakSelf.dataArray = [weakSelf dealWithHtml:htmlString HOST_URLString:HOST_URL_M_AITAOTU];
                [weakSelf.tableView reloadDataWithSource:weakSelf.dataArray];
            });
            
        } else {
            NSLog(@"获取分类列表失败");
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"获取分类列表失败"];
                // 解析数据
            });
        }
    }];
}

/// 分类标签可能type都是2
- (NSArray *)dealWithHtml:(NSString *)htmlString HOST_URLString:(NSString *)HOST_URLString {
    if (nil == htmlString || htmlString.length == 0) {
        NSLog(@"标签页数据为空");
        return @[];
    }
    
    OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];
    
    OCQueryObject *titleEles = document.Query(@".nav-title");
    OCQueryObject *listEles = document.Query(@".nav-list");
    if (titleEles.count != listEles.count) {
        // 说明啥呢, 说明名称和内容数组对不上, 就不纠结于名称了
    }
    
    NSInteger count = listEles.count;
    NSMutableArray *classModels = [NSMutableArray array];
    for (NSInteger index = 0; index < count; index ++) {
        
        NSString *title = @"分类标题";
        if (titleEles.count >= index + 1) {
            OCGumboElement *h2Ele = titleEles[index];
            OCQueryObject *aEles = h2Ele.Query(@"a");
            if (aEles.count > 0) {
                OCGumboElement *aEle = aEles[0];
                title = aEle.text();
            }
        }
        
        NSMutableArray *sourceModels = [NSMutableArray array];
        OCGumboElement *divEle = listEles[index];
        OCQueryObject *aEles = divEle.Query(@"a");
        
        for (OCGumboElement *aEle in aEles) {
            NSString *tmp = aEle.attr(@"href");
            if (tmp.length == 0) {
                continue;
            }
            NSString *href = [HOST_URLString stringByAppendingPathComponent:tmp];
            NSString *title = aEle.text();
            
            PicSourceModel *sourceMdoel = [[PicSourceModel alloc] init];
            sourceMdoel.title = title;
            sourceMdoel.url = href;
            sourceMdoel.sourceType = 2;
            sourceMdoel.HOST_URL = HOST_URLString;
            
            [sourceModels addObject:sourceMdoel];
        }
        
        PicClassModel *classModel = [PicClassModel modelWithHOST_URL:HOST_URLString Title:title sourceType:@"2" subTitles:sourceModels.copy];
        [classModels addObject:classModel];
    }
    
    return [classModels copy];
}

#pragma mark delegate
- (void)tableView:(PicClassifyTableView *)tableView didSelectActionAtIndexPath:(NSIndexPath *)indexPath withClassModel:(PicClassModel *)classModel {
    PicSourceModel *sourceModel = classModel.subTitles[indexPath.row];
    [sourceModel insertTable];
//    [JKSqliteModelTool saveOrUpdateModel:sourceModel uid:SQLite_USER];
    ContentViewController *contentVC = [[ContentViewController alloc] initWithSourceModel:sourceModel];
    [self.navigationController pushViewController:contentVC animated:YES];
}

@end
