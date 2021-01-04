//
//  PicClassifyTagsViewCell.h
//  TagsDemo
//
//  Created by Administrator on 16/1/21.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicClassifyTagsFrame.h"

@class PicClassifyTagsViewCell;
@protocol PicClassifyTagsViewCellDelegate <NSObject>

- (void)tagsViewCell:(PicClassifyTagsViewCell *)tagsViewCell didSelectTags:(NSInteger)tag indexPath:(NSIndexPath *)indexPath;

@end

@interface PicClassifyTagsViewCell : UITableViewCell

+ (id)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, weak) id<PicClassifyTagsViewCellDelegate> delegate;

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) PicClassifyTagsFrame *tagsFrame;

@end
