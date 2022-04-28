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

@property (nonatomic, strong) NSString *sourceHref;
@property (nonatomic, strong) NSString *thumbnailUrl;
@property (nonatomic, strong) NSString *href;

/// 该任务下一共有多少图片
@property (nonatomic, assign) int totalCount;
/// 已下载多少张, 这个属性忽略, 不存数据库
@property (nonatomic, assign) int downloadedCount;

- (BOOL)updateTableWhenHref:(NSString *)href;

+ (NSArray *)queryTableWithHref:(NSString *)href;

@end

/// 已添加下载的任务
@interface PicContentTaskModel : PicContentModel

/// 利用已有的contentModel初始化一个子类对象
+ (instancetype)taskModelWithContentModel:(PicContentModel *)contentModel;

/// 表示该任务是否已经开始进行(不表示全部下载完成) 0尚未开始, 1开始遍历, 2完成遍历, 3下载完成
@property (nonatomic, assign) int status;

/// 获取下一个没有开始的任务
+ (NSArray *)queryNextTask;
/// 获取所有task status为给定值的任务数
+ (NSInteger)queryCountForTaskStatus:(int)status;
/// 获取所有task status为给定值的任务数
+ (NSInteger)queryCountForTaskInStatus12;

- (BOOL)updateTableWithStatus;

/// 初始化所有任务
+ (BOOL)resetHalfWorkingTasks;

/// 删除已添加任务, 根据父级title
+ (BOOL)deleteFromTableWithSourceHref:(NSString *)sourceHref;
/// 取消已添加任务, 根据title
+ (BOOL)deleteFromTableWithTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
