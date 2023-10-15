//
//  PicContentModel.h
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PicContentModel : PicBaseModel

@property (nonatomic, assign) int sourceType;
@property (nonatomic, strong) NSString *sourceHref;
@property (nonatomic, strong) NSString *sourceTitle;
@property (nonatomic, strong) NSString *thumbnailUrl;
@property (nonatomic, strong) NSString *href;

// TODO: 此处有个bug, contentModel收藏与否与taskModel收藏与否不等价(分属俩表)
// TODO: 后期专门做一个收藏表, 保存收藏信息(清空数据时需要清空收藏表)
/// 是否收藏
@property (nonatomic, assign) BOOL isFavor;

- (BOOL)updateTableWhenHref:(NSString *)href;

+ (NSArray *)queryTableWithHref:(NSString *)href;
+ (NSArray *)queryTableWithSourceHref:(NSString *)sourceHref;
+ (NSArray *)queryTableWithSourceTitle:(NSString *)sourceTitle;

@end

typedef NS_ENUM(NSInteger, ContentTaskStatus) {
    ContentTaskStatusNormal = 0,
    ContentTaskStatusStartScane = 1,
    ContentTaskStatusFinishScane = 2,
    ContentTaskStatusFinishDownload = 3,
};

/// 已添加下载的任务
@interface PicContentTaskModel : PicContentModel

/// 利用已有的contentModel初始化一个子类对象
+ (instancetype)taskModelWithContentModel:(PicContentModel *)contentModel;

/// 已下载多少张, 这个属性在重启任务时会重置
@property (nonatomic, assign) int downloadedCount;
/// 表示该任务是否已经开始进行(不表示全部下载完成) 0尚未开始, 1开始遍历, 2完成遍历, 3下载完成
/// 该任务下一共有多少图片
@property (nonatomic, assign) int totalCount;
@property (nonatomic, assign) ContentTaskStatus status;

@property (nonatomic, assign) NSTimeInterval createTime;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval endTime;

/// 获取下一个没有开始的任务
+ (NSArray *)queryNextTask;
/// 获取所有task status为给定值的任务数
+ (NSInteger)queryCountForTaskStatus:(ContentTaskStatus)status;
/// 获取所有tasks status为给定值的任务
+ (NSArray <PicContentTaskModel *>*)queryTasksForStatus:(ContentTaskStatus)status;
/// 获取所有task status为给定值的任务数
+ (NSInteger)queryCountForTaskInStatus12;

- (BOOL)updateTableWithStatus;
- (BOOL)updateTableWithStartTime;
- (BOOL)updateTableWithEndTime;

/// 初始化所有进程中任务
+ (BOOL)resetHalfWorkingTasks;
/// 初始化所有任务
+ (BOOL)resetToZeroAllTasks;

/// 删除已添加任务, 根据父级title
+ (BOOL)deleteFromTableWithSourceTitle:(NSString *)sourceTitle;
/// 删除已添加任务, 根据父级href
+ (BOOL)deleteFromTableWithSourceHref:(NSString *)sourceHref;
/// 取消已添加任务, 根据title
+ (BOOL)deleteFromTableWithTitle:(NSString *)title;
/// 取消已添加任务, 根据href
+ (BOOL)deleteFromTableWithHref:(NSString *)href;

@end

NS_ASSUME_NONNULL_END
