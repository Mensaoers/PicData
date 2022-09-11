//
//  NetListViewController.m
//  PicData
//
//  Created by 鹏鹏 on 2022/2/18.
//  Copyright © 2022 garenge. All rights reserved.
//

#import "NetListViewController.h"
#import "NetListTCell.h"

@interface NetListViewController() <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray <PicNetModel *>* dataList;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) PicNetModel *selectedModel;

@end

@implementation NetListViewController

@synthesize selectedModel = _selectedModel;
- (PicNetModel *)selectedModel {
    if (nil == _selectedModel) {
        _selectedModel = [AppTool sharedAppTool].currentHostModel;
    }
    return _selectedModel;
}

- (void)setSelectedModel:(PicNetModel *)selectedModel {
    _selectedModel = selectedModel;
    [AppTool sharedAppTool].currentHostModel = selectedModel;

    PPIsBlockExecute(self.refreshBlock);
}

- (NSArray<PicNetModel *> *)dataList {
    if (nil == _dataList) {
        _dataList = [NSArray arrayWithArray:[AppTool sharedAppTool].hostModels];
    }
    return _dataList;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)loadMainView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;

    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.topMargin.bottomMargin.mas_equalTo(0);
        make.width.mas_equalTo(self.targetWidth > 0 ? self.targetWidth : 300);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *identifier = @"NetListTCell";
    NetListTCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (nil == cell) {
        cell = [[NetListTCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    PicNetModel *netModel = self.dataList[indexPath.row];
    cell.hostModel = netModel;
    cell.isForcus = [netModel.HOST_URL isEqualToString:self.selectedModel.HOST_URL];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    self.selectedModel = self.dataList[indexPath.row];
    [tableView reloadData];
}

@end
