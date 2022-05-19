//
//  PicClassifyTableView.h
//  PicData
//
//  Created by Garenge on 2021/1/5.
//  Copyright © 2021 garenge. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PicClassifyTableViewStyle) {
    PicClassifyTableViewStyleDefault, // 常规tableView
    PicClassifyTableViewStyleTags, // 多标签样式
};

@class PicClassifyTableView;
@protocol PicClassifyTableViewActionDelegate <NSObject>

- (void)tableView:(PicClassifyTableView *)tableView didSelectActionAtIndexPath:(NSIndexPath *)indexPath withClassModel:(PicClassModel *)classModel;
@end

@interface PicClassifyTableView : UITableView

/// 界面展示样式
@property (nonatomic, assign) PicClassifyTableViewStyle classifyStyle;

@property (nonatomic, strong) NSArray <PicClassModel *> *dataList;
- (void)reloadDataWithSource:(NSArray <PicClassModel *>*)dataList;

@property (nonatomic, weak) id<PicClassifyTableViewActionDelegate> actionDelegate;

@end

NS_ASSUME_NONNULL_END
