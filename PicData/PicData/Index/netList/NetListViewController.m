//
//  NetListViewController.m
//  PicData
//
//  Created by 鹏鹏 on 2022/2/18.
//  Copyright © 2022 garenge. All rights reserved.
//

#import "NetListViewController.h"
#import "PicNetModel.h"

@interface NetListViewController() <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray <PicNetModel *>* dataList;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) PicNetModel *selectedModel;

@end

@implementation NetListViewController

@synthesize selectedModel = _selectedModel;
- (PicNetModel *)selectedModel {
    if (nil == _selectedModel) {
        _selectedModel = [HostManager sharedHostManager].currentHostModel;
    }
    return _selectedModel;
}

- (void)setSelectedModel:(PicNetModel *)selectedModel {
    _selectedModel = selectedModel;
    [HostManager sharedHostManager].currentHostModel = selectedModel;

    PPIsBlockExecute(self.refreshBlock);
}

- (NSArray<PicNetModel *> *)dataList {
    if (nil == _dataList) {
        _dataList = [NSArray arrayWithArray:[HostManager sharedHostManager].hostModels];
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
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    PicNetModel *netModel = self.dataList[indexPath.row];
    cell.textLabel.text = netModel.title;
    cell.textLabel.font = [UIFont systemFontOfSize:17];

    cell.backgroundColor = [netModel.HOST_URL isEqualToString:self.selectedModel.HOST_URL] ? [UIColor redColor] : [UIColor whiteColor];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    self.selectedModel = self.dataList[indexPath.row];
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

@end
