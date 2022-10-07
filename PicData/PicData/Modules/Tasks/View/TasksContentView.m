//
//  TasksContentView.m
//  PicData
//
//  Created by 鹏鹏 on 2022/5/8.
//  Copyright © 2022 garenge. All rights reserved.
//

#import "TasksContentView.h"

@implementation CollectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //        self.backgroundColor = [UIColor grayColor];
    }
    return self;
}

@end

@implementation TasksContentView

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
    // (617.0 / 411)
    CGFloat itemHeight = [TasksContentView itemWidth:wholeWidth] * 1.3 + 60;
    return itemHeight;
}
+ (CGSize)itemSize:(CGFloat)wholeWidth {
    CGFloat itemWidth = [TasksContentView itemWidth:wholeWidth];
    CGFloat itemHieght = [TasksContentView itemHeight:wholeWidth];
    CGSize size = CGSizeMake(itemWidth, itemHieght);
    return size;
}

+ (instancetype)collectionView:(CGFloat)wholeWidth {

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = [TasksContentView itemSize:wholeWidth - 4 * sideMargin];
    layout.sectionInset = UIEdgeInsetsMake(2 * sideMargin, 2 * sideMargin, 2 * sideMargin, 2 * sideMargin);
    layout.minimumLineSpacing = 2 * sideMargin;
    layout.minimumInteritemSpacing = 2 * sideMargin;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;

    TasksContentView *collectionView = [[TasksContentView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    return collectionView;
}

- (void)layoutSubviews {
    [super layoutSubviews];

#if TARGET_OS_MACCATALYST

    // mac端拖拽之后, 界面重新适配
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    layout.itemSize = [TasksContentView itemSize:self.mj_w - 4 * sideMargin];

#endif
}

@end
