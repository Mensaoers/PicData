//
//  IndexViewController.m
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "IndexViewController.h"
#import "ContentViewController.h"
#import "PicClassTableView.h"
#import "ClassifyPage.h"
#import "SettingViewController.h"
#import "FloatingWindowView.h"

@interface IndexViewController () <PicClassTableViewActionDelegate>

@property (nonatomic, strong) PicClassTableView *tableView;
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
    self.navigationItem.title = @"爱套图手机资源";
    [self loadNavigationItem];
    [self loadMainView];
    [self loadSourceData];
}

- (void)loadNavigationItem {
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"网络分类" style:UIBarButtonItemStyleDone target:self action:@selector(jumpToClassifyPage)];
    self.navigationItem.leftBarButtonItem = leftItem;

    UIBarButtonItem *settingItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStyleDone target:self action:@selector(jumpToSettingPage)];
    self.navigationItem.rightBarButtonItem = settingItem;
}

- (void)jumpToClassifyPage {
    ClassifyPage *classifyPage = [[ClassifyPage alloc] init];
    [self.navigationController pushViewController:classifyPage animated:YES];
}

- (void)jumpToSettingPage {
    SettingViewController *settingPage = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:settingPage animated:YES];
}

- (void)loadMainView {
    PicClassTableView *tableView = [[PicClassTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.actionDelegate = self;
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];

    [[FloatingWindowView shareInstance] isHidden:NO];
    PDBlockSelf
    [FloatingWindowView shareInstance].ClickAction = ^{
        NSArray *viewControllers = weakSelf.navigationController.viewControllers;
        BOOL jumped = NO;
        for (UIViewController *viewController in viewControllers) {
            if ([viewController isKindOfClass:[AddNetTaskVC class]]) {
                // 弹过了, 不弹了
                jumped = YES;
                break;
            }
        }
        if (!jumped) {
            [weakSelf.navigationController pushViewController:[[AddNetTaskVC alloc] init] animated:YES];
        }
    };
}

- (void)loadSourceData {
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
}

- (void)tableView:(PicClassTableView *)tableView didSelectActionAtIndexPath:(NSIndexPath *)indexPath withClassModel:(PicClassModel *)classModel {
    PicSourceModel *sourceModel = classModel.subTitles[indexPath.row];
    [sourceModel insertTable];
//    [JKSqliteModelTool saveOrUpdateModel:sourceModel uid:SQLite_USER];
    ContentViewController *contentVC = [[ContentViewController alloc] initWithSourceModel:sourceModel];
    [self.navigationController pushViewController:contentVC animated:YES];
}

@end
