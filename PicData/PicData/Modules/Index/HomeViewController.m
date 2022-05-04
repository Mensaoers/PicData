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

@property (nonatomic, strong) NSString *tagsAddressUrl;
@property (nonatomic, strong) NSString *host_url;

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

- (NSString *)host_url {
    return [[AppTool sharedAppTool].currentHostModel HOST_URL];
}
- (NSString *)tagsAddressUrl {
    return [[AppTool sharedAppTool].currentHostModel tagsUrl];
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

    UIBarButtonItem *rightItem;
    if (isList) {
        rightItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"list_tags"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(rightNavigationItemClickAction:)];
    } else {
        rightItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"list"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(rightNavigationItemClickAction:)];
    }

    self.navigationItem.rightBarButtonItems = @[rightItem];

    MJWeakSelf
    [self cw_registerShowIntractiveWithEdgeGesture:NO transitionDirectionAutoBlock:^(CWDrawerTransitionDirection direction) {
        if (direction == CWDrawerTransitionFromLeft) {
            [weakSelf selectNetHost:nil];
        }
    }];
}

- (void)selectNetHost:(UIBarButtonItem *)sender {
    NetListViewController *hostVC = [NetListViewController new];
    PDBlockSelf
    hostVC.refreshBlock = ^{
        [weakSelf loadAllTags];
    };
    CGFloat distance = MIN(self.view.mj_w * 0.75, 400);
    CWLateralSlideConfiguration *configuration = [CWLateralSlideConfiguration configurationWithDistance:distance maskAlpha:0.4 scaleY:1.0 direction:CWDrawerTransitionFromLeft backImage:nil];
    [self cw_showDrawerViewController:hostVC animationType:CWDrawerAnimationTypeDefault configuration:configuration];
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

    [self loadAllTags];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

#if TARGET_OS_MACCATALYST

    // 方法重置, 在mac端拖动界面大小之后, 刷新tag列表, 重新布局
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshDataList) object:nil];
    [self performSelector:@selector(refreshDataList) afterDelay:0.2];

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

- (void)loadAllTags {

    self.classModels = nil;

    // 添加默认页面
    PicNetModel *hostModel = [AppTool sharedAppTool].currentHostModel;
    PicSourceModel*(^getIndexModel)(void) = ^PicSourceModel *{
        PicSourceModel *sourceModel = [[PicSourceModel alloc] init];
        sourceModel.sourceType = hostModel.sourceType;
        sourceModel.url = hostModel.url;

        NSString *mark = hostModel.mark;
        if (nil == mark || mark.length == 0) {
            mark = [NSString stringWithFormat:@"%d", hostModel.sourceType];
        }

        sourceModel.title = [NSString stringWithFormat:@"%@首页", mark];
        sourceModel.HOST_URL = self.host_url;
        [sourceModel insertTable];
        return sourceModel;
    };

    PicClassModel *indexModel = [PicClassModel modelWithHOST_URL:self.host_url Title:@"首页" sourceType:hostModel.sourceType subTitles:@[getIndexModel()]];
    [self.classModels addObject:indexModel];

    [self.tableView reloadDataWithSource:self.classModels];

    if (self.tagsAddressUrl.length == 0) {
        [self.tableView reloadDataWithSource:self.classModels];
        [self.tableView.mj_header endRefreshing];
        return;
    }
    MJWeakSelf
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PDRequest getWithURL:[NSURL URLWithString:self.tagsAddressUrl] isPhone:NO completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf.tableView.mj_header endRefreshing];
        });
        if (nil == error) {
            NSString *htmlString = [ContentParserManager getHtmlStringWithData:data sourceType:hostModel.sourceType];

            // 解析html
            [weakSelf paraseHtmlString_tags:htmlString];
        } else {
            MJWeakSelf
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadDataWithSource:self.classModels];
            });
        }
    }];
}

- (void)paraseHtmlString_tags:(NSString *)htmlString {

    if (htmlString.length == 0) { return; }

    OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];

    PicNetModel *hostModel = [AppTool sharedAppTool].currentHostModel;

    switch (hostModel.sourceType) {
        case 1: {

            OCQueryObject *tagsListEs = document.QueryClass(@"jigou");

            for (OCGumboElement *tagsListE in tagsListEs) {

                OCQueryObject *aEs = tagsListE.QueryElement(@"a");

                NSMutableArray *subTitles = [NSMutableArray array];
                for (OCGumboElement *aE in aEs) {
                    NSString *href = aE.attr(@"href");
                    NSString *subTitle = aE.text();

                    PicSourceModel *sourceModel = [[PicSourceModel alloc] init];
                    sourceModel.sourceType = hostModel.sourceType;
                    sourceModel.url = [self.host_url stringByAppendingPathComponent:href];
                    sourceModel.title = subTitle;
                    sourceModel.HOST_URL = self.host_url;
                    [sourceModel insertTable];

                    [subTitles addObject:sourceModel];
                }

                PicClassModel *classModel = [PicClassModel modelWithHOST_URL:self.host_url Title:@"标签" sourceType:hostModel.sourceType subTitles:subTitles];
                [self.classModels addObject:classModel];
            }
        }
            break;
        case 2: {
            OCQueryObject *tagsListEs = document.QueryClass(@"TagTop_Gs_r");

            for (OCGumboElement *tagsListE in tagsListEs) {

                OCQueryObject *aEs = tagsListE.QueryElement(@"a");

                NSMutableArray *subTitles = [NSMutableArray array];
                for (OCGumboElement *aE in aEs) {
                    NSString *href = aE.attr(@"href");
                    NSString *subTitle = aE.text();

                    PicSourceModel *sourceModel = [[PicSourceModel alloc] init];
                    sourceModel.sourceType = hostModel.sourceType;
                    sourceModel.url = href;// [self.host_url stringByAppendingPathComponent:href];
                    sourceModel.title = subTitle;
                    sourceModel.HOST_URL = self.host_url;
                    [sourceModel insertTable];

                    [subTitles addObject:sourceModel];
                }

                PicClassModel *classModel = [PicClassModel modelWithHOST_URL:self.host_url Title:@"标签" sourceType:hostModel.sourceType subTitles:subTitles];
                [self.classModels addObject:classModel];
            }
        }
            break;
        case 3: {

        }
            break;
        default:
            break;
    }

    MJWeakSelf
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tableView reloadDataWithSource:self.classModels];
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
