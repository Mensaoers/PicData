//
//  PicContentViewFlowLayout.m
//  PicData
//
//  Created by Garenge on 2021/3/14.
//  Copyright © 2021 garenge. All rights reserved.
//

#import "PicContentViewFlowLayout.h"

@implementation PicContentViewFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    /// 暂且设为NO, 不让他改
    return NO;
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *arr = [self getCopyOfAttributes:[super layoutAttributesForElementsInRect:rect]];
    for (UICollectionViewLayoutAttributes *attribute in arr) {
        // 在这里修改每个item的属性, 包括frame, size之类的
        CGSize size = attribute.size;
        size.width = self.itemSize.width;
        attribute.size = size;
    }
    return arr;
}

- (NSArray *)getCopyOfAttributes:(NSArray *)attributes {
    NSMutableArray *copyArr = [NSMutableArray new];
    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        [copyArr addObject:[attribute copy]];
    }
    return copyArr;
}

@end
