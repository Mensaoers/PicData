//
//  PicContentCell.h
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicContentModel.h"

NS_ASSUME_NONNULL_BEGIN

#define PicContentCellSCALE 0.75

@class PicContentCell;
@protocol PicContentCellDelegate <NSObject>

- (void)contentCell:(PicContentCell *)contentCell downBtnClicked:(UIButton *)sender contentModel:(PicContentModel *)contentModel;

@end

@interface PicContentCell : UICollectionViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) PicContentModel *contentModel;
@property (nonatomic, weak) id<PicContentCellDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
