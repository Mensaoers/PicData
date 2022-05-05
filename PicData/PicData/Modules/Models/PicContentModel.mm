//
//  PicContentModel.m
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "PicContentModel+WCTTableCoding.h"

@implementation PicContentModel

WCDB_IMPLEMENTATION(PicContentModel)
WCDB_SYNTHESIZE(PicContentModel, title)
WCDB_SYNTHESIZE(PicContentModel, systemTitle)
WCDB_SYNTHESIZE(PicContentModel, HOST_URL)
WCDB_SYNTHESIZE(PicContentModel, sourceHref)
WCDB_SYNTHESIZE(PicContentModel, sourceTitle)
WCDB_SYNTHESIZE(PicContentModel, thumbnailUrl)
WCDB_SYNTHESIZE(PicContentModel, href)
WCDB_SYNTHESIZE(PicContentModel, totalCount)
WCDB_SYNTHESIZE(PicContentModel, downloadedCount)

WCDB_PRIMARY(PicContentModel, href)

WCDB_INDEX(PicContentModel, "_index", href)

- (BOOL)updateTable {
    return [self updateTableWhenHref:self.href];
}

- (BOOL)updateTableWhenHref:(NSString *)href {
    return [[DatabaseManager getDatabase] updateRowsInTable:[self.class tableName] onProperties:[self.class AllProperties] withObject:self where:self.class.href == self.href];
}

+ (NSArray *)queryTableWithHref:(NSString *)href {
    return [[DatabaseManager getDatabase] getObjectsOfClass:self fromTable:[self tableName] where:self.href == href];
}

@end

@implementation PicContentTaskModel

WCDB_IMPLEMENTATION(PicContentTaskModel)
WCDB_SYNTHESIZE(PicContentTaskModel, title)
WCDB_SYNTHESIZE(PicContentTaskModel, systemTitle)
WCDB_SYNTHESIZE(PicContentTaskModel, HOST_URL)
WCDB_SYNTHESIZE(PicContentTaskModel, sourceHref)
WCDB_SYNTHESIZE(PicContentTaskModel, sourceTitle)
WCDB_SYNTHESIZE(PicContentTaskModel, thumbnailUrl)
WCDB_SYNTHESIZE(PicContentTaskModel, href)
WCDB_SYNTHESIZE(PicContentTaskModel, totalCount)
WCDB_SYNTHESIZE(PicContentTaskModel, downloadedCount)
WCDB_SYNTHESIZE(PicContentTaskModel, status)

WCDB_PRIMARY(PicContentTaskModel, href)

WCDB_INDEX(PicContentTaskModel, "_index", href)

/// 利用已有的contentModel初始化一个子类对象
+ (instancetype)taskModelWithContentModel:(PicContentModel *)contentModel {
    NSMutableDictionary *keyValues = [contentModel mj_keyValues];
    PicContentTaskModel *taskModel = [PicContentTaskModel mj_objectWithKeyValues:keyValues];
    taskModel.status = 0;
    return taskModel;
}

/// 获取下一个任务
+ (NSArray *)queryNextTask {
    return [[DatabaseManager getDatabase] getObjectsOfClass:self fromTable:[self tableName] where:self.status == 0 orderBy:self.href.order(WCTOrderedAscending) limit:1];
}
/// 获取所有task status为0的任务数
+ (NSInteger)queryCountForTaskStatus:(int)status {
    return [[[DatabaseManager getDatabase] getOneValueOnResult:self.AnyProperty.count() fromTable:[self tableName] where:self.status == status] integerValue];
}

/// 获取所有tasks status为给定值的任务
+ (NSArray <PicContentTaskModel *>*)queryTasksForStatus:(int)status {
    return [[DatabaseManager getDatabase] getObjectsOfClass:self fromTable:[self tableName] where:self.status == status];
}

/// 获取所有task status为给定值的任务数
+ (NSInteger)queryCountForTaskInStatus12 {
    return [[[DatabaseManager getDatabase] getOneValueOnResult:self.AnyProperty.count() fromTable:[self tableName] where:self.status == 1 || self.status == 2] integerValue];
}

- (BOOL)updateTableWithStatus {
    return [[DatabaseManager getDatabase] updateRowsInTable:[self.class tableName] onProperties:self.class.status withObject:self where:self.class.href == self.href];
}

/// 初始化所有任务
+ (BOOL)resetHalfWorkingTasks {
    [[DatabaseManager getDatabase] updateRowsInTable:[self tableName] onProperty:self.status withValue:@3 where:self.downloadedCount > 0 && self.downloadedCount == self.totalCount];
    // 更新多列数据
    return [[DatabaseManager getDatabase] updateRowsInTable:[self tableName] onProperties:{self.status, self.downloadedCount} withRow:@[@0, @0] where:self.downloadedCount >= 0 && self.status != 3];
}

+ (BOOL)deleteFromTableWithSourceHref:(NSString *)sourceHref {
    return [[DatabaseManager getDatabase] deleteObjectsFromTable:[self tableName] where:self.sourceHref == sourceHref];
}

+ (BOOL)deleteFromTableWithTitle:(NSString *)title {
    return [[DatabaseManager getDatabase] deleteObjectsFromTable:[self tableName] where:self.title == title];
}

@end
