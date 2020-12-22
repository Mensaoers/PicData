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

+ (CGFloat)itemWidth {
    CGFloat itemWidth = MIN(200, (PDSCREENWIDTH - 30) * 0.333);
    return itemWidth;
}
+ (CGFloat)itemHeight {
    CGFloat itemHeight = [PicContentView itemWidth] * 360.0 / 250.0 + 50;
    return itemHeight;
}
+ (CGSize)itemSize {
    CGFloat itemWidth = [PicContentView itemWidth];
    CGFloat itemHieght = [PicContentView itemHeight];
    CGSize size = CGSizeMake(itemWidth, itemHieght);
    return size;
}

+ (instancetype)collectionView {

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = [PicContentView itemSize];
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    PicContentView *collectionView = [[PicContentView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [collectionView registerClass:[PicContentCell class] forCellWithReuseIdentifier:@"PicContentCell"];
    collectionView.backgroundColor = [UIColor whiteColor];
    return collectionView;
}

@end
