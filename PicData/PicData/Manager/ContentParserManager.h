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

/// 某个套图新增任务(新增一页)
#define NOTICECHEADDNEWDETAILTASK @"NOTICECHEADDNEWDETAILTASK"
/// 新增某个套图
#define NOTICECHEADDNEWTASK @"NOTICECHEADDNEWTASK"
/// 某个套图下载完成
#define NOTICECHECOMPLETEDOWNATASK @"NOTICECHECOMPLETEDOWNATASK"
/// 某个套图下载失败
#define NOTICECHEFAILEDDOWNATASK @"NOTICECHEFAILEDDOWNATASK"

@interface ContentParserManager : NSObject

singleton_interface(ContentParserManager)

+ (void)cancelAll;

/// 尝试下载某一个套图, 做出基本判断,
+ (void)tryToAddTaskWithSourceModel:(PicSourceModel *)sourceModel ContentModel:(PicContentModel *)contentModel operationTips:(void(^ __nonnull)(BOOL isSuccess, NSString *tips))operationTips;
/// 从数据库某条数据创建任务
//+ (void)tryToAddTaskWithContentTaskModel:(PicContentTaskModel *)contentModel operationTips:(void (^)(BOOL, NSString * _Nonnull))operationTips;
/// app启动的时候, 将所有1的任务取出来开始进行
+ (void)prepareForAppLaunch;
/// 查询接下来要开始的任务
+ (void)prepareToDoNextTask;
/// 查询接下来要开始的任务(强制添加)
+ (void)prepareToDoNextTask:(BOOL)force;

+ (NSString *)getHtmlStringWithData:(NSData *)data sourceType:(int)sourceType;

@end

NS_ASSUME_NONNULL_END
