//
//  HomeViewController.m
//  PicData
//
//  Created by 鹏鹏 on 2021/9/12.
//  Copyright © 2021 garenge. All rights reserved.
//

#import "HomeViewController.h"
#import "ContentViewController.h"
#import "PicClassifyTableView.h"

@interface HomeViewController () <PicClassifyTableViewActionDelegate>

@property (nonatomic, strong) PicClassifyTableView *tableView;
@property (nonatomic, strong) NSArray *dataList;

@property (nonatomic, strong) NSString *tagsAddressUrl;
@property (nonatomic, strong) NSString *host_url;

@end

@implementation HomeViewController

- (NSArray *)dataList {
    if (nil == _dataList) {
        _dataList = @[];
    }
    return _dataList;
}

- (NSString *)host_url {
    return [AppTool sharedAppTool].HOST_URL;
}
- (NSString *)tagsAddressUrl {
    return [self.host_url stringByAppendingPathComponent:@"/b/tag/"];
}

- (void)loadNavigationItem {
    self.navigationItem.title = @"标签页";

//    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"网络分类" style:UIBarButtonItemStyleDone target:self action:@selector(jumpToClassifyPage)];
//    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)loadRightNavigationItem:(BOOL)isList {

    UIBarButtonItem *rightItem;
    if (isList) {
        rightItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"list_tags"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(rightNavigationItemClickAction:)];
    } else {
        rightItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"list"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(rightNavigationItemClickAction:)];
    }

    self.navigationItem.rightBarButtonItems = @[rightItem];
}

- (void)rightNavigationItemClickAction:(UIBarButtonItem *)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (self.tableView.classifyStyle == PicClassifyTableViewStyleDefault) {
        [self loadRightNavigationItem:NO];
        self.tableView.classifyStyle = PicClassifyTableViewStyleTags;
    } else if (self.tableView.classifyStyle == PicClassifyTableViewStyleTags) {
        [self loadRightNavigationItem:YES];
        self.tableView.classifyStyle = PicClassifyTableViewStyleDefault;
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)loadMainView {
    [super loadMainView];

    [super loadMainView];
    PicClassifyTableView *tableView = [[PicClassifyTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self loadRightNavigationItem:tableView.classifyStyle == PicClassifyTableViewStyleDefault];
    tableView.actionDelegate = self;
    tableView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:tableView];

    self.tableView = tableView;

    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];

    [self setupFloating];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadAllTags];
}

#pragma mark - request

#pragma mark request tags

- (void)loadAllTags {

    if (self.tagsAddressUrl.length == 0) {
        return;
    }
    MJWeakSelf
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PDRequest getWithURL:[NSURL URLWithString:self.tagsAddressUrl] isPhone:NO completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        });
        if (nil == error) {
            NSString *htmlString = [AppTool getStringWithGB_18030_2000Code:data];

            // 解析html
            [weakSelf paraseHtmlString_tags:htmlString];
        }
    }];
}

- (void)paraseHtmlString_tags:(NSString *)htmlString {

    if (htmlString.length == 0) { return; }

    OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];

    OCQueryObject *tagsListEs = document.QueryClass(@"jigou");

    NSMutableArray *classModels = [NSMutableArray array];
    for (OCGumboElement *tagsListE in tagsListEs) {

        OCQueryObject *aEs = tagsListE.QueryElement(@"a");

        NSMutableArray *subTitles = [NSMutableArray array];
        for (OCGumboElement *aE in aEs) {
            NSString *href = aE.attr(@"href");
            NSString *subTitle = aE.text();

            PicSourceModel *sourceModel = [[PicSourceModel alloc] init];
            sourceModel.sourceType = 4;
            sourceModel.url = [self.host_url stringByAppendingPathComponent:href];
            sourceModel.title = subTitle;
            sourceModel.HOST_URL = self.host_url;
            [sourceModel insertTable];

            [subTitles addObject:sourceModel];
        }

        PicClassModel *classModel = [PicClassModel modelWithHOST_URL:self.host_url Title:@"标签" sourceType:@"4" subTitles:subTitles];
        [classModels addObject:classModel];
    }

    MJWeakSelf
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tableView reloadDataWithSource:classModels];
    });
}

#pragma mark PicClassifyTableViewActionDelegate
-  (void)tableView:(PicClassifyTableView *)tableView didSelectActionAtIndexPath:(NSIndexPath *)indexPath withClassModel:(PicClassModel *)classModel {
    PicSourceModel *sourceModel = classModel.subTitles[indexPath.row];
    [sourceModel insertTable];

    ContentViewController *contentVC = [[ContentViewController alloc] initWithSourceModel:sourceModel];
    [self.navigationController pushViewController:contentVC animated:YES];
}

@end
