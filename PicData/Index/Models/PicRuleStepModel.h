//
//  PicRuleStepModel.h
//  PicViewDemo
//
//  Created by CleverPeng on 2020/5/29.
//  Copyright © 2020 CleverPeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PicElementType) {
    PicElementTypeClass, // class
    PicElementTypeAttribute, // 属性
    PicElementTypeID, // id
};

/// 某个步骤得到的结果, 倾向于某个类型, 返回一个元素的数组, 视作元素
typedef NS_ENUM(NSInteger, PicElementResultType) {
    PicElementResultTypeArray, // 该步骤得到一个数组
    PicElementResultTypeObject, // 该步骤得到一个元素
};

@interface PicRuleStepModel : PicBaseModel

/** 所属规则 */
@property (nonatomic, strong) NSString *ruleIdentifier;
/** 上一级步骤 */
@property (nonatomic, strong) NSString *followIdentifier;
/** 标签类型 */
@property (nonatomic, assign) PicElementType elementType;
/** 期望值, 返回值是数组还是模型 */
@property (nonatomic, assign) PicElementResultType resultType;

@end

NS_ASSUME_NONNULL_END
