//
//  DetailViewContentCell.h
//  PicData
//
//  Created by Garenge on 2020/4/20.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DetailViewContentCell;

@interface DetailViewContentCell : UITableViewCell

@property (nonatomic, assign) CGFloat targetImageWidth;
@property (nonatomic, strong) UIImageView *conImgView;

@property (nonatomic, strong) NSIndexPath *indexpath;

- (void)setImageUrl:(NSString *)imageUrl refererUrl:(NSString *)refererUrl;

@property (nonatomic, copy) void(^updateCellHeightBlock)(NSIndexPath *indexPath, CGFloat height);

@end

NS_ASSUME_NONNULL_END
