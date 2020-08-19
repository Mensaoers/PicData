//
//  PicRuleModel.h
//  PicViewDemo
//
//  Created by CleverPeng on 2020/5/29.
//  Copyright © 2020 CleverPeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PicRuleStepModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PicRuleModel : PicBaseModel<JKSqliteProtocol>

/** 规则步骤, 数组 */
@property (nonatomic, strong) NSArray<PicRuleStepModel *> *rulerSteps;
/** 默认规则, 补充项 */
+ (instancetype)defaultRule;

@end

NS_ASSUME_NONNULL_END
