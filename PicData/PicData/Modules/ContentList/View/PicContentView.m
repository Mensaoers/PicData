//
//  PicContentView.m
//  PicData
//
//  Created by CleverPeng on 2020/9/13.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "PicContentView.h"
#import "PicContentCell.h"
#import "PicContentViewFlowLayout.h"

@interface PicContentView()

@end

@implementation PicContentView

static CGFloat sideMargin = 5;

+ (CGFloat)itemWidth:(CGFloat)wholeWidth {
    // cell的排布, 想让cell的宽度逐渐增大, 大到一定程度, 加一个cell, 以此往复

    // 这一行至少可以放几个
    NSInteger suggestCount = 3;
    CGFloat sugWidth = 150;

    if (wholeWidth < 420) {
        sugWidth = 110; // 3
        suggestCount = 3;
    } else {

#if TARGET_OS_MACCATALYST
        sugWidth = 180;
#else
        if (wholeWidth < 680) {
            sugWidth = 135; // 4
        } else if (wholeWidth < 1000) {
            sugWidth = 160; // 5
        } else {
            sugWidth = 200;
        }
#endif

        suggestCount = floorf(wholeWidth / sugWidth);
    }
    CGFloat itemWidth = (wholeWidth - (suggestCount - 1) * 2 * sideMargin) / suggestCount - 1;
    return itemWidth;
}
+ (CGFloat)itemHeight:(CGFloat)wholeWidth {
    CGFloat itemHeight = [PicContentView itemWidth:wholeWidth] * PicContentCellSCALE + 50;
    return itemHeight;
}
+ (CGSize)itemSize:(CGFloat)wholeWidth {
    CGFloat itemWidth = [PicContentView itemWidth:wholeWidth];
    CGFloat itemHieght = [PicContentView itemHeight:wholeWidth];
    CGSize size = CGSizeMake(itemWidth, itemHieght);
    return size;
}

+ (instancetype)collectionView:(CGFloat)wholeWidth {

    PicContentViewFlowLayout *layout = [[PicContentViewFlowLayout alloc] init];
    layout.itemSize = [PicContentView itemSize:wholeWidth - 4 * sideMargin];
    layout.sectionInset = UIEdgeInsetsMake(2 * sideMargin, 2 * sideMargin, 2 * sideMargin, 2 * sideMargin);
    layout.minimumLineSpacing = 2 * sideMargin;
    layout.minimumInteritemSpacing = 2 * sideMargin;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    PicContentView *collectionView = [[PicContentView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [collectionView registerClass:[PicContentCell class] forCellWithReuseIdentifier:@"PicContentCell"];
    collectionView.backgroundColor = [UIColor whiteColor];
    return collectionView;
}

- (void)layoutSubviews {
    [super layoutSubviews];

#if TARGET_OS_MACCATALYST

    // mac端拖拽之后, 界面重新适配
    PicContentViewFlowLayout *layout = (PicContentViewFlowLayout *)self.collectionViewLayout;
    layout.itemSize = [PicContentView itemSize:self.mj_w - 4 * sideMargin];

#endif
}

@end
