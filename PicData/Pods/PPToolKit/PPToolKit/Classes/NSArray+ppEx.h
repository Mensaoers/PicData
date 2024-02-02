//
//  NSArray+ppEx.h
//  Ashton
//
//  Created by pengpeng on 2023/11/16.
//  Copyright © 2023 Falcon Automation. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// TODO: 暂时有一个缺点, 调用block属性的时候, 代码提示不准确, block里面的泛型无法识别
@interface NSArray <__covariant ObjectType> (ppEx)

/// 点语法返回数组指定下标的元素, 可以为空, 不会越界
@property (nonatomic, copy, readonly) _Nullable ObjectType(^objectNullableAtIndexBlock)(NSUInteger index);
/// 返回数组指定下标的元素, 可以为空, 不会越界
- (nullable ObjectType)pp_objectNullableAtIndex:(NSUInteger)index;

/// 点语法生成新的数组, 回调返回重新生成的符合要求的对象
@property (nonatomic, copy, readonly) NSArray *(^mapBlock)(id(^paramBlock)(ObjectType element));
/// 生成新的数组, 回调返回重新生成的符合要求的对象
- (NSArray *)pp_map:(id(^)(ObjectType element))block;

/// 点语法生成新的数组, 回调 带下标 返回重新生成的符合要求的对象
@property (nonatomic, copy, readonly) NSArray *(^mapWithIndexBlock)(id(^paramBlock)(ObjectType element, NSInteger index));
/// 生成新的数组, 回调 带下标 返回重新生成的符合要求的对象
- (NSArray *)pp_mapWithIndex:(id(^)(ObjectType element, NSInteger index))block;

/// 点语法过滤符合条件的元素, 生成新的数组
@property (nonatomic, copy, readonly) NSArray <ObjectType>*(^filterBlock)(BOOL(^paramBlock)(ObjectType element));
/// 过滤符合条件的元素, 生成新的数组
- (NSArray <ObjectType>*)pp_filter:(BOOL(^)(ObjectType element))block;

/// 点语法判断是否包含满足条件的元素
@property (nonatomic, copy, readonly) BOOL(^containsBlock)(BOOL(^paramBlock)(ObjectType element));
/// 判断是否包含满足条件的元素
- (BOOL)pp_contains:(BOOL(^)(ObjectType element))block;

/// 点语法找到第一个符合条件的元素, 可以为空
@property (nonatomic, copy, readonly) ObjectType(^firstBlock)(BOOL(^paramBlock)(ObjectType element));
/// 找到第一个符合条件的元素, 可以为空
- (nullable ObjectType)pp_first:(BOOL(^)(ObjectType element))block;

/// 点语法找到第一个符合条件的元素的下标, 如果不存在, 则返回-1
@property (nonatomic, copy, readonly) NSInteger(^firstIndexBlock)(BOOL(^paramBlock)(ObjectType element));
/// 找到第一个符合条件的元素的下标, 如果不存在, 则返回-1
- (NSInteger)pp_firstIndex:(BOOL(^)(ObjectType element))block;

/// 点语法一键枚举, for循环, index
@property (nonatomic, copy) void(^enumerationBlock)(void(^paramBlock)(ObjectType element, NSInteger index, NSInteger totalCount));
/// 一键枚举, for循环, index
- (void)pp_enumeration:(void(^)(ObjectType element, NSInteger index, NSInteger totalCount))block;

@end

@interface NSMutableArray <ObjectType> (ppEx)

/// 点语法可变数组移除符合条件的元素
@property (nonatomic, copy, readonly) void(^removeBlock)(BOOL(^paramBlock)(ObjectType element));
/// 可变数组移除符合条件的元素
- (void)pp_remove:(BOOL(^)(ObjectType element))block;

@end

NS_ASSUME_NONNULL_END
