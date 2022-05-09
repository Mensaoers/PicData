//
//  TasksContentView.h
//  PicData
//
//  Created by 鹏鹏 on 2022/5/8.
//  Copyright © 2022 garenge. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CollectionHeaderView : UICollectionReusableView

@end

@interface TasksContentView : UICollectionView

+ (CGFloat)itemWidth:(CGFloat)wholeWidth;
+ (CGFloat)itemHeight:(CGFloat)wholeWidth;
+ (CGSize)itemSize:(CGFloat)wholeWidth;

+ (instancetype)collectionView:(CGFloat)wholeWidth;

@end

NS_ASSUME_NONNULL_END
