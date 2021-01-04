//
//  PicClassifyTableView.m
//  PicData
//
//  Created by Garenge on 2021/1/5.
//  Copyright © 2021 garenge. All rights reserved.
//

#import "PicClassifyTableView.h"

@interface PicClassifyTableView() <UITableViewDelegate, UITableViewDataSource, PicClassifyTagsViewCellDelegate>

@property (nonatomic, strong) NSMutableArray *tagsFrames;

@end

@implementation PicClassifyTableView

- (NSMutableArray *)tagsFrames {
    if (nil == _tagsFrames) {
        _tagsFrames = [NSMutableArray array];
    }
    return _tagsFrames;
}

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

    [self.tagsFrames removeAllObjects];
    for (PicClassModel *classModel in self.dataList) {
        PicClassifyTagsFrame *frame = [[PicClassifyTagsFrame alloc] init];
        frame.tagsMinPadding = 5;
        frame.tagsMargin = 12;
        frame.tagsLineSpacing = 8;
        frame.tagsArray = classModel.subTitleStrings;

        [self.tagsFrames addObject:frame];
    }

    [self reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tagsFrames.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = NSStringFromClass([PicClassifyTagsViewCell class]);
    PicClassifyTagsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell) {
        cell = [[PicClassifyTagsViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.tagsFrame = self.tagsFrames[indexPath.section];
    cell.indexPath = indexPath;
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%f",[self.tagsFrames[indexPath.section] tagsHeight]);
    return [self.tagsFrames[indexPath.section] tagsHeight];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    PicClassModel *classModel = self.dataList[section];
    return classModel.title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (void)tagsViewCell:(PicClassifyTagsViewCell *)tagsViewCell didSelectTags:(NSInteger)tag indexPath:(NSIndexPath *)indexPath {
    if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(tableView:didSelectActionAtIndexPath:withClassModel:)]) {
        NSIndexPath *selIndex = [NSIndexPath indexPathForRow:tag inSection:indexPath.section];
        PicClassModel *classModel = self.dataList[selIndex.section];
        [self.actionDelegate tableView:self didSelectActionAtIndexPath:selIndex withClassModel:classModel];
    }
}
@end
