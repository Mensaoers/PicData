//
//  SettingViewController.m
//  PicData
//
//  Created by CleverPeng on 2020/7/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingPathViewController.h"

@interface SettingOperationModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSString *func;


+ (instancetype)ModelWithName:(NSString *)name value:(NSString *)value func:(NSString *)func;

@end

@implementation SettingOperationModel

+ (instancetype)ModelWithName:(NSString *)name value:(NSString *)value func:(NSString *)func {
    SettingOperationModel *operationModel = [[SettingOperationModel alloc] init];
    operationModel.name = name;
    operationModel.value = value;
    operationModel.func = func;
    return operationModel;
}

@end

@interface SettingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray <SettingOperationModel *>* operationModels;

@end

@implementation SettingViewController

- (NSArray<SettingOperationModel *> *)operationModels {
    if (nil == _operationModels) {
        _operationModels = @[
            [SettingOperationModel ModelWithName:@"下载路径" value:[[PDDownloadManager sharedPDDownloadManager] systemDownloadPath] func:@"setDownloadPath:"],
            [SettingOperationModel ModelWithName:@"导出数据库" value:@"" func:@"shareDatabase:"],
            [SettingOperationModel ModelWithName:@"检查更新" value:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] func:@"checkNewVersion:"],
        ];
    }
    return _operationModels;
}

- (void)loadNavigationItem {
    self.navigationItem.title = @"设置";
}

- (void)loadMainView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];

    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.bottom.equalTo(self.view.mas_bottomMargin).with.offset(0);
    }];

    tableView.tableFooterView = [UIView new];
}

#pragma mark tableView delegate, datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.operationModels.count;
}

static NSString *identifier = @"identifier";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    SettingOperationModel *operationModel = self.operationModels[indexPath.row];
    cell.textLabel.text = operationModel.name;
    cell.detailTextLabel.text = operationModel.value;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self performSelfFuncWithString:self.operationModels[indexPath.row].func withObject:cell];
}

- (void)checkNewVersion:(UIView *)sender {

    PDBlockSelf
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PDRequest requestToCheckVersion:NO onView:self.view completehandler:^{
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    }];
}

- (void)setDownloadPath:(UIView *)sender {
    SettingPathViewController *vc = [[SettingPathViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)shareDatabase:(UIView *)sender {
    NSString *dbFilePath = [PDDownloadManager sharedPDDownloadManager].databaseFilePath;
    [AppTool shareFileWithURLs:@[[NSURL fileURLWithPath:dbFilePath]] sourceView:sender completionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        NSLog(@"调用分享的应用id :%@", activityType);
        if (completed) {
            NSLog(@"分享成功!");
        } else {
            NSLog(@"分享失败!");
        }
    }];
}

@end
