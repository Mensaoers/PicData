//
//  TransViewCell.h
//  PicData
//
//  Created by CleverPeng on 2020/8/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TransViewCell : UITableViewCell

@property (nonatomic, strong) PicContentModel *contentModel;
- (void)setDownloadedCount:(int)downloadCount;
- (void)setTotalCount:(int)totalCount;
@end

NS_ASSUME_NONNULL_END
