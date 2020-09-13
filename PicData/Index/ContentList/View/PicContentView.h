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

+ (CGFloat)itemWidth;
+ (CGFloat)itemHeight;
+ (CGSize)itemSize;

+ (instancetype)collectionView;
@property (nonatomic, strong) NSArray<PicContentModel *> *dataList;

@end

NS_ASSUME_NONNULL_END
