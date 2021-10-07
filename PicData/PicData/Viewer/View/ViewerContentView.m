//
//  ViewerContentView.m
//  PicData
//
//  Created by 鹏鹏 on 2020/12/27.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "ViewerContentView.h"

@implementation ViewerContentView


static CGFloat sideMargin = 5;

+ (CGFloat)itemWidth:(CGFloat)wholeWidth {
    // 最小宽度
    CGFloat minWidth = MIN(180, (wholeWidth - 30) * 0.333);
    // 这一行至少可以放几个
    NSInteger count = floorf(wholeWidth / minWidth);
    CGFloat itemWidth = wholeWidth / count;
    // MIN(200, MAX((PDSCREENWIDTH - 30) * 0.333, MIN(130, (PDSCREENWIDTH - 30) * 0.333)));
    return itemWidth - 2 * sideMargin;
}
+ (CGFloat)itemHeight:(CGFloat)wholeWidth {
    CGFloat itemHeight = [ViewerContentView itemWidth:wholeWidth] * ViewerContentImageScale + 70;
    return itemHeight;
}
+ (CGSize)itemSize:(CGFloat)wholeWidth {
    CGFloat itemWidth = [ViewerContentView itemWidth:wholeWidth];
    CGFloat itemHieght = [ViewerContentView itemHeight:wholeWidth];
    CGSize size = CGSizeMake(itemWidth, itemHieght);
    return size;
}

+ (instancetype)collectionView:(CGFloat)wholeWidth {

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = [ViewerContentView itemSize:wholeWidth];
    layout.sectionInset = UIEdgeInsetsMake(10, sideMargin, 10, sideMargin);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 0;
    ViewerContentView *collectionView = [[ViewerContentView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [collectionView registerClass:[ViewerContentCell class] forCellWithReuseIdentifier:@"ViewerContentCell"];
    collectionView.backgroundColor = [UIColor whiteColor];
    return collectionView;
}

@end
