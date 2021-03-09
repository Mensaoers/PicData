//
//  PicContentModel.h
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN



@interface PicContentModel : PicBaseModel///<JKSqliteProtocol>

@property (nonatomic, strong) NSString *sourceTitle;
@property (nonatomic, strong) NSString *thumbnailUrl;
@property (nonatomic, strong) NSString *href;

/// 该任务下一共有多少图片
@property (nonatomic, assign) int totalCount;
/// 已下载多少张, 这个属性忽略, 不存数据库
@property (nonatomic, assign) int downloadedCount;

+ (NSArray *)queryTableWithHref:(NSString *)href;

@end

/// 已添加下载的任务
@interface PicContentTaskModel : PicContentModel

/// 利用已有的contentModel初始化一个子类对象
+ (instancetype)taskModelWithContentModel:(PicContentModel *)contentModel;

/// 表示该任务是否已经开始进行(不表示全部下载完成)
@property (nonatomic, assign) int status;
/// 获取是否已添加任务
+ (NSArray *)queryTableWhereHasAddedWithHref:(NSString *)href;

/// 删除已添加任务, 根据父级title
+ (BOOL)deleteFromTableWithSourceTitle:(NSString *)sourceTitle;
/// 取消已添加任务, 根据title
+ (BOOL)deleteFromTableWithTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
