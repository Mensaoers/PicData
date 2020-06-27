//
//  IndexViewController.m
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "IndexViewController.h"
#import "PicClassModel.h"
#import "ContentViewController.h"

@interface IndexViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
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
    [self loadMainView];
    [self loadSourceData];
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
                [weakSelf.tableView reloadData];
                [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"加载完成" afterDelay:1];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"加载失败" afterDelay:1];
            });
        }
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PicClassModel *classModel = self.dataList[section];
    NSArray *list = classModel.subTitles;
    if (list) {
        return list.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    PicClassModel *classModel = self.dataList[indexPath.section];
    PicSourceModel *sourceModel = classModel.subTitles[indexPath.row];
    cell.textLabel.text = sourceModel.title;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    PicClassModel *classModel = self.dataList[section];
    return classModel.title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PicClassModel *classModel = self.dataList[indexPath.section];
    PicSourceModel *sourceModel = classModel.subTitles[indexPath.row];
    ContentViewController *contentVC = [[ContentViewController alloc] initWithSourceModel:sourceModel];
    [self.navigationController pushViewController:contentVC animated:YES];
}

@end
