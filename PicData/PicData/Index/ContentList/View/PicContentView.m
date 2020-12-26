//
//  PicContentView.m
//  PicData
//
//  Created by CleverPeng on 2020/9/13.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "PicContentView.h"
#import "PicContentCell.h"

@interface PicContentView()

@end

@implementation PicContentView

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
    CGFloat itemHeight = [PicContentView itemWidth:wholeWidth] * 360.0 / 250.0 + 50;
    return itemHeight;
}
+ (CGSize)itemSize:(CGFloat)wholeWidth {
    CGFloat itemWidth = [PicContentView itemWidth:wholeWidth];
    CGFloat itemHieght = [PicContentView itemHeight:wholeWidth];
    CGSize size = CGSizeMake(itemWidth, itemHieght);
    return size;
}

+ (instancetype)collectionView:(CGFloat)wholeWidth {

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = [PicContentView itemSize:wholeWidth];
    layout.sectionInset = UIEdgeInsetsMake(10, sideMargin, 10, sideMargin);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 0;
    PicContentView *collectionView = [[PicContentView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [collectionView registerClass:[PicContentCell class] forCellWithReuseIdentifier:@"PicContentCell"];
    collectionView.backgroundColor = [UIColor whiteColor];
    return collectionView;
}

@end
