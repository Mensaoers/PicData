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
#define NotificationNameCompleteScaneTaskNewPage @"NotificationNameCompleteScaneTaskNewPage"

/// 刷新套图记录
#define NotificationNameRefreshDownloadTaskStatus @"NotificationNameRefreshDownloadTaskStatus"

/// 新增某个套图
#define NotificationNameAddNewTask @"NotificationNameAddNewTask"
/// 某个套图开始扫描
#define NotificationNameStartScaneTask @"NotificationNameStartScaneTask"
/// 某个套图扫描完成
#define NotificationNameCompleteScaneTask @"NotificationNameCompleteScaneTask"
/// 某个套图下载完成
#define NotificationNameCompleteDownTask @"NotificationNameCompleteDownTask"
/// 某个套图下载失败
#define NotificationNameFailedDownTask @"NotificationNameFailedDownTask"
/// 某个套图取消下载
#define NotificationNameCancelDownTasks @"NotificationNameCancelDownTasks"

/// 某个套图某张图下载成功
#define NotificationNameCompleteDownPicture @"NotificationNameCompleteDownPicture"
/// 某个套图某张图下载失败
#define NotificationNameFailedDownPicture @"NotificationNameFailedDownPicture"

@interface ContentParserManager : NSObject

singleton_interface(ContentParserManager)

+ (void)cancelAll;
/// 取消某个任务(根据任务的href)
- (void)cancelDownloadsByIdentifiers:(NSArray <NSString *>*)identifiers;

/// 尝试下载某一个套图, 做出基本判断,
+ (void)tryToAddTaskWithSourceModel:(PicSourceModel *)sourceModel ContentModel:(PicContentModel *)contentModel operationTips:(void(^ __nonnull)(BOOL isSuccess, NSString *tips))operationTips;

/// 处理html标签, 创建下载图片任务开始下载
/// - Parameters:
///   - htmlString: 该网页的源文件
///   - referer: 该网上的图都引用自该地址, 即该网页地址
///   - nextUrl: 下一页图的地址
///   - sourceModel: App内部分类模型
///   - contentTaskModel: 当前下载任务
///   - picCount: 该页共多少张图
+ (NSDictionary *)dealWithHtmlData:(NSString *)htmlString referer: (NSString *)referer nextUrl:(NSString *)nextUrl WithSourceModel:(PicSourceModel *)sourceModel ContentTaskModel:(PicContentTaskModel *)contentTaskModel picCount:(int)picCount;

/// app启动的时候, 将所有1的任务取出来开始进行
+ (void)prepareForAppLaunch;
/// 查询接下来要开始的任务
+ (void)prepareToDoNextTask;
/// 查询接下来要开始的任务(强制添加)
+ (void)prepareToDoNextTask:(BOOL)force;

@end

NS_ASSUME_NONNULL_END
