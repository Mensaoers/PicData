//
//  ContentParserManager.h
//  PicData
//
//  Created by Garenge on 2020/4/20.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "PicContentModel.h"
#import "PicSourceModel.h"
#import "PicRuleModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 某个套图新增任务
#define NOTICECHEADDNEWDETAILTASK @"NOTICECHEADDNEWDETAILTASK"
/// 新增某个套图
#define NOTICECHEADDNEWTASK @"NOTICECHEADDNEWTASK"

@interface ContentParserManager : NSObject

singleton_interface(ContentParserManager)

+ (void)cancelAll;

/// 尝试下载某一个套图, 做出基本判断,
+ (void)tryToAddTaskWithSourceModel:(PicSourceModel *)sourceModel ContentModel:(PicContentModel *)contentModel operationTips:(void(^ __nonnull)(BOOL isSuccess, NSString *tips))operationTips;

/// app启动的时候, 将所有1的任务取出来开始进行
+ (void)prepareForAppLaunch;
/// 查询接下来要开始的任务
+ (void)prepareToDoNextTask;

@end

NS_ASSUME_NONNULL_END
