//
//  PicContentView.h
//  PicData
//
//  Created by CleverPeng on 2020/9/13.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PicContentView : UICollectionView

+ (CGFloat)itemWidth:(CGFloat)wholeWidth;
+ (CGFloat)itemHeight:(CGFloat)wholeWidth;
+ (CGSize)itemSize:(CGFloat)wholeWidth;

+ (CGSize)contentViewSize:(CGFloat)wholeWidth targetCount:(NSInteger)targetCount;

+ (instancetype)collectionView:(CGFloat)wholeWidth;

@end

NS_ASSUME_NONNULL_END
