//
//  PicClassTableView.m
//  PicData
//
//  Created by Garenge on 2020/7/18.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "PicClassTableView.h"
#import "PicClassTableViewCell.h"

@interface PicClassTableView() <UITableViewDelegate, UITableViewDataSource>

@end

@implementation PicClassTableView

- (NSArray<PicClassModel *> *)dataList {
    if (nil == _dataList) {
        _dataList = @[];
    }
    return _dataList;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        self.delegate = self;
        self.dataSource = self;
        self.tableFooterView = [UIView new];
    }
    return self;
}

- (void)reloadDataWithSource:(NSArray<PicClassModel *> *)dataList {
    self.dataList = dataList;
    [self reloadData];
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
    NSString *identifier = NSStringFromClass([PicClassTableViewCell class]);
    PicClassTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell) {
        cell = [[PicClassTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
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
    [self deselectRowAtIndexPath:indexPath animated:YES];
    if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(tableView:didSelectActionAtIndexPath:withClassModel:)]) {
        PicClassModel *classModel = self.dataList[indexPath.section];
        [self.actionDelegate tableView:self didSelectActionAtIndexPath:indexPath withClassModel:classModel];
    }
}

@end
