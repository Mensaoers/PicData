//
//  PicClassifyTableView.h
//  PicData
//
//  Created by Garenge on 2021/1/5.
//  Copyright © 2021 garenge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicClassifyTagsViewCell.h"

NS_ASSUME_NONNULL_BEGIN
@class PicClassifyTableView;
@protocol PicClassifyTableViewActionDelegate <NSObject>

- (void)tableView:(PicClassifyTableView *)tableView didSelectActionAtIndexPath:(NSIndexPath *)indexPath withClassModel:(PicClassModel *)classModel;
@end

@interface PicClassifyTableView : UITableView

@property (nonatomic, strong) NSArray <PicClassModel *> *dataList;
- (void)reloadDataWithSource:(NSArray <PicClassModel *>*)dataList;

@property (nonatomic, weak) id<PicClassifyTableViewActionDelegate> actionDelegate;

@end

NS_ASSUME_NONNULL_END
