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
#import "NetListViewController.h"

@interface HomeViewController () <PicClassifyTableViewActionDelegate>

@property (nonatomic, strong) PicClassifyTableView *tableView;
@property (nonatomic, strong) NSArray *dataList;

@property (nonatomic, strong) NSMutableArray <PicClassModel *> *classModels;

@end

@implementation HomeViewController

- (NSArray *)dataList {
    if (nil == _dataList) {
        _dataList = @[];
    }
    return _dataList;
}

- (NSMutableArray<PicClassModel *> *)classModels {
    if (nil == _classModels) {
        _classModels = [NSMutableArray array];
    }
    return _classModels;
}

- (void)loadNavigationItem {
    self.navigationItem.title = @"标签页";
}

- (void)loadRightNavigationItem:(BOOL)isList {

    NSMutableArray *leftBarButtonItems = [NSMutableArray array];

    UIBarButtonItem *checkItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"network"] style:UIBarButtonItemStyleDone target:self action:@selector(selectNetHost:)];
    [leftBarButtonItems addObject:checkItem];

#if TARGET_OS_MACCATALYST
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"arrow.clockwise"] style:UIBarButtonItemStyleDone target:self action:@selector(refreshItemClickAction:)];
    [leftBarButtonItems addObject:refreshItem];
#endif
    self.navigationItem.leftBarButtonItems = leftBarButtonItems;

    NSMutableArray *rightBarButtonItems = [NSMutableArray array];

    UIBarButtonItem *listItem;
    if (isList) {
        listItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"list_tags"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(listNavigationItemClickAction:)];
    } else {
        listItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"list"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(listNavigationItemClickAction:)];
    }
    [rightBarButtonItems addObject:listItem];

    PicNetModel *hostModel = [AppTool sharedAppTool].currentHostModel;
    if (hostModel.searchKeys.count > 0 || [[AppTool sharedAppTool] searchKeys].count > 0) {
        UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"magnifyingglass"] style:UIBarButtonItemStyleDone target:self action:@selector(searchItemClickAction:)];
        [rightBarButtonItems addObject:searchItem];
    }

    self.navigationItem.rightBarButtonItems = rightBarButtonItems;

}

- (void)selectNetHost:(UIBarButtonItem *)sender {
    NetListViewController *hostVC = [NetListViewController new];
    PDBlockSelf
    hostVC.refreshBlock = ^{
        [weakSelf loadAllTags];
    };
    CGFloat distance = MIN(self.view.mj_w * 0.75, 400);
    hostVC.targetWidth = distance;
    CWLateralSlideConfiguration *configuration = [CWLateralSlideConfiguration configurationWithDistance:distance maskAlpha:0.4 scaleY:1.0 direction:CWDrawerTransitionFromLeft backImage:nil];
    [self cw_showDrawerViewController:hostVC animationType:CWDrawerAnimationTypeDefault configuration:configuration];
}

- (void)listNavigationItemClickAction:(UIBarButtonItem *)sender {
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

- (void)searchItemClickAction:(UIBarButtonItem *)sender {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"搜索套图" message:@"请输入你想要搜索的关键字" preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"套图关键字";
    }];

    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        UITextField *keywordTF = alert.textFields.firstObject;
        NSString *titleString = keywordTF.text;
        if (titleString.length == 0) {
            return;
        }

        PicNetModel *hostModel = AppTool.sharedAppTool.currentHostModel;
        NSString *titleStringEncode = hostModel.searchEncode ? [titleString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] : [titleString stringByAddingPercentEscapesUsingEncoding:[AppTool getNSStringEncoding_GB_18030_2000]];
        NSString *searchUrl = [NSString stringWithFormat:hostModel.searchFormat, titleStringEncode];

        PicSourceModel *sourceModel = [[PicSourceModel alloc] init];
        sourceModel.sourceType = hostModel.sourceType;
        sourceModel.url = searchUrl;
        sourceModel.title = titleString;
        sourceModel.HOST_URL = hostModel.HOST_URL;
        [sourceModel insertTable];

        ContentViewController *contentVC = [[ContentViewController alloc] initWithSourceModel:sourceModel];
        [self.navigationController pushViewController:contentVC animated:YES];

    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)loadMainView {

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

    MJWeakSelf
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{

        [weakSelf loadAllTags];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[TKGestureLockManager sharedInstance] showGestureLockWindow];

    MJWeakSelf
    [self cw_registerShowIntractiveWithEdgeGesture:NO transitionDirectionAutoBlock:^(CWDrawerTransitionDirection direction) {
        if (direction == CWDrawerTransitionFromLeft) {
            [weakSelf selectNetHost:nil];
        }
    }];

    [self loadAllTags];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

#if TARGET_OS_MACCATALYST

    // 方法重置, 在mac端拖动界面大小之后, 刷新tag列表, 重新布局
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshDataList) object:nil];
    [self performSelector:@selector(refreshDataList) afterDelay:0.5];

#endif

}

- (void)refreshDataList {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadDataWithSource:self.classModels];
    });
}

- (void)refreshItemClickAction:(UIBarButtonItem *)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self loadAllTags];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - request

#pragma mark request tags

- (void)prepareDefaultTags:(PicNetModel *)hostModel {

    NSArray <PicSourceModel*>*(^getIndexModel)(PicNetModel *hostModel) = ^NSArray <PicSourceModel*> * (PicNetModel *hostModel) {

        NSMutableArray *sourceModels = [NSMutableArray array];

        for (PicNetUrlModel *urlModel in hostModel.urls) {
            PicSourceModel *sourceModel = [[PicSourceModel alloc] init];
            sourceModel.sourceType = hostModel.sourceType;
            sourceModel.url = urlModel.url;

            if (urlModel.title.length > 0) {
                sourceModel.title = urlModel.title;
            } else {
                NSString *mark = hostModel.mark;
                if (nil == mark || mark.length == 0) {
                    mark = [NSString stringWithFormat:@"%d", hostModel.sourceType];
                }

                sourceModel.title = [NSString stringWithFormat:@"%@首页", mark];
            }

            sourceModel.HOST_URL = hostModel.HOST_URL;
            [sourceModel insertTable];

            [sourceModels addObject:sourceModel];
        }

        return sourceModels;
    };

    NSMutableArray *subTitles = [NSMutableArray array];
    [subTitles addObjectsFromArray:getIndexModel(hostModel)];

    if (hostModel.searchFormat.length > 0) {
        NSArray *searchKeys = hostModel.searchKeys;
        if (nil == searchKeys || searchKeys.count == 0) {
            searchKeys = AppTool.sharedAppTool.searchKeys;
        }
        for (NSString *titleString in searchKeys) {
            NSString *titleStringEncode = hostModel.searchEncode ? [titleString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] : [titleString stringByAddingPercentEscapesUsingEncoding:[AppTool getNSStringEncoding_GB_18030_2000]];
            NSString *searchUrl = [NSString stringWithFormat:hostModel.searchFormat, titleStringEncode];

            PicSourceModel *sourceModel = [[PicSourceModel alloc] init];
            sourceModel.sourceType = hostModel.sourceType;
            sourceModel.url = searchUrl;

            sourceModel.title = titleString;
            sourceModel.HOST_URL = hostModel.HOST_URL;
            [sourceModel insertTable];

            [subTitles addObject:sourceModel];
        }
    }

    PicClassModel *indexModel = [PicClassModel modelWithHOST_URL:hostModel.HOST_URL Title:@"首页" sourceType:hostModel.sourceType subTitles:subTitles];
    [self.classModels addObject:indexModel];

    [self loadRightNavigationItem:self.tableView.classifyStyle == PicClassifyTableViewStyleDefault];
}

- (void)loadAllTags {

    [self.classModels removeAllObjects];

    // 添加默认页面
    PicNetModel *hostModel = [AppTool sharedAppTool].currentHostModel;

    [self prepareDefaultTags:hostModel];
    // 先加载默认的
    [self.tableView reloadDataWithSource:self.classModels];

    if (hostModel.tagsUrl.length == 0) {
        [self.tableView.mj_header endRefreshing];
        return;
    }
    MJWeakSelf
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PDRequest getWithURL:[NSURL URLWithString:hostModel.tagsUrl] isPhone:NO completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf.tableView.mj_header endRefreshing];
        });
        if (nil == error) {

            // 处理数据
            [weakSelf paraseResponseData:data hostModel:hostModel];
        }

        MJWeakSelf
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadDataWithSource:self.classModels];
        });
    }];
}

- (void)paraseResponseData:(NSData *)data hostModel:(PicNetModel *)hostModel {

    NSString *htmlString = [ContentParserManager getHtmlStringWithData:data sourceType:hostModel.sourceType];

    NSArray *classModels = [ContentParserManager parseTagsWithHtmlString:htmlString HostModel:hostModel];

    [self.classModels addObjectsFromArray:classModels];
}

#pragma mark PicClassifyTableViewActionDelegate
-  (void)tableView:(PicClassifyTableView *)tableView didSelectActionAtIndexPath:(NSIndexPath *)indexPath withClassModel:(PicClassModel *)classModel {

    PicSourceModel *sourceModel = classModel.subTitles[indexPath.row];
    [sourceModel insertTable];

    ContentViewController *contentVC = [[ContentViewController alloc] initWithSourceModel:sourceModel];
    [self.navigationController pushViewController:contentVC animated:YES];
}

@end
