//
//  NSArray+ppEx.m
//  Ashton
//
//  Created by pengpeng on 2023/11/16.
//  Copyright © 2023 Falcon Automation. All rights reserved.
//

#import "NSArray+ppEx.h"

@implementation NSArray (ppEx)

@dynamic objectNullableAtIndexBlock;
/// 点语法返回数组指定下标的元素, 可以为空, 不会越界
- (id _Nullable (^)(NSUInteger))objectNullableAtIndexBlock {
    return ^_Nullable id(NSUInteger index) {
        return [self pp_objectNullableAtIndex:index];
    };
}
/// 返回数组指定下标的元素, 可以为空, 不会越界
- (id)pp_objectNullableAtIndex:(NSUInteger)index {
    if (self.count > index) {
        return [self objectAtIndex:index];
    } else {
        return nil;
    }
}


@dynamic mapBlock;
/// 点语法生成新的数组, 回调返回重新生成的符合要求的对象
- (NSArray * _Nonnull (^)(id  _Nonnull (^ _Nonnull)(id _Nonnull)))mapBlock {
    return ^NSArray *(id(^block)(id element)) {
        return [self pp_map:block];
    };
}
/// 生成新的数组, 回调返回重新生成的符合要求的对象
- (NSArray *)pp_map:(id  _Nonnull (^)(id _Nonnull))block {
    if (!block) { return @[]; }
    
    NSMutableArray *array = [NSMutableArray array];
    for (id object in self) {
        [array addObject:block(object)];
    }
    return array;
}


@dynamic mapWithIndexBlock;
/// 点语法生成新的数组, 回调 带下标 返回重新生成的符合要求的对象
- (NSArray * _Nonnull (^)(id  _Nonnull (^ _Nonnull)(id _Nonnull, NSInteger)))mapWithIndexBlock {
    return ^NSArray *(id(^block)(id element, NSInteger index)) {
        return [self pp_mapWithIndex:block];
    };
}
/// 生成新的数组, 回调 带下标 返回重新生成的符合要求的对象
- (NSArray *)pp_mapWithIndex:(id  _Nonnull (^)(id _Nonnull, NSInteger))block {
    if (!block) { return @[]; }
    
    NSMutableArray *array = [NSMutableArray array];
    NSInteger count = self.count;
    for (NSInteger index = 0; index < count; index ++) {
        id object = [self objectAtIndex:index];
        [array addObject:block(object, index)];
    }
    return array;
}


@dynamic filterBlock;
/// 点语法过滤符合条件的元素, 生成新的数组
- (NSArray * _Nonnull (^)(BOOL (^ _Nonnull)(id _Nonnull)))filterBlock {
    return ^NSArray *(BOOL(^block)(id element)) {
        return [self pp_filter:block];
    };
}
/// 过滤符合条件的元素, 生成新的数组
- (NSArray *)pp_filter:(BOOL (^)(id _Nonnull))block {
    if (!block) { return @[]; }
    
    NSMutableArray *array = [NSMutableArray array];
    for (id object in self) {
        if (block(object)) {
            [array addObject:object];
        }
    }
    return array;
}


@dynamic containsBlock;
/// 点语法判断是否包含满足条件的元素
- (BOOL (^)(BOOL (^ _Nonnull)(id _Nonnull)))containsBlock {
    return ^BOOL (BOOL(^block)(id element)) {
        return [self pp_contains:block];
    };
}
/// 判断是否包含满足条件的元素
- (BOOL)pp_contains:(BOOL (^)(id _Nonnull))block {
    if (!block) { return NO; }
    
    for (id object in self) {
        if (block(object)) {
            return YES;
        }
    }
    return NO;
}


@dynamic firstBlock;
/// 点语法找到第一个符合条件的元素, 可以为空
- (id  _Nonnull (^)(BOOL (^ _Nonnull)(id _Nonnull)))firstBlock {
    return ^id (BOOL(^block)(id element)) {
        return [self pp_first:block];
    };
}
/// 找到第一个符合条件的元素, 可以为空
- (id)pp_first:(BOOL (^)(id _Nonnull))block {
    if (!block) { return nil; }
    
    for (id object in self) {
        if (block(object)) {
            return object;
        }
    }
    return nil;
}


@dynamic firstIndexBlock;
/// 点语法找到第一个符合条件的元素的下标, 如果不存在, 则返回-1
- (NSInteger (^)(BOOL (^ _Nonnull)(id _Nonnull)))firstIndexBlock {
    return ^NSInteger (BOOL(^block)(id element)) {
        return [self pp_firstIndex:block];
    };
}
/// 找到符合条件的元素的下标, 如果不存在, 则返回-1
- (NSInteger)pp_firstIndex:(BOOL (^)(id _Nonnull))block {
    if (!block) { return -1; }
    
    NSInteger count = self.count;
    for (NSInteger index = 0; index < count; index ++) {
        id object = [self objectAtIndex:index];
        if (block(object)) {
            return index;
        }
    }
    return -1;
}


@dynamic enumerationBlock;
/// 点语法一键枚举, for循环, index
- (void (^)(void (^ _Nonnull)(id _Nonnull, NSInteger, NSInteger)))enumerationBlock {
    return ^void (void(^block)(id element, NSInteger index, NSInteger count)) {
        [self pp_enumeration:block];
    };
}
/// 一键枚举, for循环, index
- (void)pp_enumeration:(void (^)(id _Nonnull, NSInteger, NSInteger))block {
    if (!block) { return; }
    
    NSInteger count = self.count;
    for (NSInteger index = 0; index < count; index ++) {
        id object = [self objectAtIndex:index];
        block(object, index, count);
    }
}

@end

@implementation NSMutableArray (ppEx)

@dynamic removeBlock;
/// 点语法可变数组移除符合条件的元素
- (void (^)(BOOL (^ _Nonnull)(id _Nonnull)))removeBlock {
    return ^void (BOOL(^block)(id element)) {
        [self pp_remove:block];
    };
}
/// 可变数组移除符合条件的元素
- (void)pp_remove:(BOOL (^)(id _Nonnull))block {
    if (!block) { return; }
    
    NSInteger count = self.count;
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSInteger index = 0; index < count; index ++) {
        id object = [self objectAtIndex:index];
        if (block(object)) {
            [indexSet addIndex:index];
        }
    }
    [self removeObjectsAtIndexes:indexSet];
}

@end
