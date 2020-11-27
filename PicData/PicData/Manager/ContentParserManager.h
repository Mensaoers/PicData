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

/// 尝试下载某一个套图, 做出基本判断,
+ (void)tryToAddTaskWithSourceModel:(PicSourceModel *)sourceModel ContentModel:(PicContentModel *)contentModel needDownload:(BOOL)needDownload operationTips:(void(^ __nonnull)(BOOL isSuccess, NSString *tips))operationTips;
/// 解析对应的数据, 开始创建下载任务
+ (void)parserWithSourceModel:(PicSourceModel *)sourceModel ContentModel:(PicContentModel *)contentModel needDownload:(BOOL)needDownload;

@end

NS_ASSUME_NONNULL_END
