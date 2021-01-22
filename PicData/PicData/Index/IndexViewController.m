//
//  IndexViewController.m
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "IndexViewController.h"
#import "ContentViewController.h"
#import "PicClassifyTableView.h"
#import "ClassifyPage.h"
#import "SettingViewController.h"
#import "FloatingWindowView.h"

@interface IndexViewController () <PicClassifyTableViewActionDelegate>

@property (nonatomic, strong) PicClassifyTableView *tableView;
@property (nonatomic, strong) NSArray *dataList;

@end

@implementation IndexViewController

- (NSArray *)dataList {
    if (nil == _dataList) {
        _dataList = @[];
    }
    return _dataList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSourceData];
}

- (void)loadNavigationItem {
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"网络分类" style:UIBarButtonItemStyleDone target:self action:@selector(jumpToClassifyPage)];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)loadRightNavigationItem:(BOOL)isList {
    if (isList) {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"list_tags"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(rightNavigationItemClickAction:)];
        self.navigationItem.rightBarButtonItem = leftItem;
    } else {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"list"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(rightNavigationItemClickAction:)];
        self.navigationItem.rightBarButtonItem = leftItem;
    }
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

- (void)jumpToClassifyPage {
    ClassifyPage *classifyPage = [[ClassifyPage alloc] init];
    [self.navigationController pushViewController:classifyPage animated:YES];
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

    [[FloatingWindowView shareInstance] isHidden:NO];
    
    [FloatingWindowView shareInstance].ClickAction = ^{
        
        BaseTabBarController *tabBarVC = (BaseTabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [tabBarVC setSelectedIndex:0];
        BaseNavigationController *indexNavi = (BaseNavigationController *)tabBarVC.selectedViewController;
        
        NSArray *viewControllers = indexNavi.viewControllers;
        BOOL jumped = NO;
        for (UIViewController *viewController in viewControllers) {
            if ([viewController isKindOfClass:[AddNetTaskVC class]]) {
                // 弹过了, 不弹了
                jumped = YES;
                break;
            }
        }
        if (!jumped) {
            [indexNavi pushViewController:[[AddNetTaskVC alloc] init] animated:YES];
        }
    };
}

- (void)loadSourceData {
    
#ifdef DEBUG
#else
    self.navigationItem.title = @"爱套图手机资源";
    [MBProgressHUD showHUDAddedTo:self.view WithStatus:@"加载中"];
    PDBlockSelf
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *jsonReadingError = nil;
        NSArray *subTitles = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PicSource.json" ofType:@""]] options:NSJSONReadingMutableContainers error:&jsonReadingError];
        if (nil == jsonReadingError) {
            weakSelf.dataList = [PicClassModel mj_objectArrayWithKeyValuesArray:subTitles];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadDataWithSource:weakSelf.dataList];
                [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"加载完成" afterDelay:1];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"加载失败" afterDelay:1];
            });
        }
    });
#endif
    
}

-  (void)tableView:(PicClassifyTableView *)tableView didSelectActionAtIndexPath:(NSIndexPath *)indexPath withClassModel:(PicClassModel *)classModel {
    PicSourceModel *sourceModel = classModel.subTitles[indexPath.row];
    [sourceModel insertTable];
//    [JKSqliteModelTool saveOrUpdateModel:sourceModel uid:SQLite_USER];
    ContentViewController *contentVC = [[ContentViewController alloc] initWithSourceModel:sourceModel];
    [self.navigationController pushViewController:contentVC animated:YES];
}
//- (void)tableView:(PicClassTableView *)tableView didSelectActionAtIndexPath:(NSIndexPath *)indexPath withClassModel:(PicClassModel *)classModel {
//    PicSourceModel *sourceModel = classModel.subTitles[indexPath.row];
//    [sourceModel insertTable];
////    [JKSqliteModelTool saveOrUpdateModel:sourceModel uid:SQLite_USER];
//    ContentViewController *contentVC = [[ContentViewController alloc] initWithSourceModel:sourceModel];
//    [self.navigationController pushViewController:contentVC animated:YES];
//}

@end
