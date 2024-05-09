//
//  ViewerContentView.h
//  PicData
//
//  Created by 鹏鹏 on 2020/12/27.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewerContentCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewerContentView : UICollectionView

+ (CGFloat)itemWidth:(CGFloat)wholeWidth sugWidth: (CGFloat)sugWidth;
+ (CGFloat)itemWidth:(CGFloat)wholeWidth;
+ (CGFloat)itemHeight:(CGFloat)wholeWidth;
+ (CGSize)itemSize:(CGFloat)wholeWidth;

+ (instancetype)collectionView:(CGFloat)wholeWidth;

@end

NS_ASSUME_NONNULL_END
