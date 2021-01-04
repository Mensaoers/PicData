//
//  PicClassTableView.h
//  PicData
//
//  Created by Garenge on 2020/7/18.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PicClassTableView;
@protocol PicClassTableViewActionDelegate <NSObject>

- (void)tableView:(PicClassTableView *)tableView didSelectActionAtIndexPath:(NSIndexPath *)indexPath withClassModel:(PicClassModel *)classModel;

@end

@interface PicClassTableView : UITableView

@property (nonatomic, strong) NSArray <PicClassModel *> *dataList;
- (void)reloadDataWithSource:(NSArray <PicClassModel *>*)dataList;

@property (nonatomic, weak) id<PicClassTableViewActionDelegate> actionDelegate;

@end

NS_ASSUME_NONNULL_END
