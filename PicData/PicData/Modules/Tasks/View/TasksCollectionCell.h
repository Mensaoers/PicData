//
//  TasksCollectionCell.h
//  PicData
//
//  Created by 鹏鹏 on 2022/5/5.
//  Copyright © 2022 garenge. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TasksCollectionCell : UICollectionViewCell

@property (nonatomic, strong) PicContentTaskModel *taskModel;

- (void)updateProgress:(PicContentTaskModel *)taskModel;

@end

NS_ASSUME_NONNULL_END
