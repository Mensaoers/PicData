//
//  PicClassifyTableView.m
//  PicData
//
//  Created by Garenge on 2021/1/5.
//  Copyright © 2021 garenge. All rights reserved.
//

#import "PicClassifyTableView.h"
#import "PicClassifyTagsViewCell.h"

@interface PicClassifyTableView() <UITableViewDelegate, UITableViewDataSource, PicClassifyTagsViewCellDelegate>

@property (nonatomic, strong) NSMutableArray *tagsFrames;

@end

@implementation PicClassifyTableView

- (void)setClassifyStyle:(PicClassifyTableViewStyle)classifyStyle {
    _classifyStyle = classifyStyle;

    [self reloadData];
}

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
        _classifyStyle = PicClassifyTableViewStyleTags;
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
        frame.currWidth = self.mj_w;
        frame.tagsMinPadding = 5;
        frame.tagsMargin = 12;
        frame.tagsLineSpacing = 8;
        frame.tagsArray = classModel.subTitleStrings;

        [self.tagsFrames addObject:frame];
    }

    [self reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.classifyStyle == PicClassifyTableViewStyleTags) {
        return self.tagsFrames.count;
    } else {
        return self.dataList.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.classifyStyle == PicClassifyTableViewStyleTags) {
        return 1;
    } else {
        PicClassModel *classModel = self.dataList[section];
        NSArray *list = classModel.subTitles;
        if (list) {
            return list.count;
        } else {
            return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (self.classifyStyle == PicClassifyTableViewStyleTags) {
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
    } else {
        NSString *identifier = NSStringFromClass([UITableViewCell class]);
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        PicClassModel *classModel = self.dataList[indexPath.section];
        PicSourceModel *sourceModel = classModel.subTitles[indexPath.row];
        cell.textLabel.text = sourceModel.title;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.classifyStyle == PicClassifyTableViewStyleTags) {
//        NSLog(@"%f",[self.tagsFrames[indexPath.section] tagsHeight]);
        return [self.tagsFrames[indexPath.section] tagsHeight];
    } else {
        return 44;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    PicClassModel *classModel = self.dataList[section];
    return classModel.title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.classifyStyle == PicClassifyTableViewStyleTags) {

    } else {
        [self deselectRowAtIndexPath:indexPath animated:YES];
        if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(tableView:didSelectActionAtIndexPath:withClassModel:)]) {
            PicClassModel *classModel = self.dataList[indexPath.section];
            [self.actionDelegate tableView:self didSelectActionAtIndexPath:indexPath withClassModel:classModel];
        }
    }
}

- (void)tagsViewCell:(PicClassifyTagsViewCell *)tagsViewCell didSelectTags:(NSInteger)tag indexPath:(NSIndexPath *)indexPath {
    if (self.classifyStyle == PicClassifyTableViewStyleTags) {
        if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(tableView:didSelectActionAtIndexPath:withClassModel:)]) {
            NSIndexPath *selIndex = [NSIndexPath indexPathForRow:tag inSection:indexPath.section];
            PicClassModel *classModel = self.dataList[selIndex.section];
            [self.actionDelegate tableView:self didSelectActionAtIndexPath:selIndex withClassModel:classModel];
        }
    }
}

@end
