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
WCDB_SYNTHESIZE(PicContentModel, sourceTitle)
WCDB_SYNTHESIZE(PicContentModel, thumbnailUrl)
WCDB_SYNTHESIZE(PicContentModel, href)
WCDB_SYNTHESIZE(PicContentModel, totalCount)
WCDB_SYNTHESIZE(PicContentModel, downloadedCount)

WCDB_PRIMARY(PicContentModel, href)

WCDB_INDEX(PicContentModel, "_index", href)

- (BOOL)updateTable {
    return [self updateTableWithHref:self.href];
}

- (BOOL)updateTableWithHref:(NSString *)href {
    return [[DatabaseManager getDatabase] updateRowsInTable:[self.class tableName] onProperties:[self.class AllProperties] withObject:self where:self.class.href == self.href];
}

+ (NSArray *)queryTableWithHref:(NSString *)href {
    return [[DatabaseManager getDatabase] getObjectsOfClass:self fromTable:[self tableName] where:self.href == href];
}

+ (BOOL)updateTableWithSourceTitle:(NSString *)sourceTitle WhenTitle:(NSString *)title {
    if (sourceTitle.length == 0) {
        return YES;
    }
    return [[DatabaseManager getDatabase] updateRowsInTable:[self tableName] onProperty:self.sourceTitle withValue:sourceTitle where:self.title == title];
}

@end

@implementation PicContentTaskModel

WCDB_IMPLEMENTATION(PicContentTaskModel)
WCDB_SYNTHESIZE(PicContentTaskModel, title)
WCDB_SYNTHESIZE(PicContentTaskModel, systemTitle)
WCDB_SYNTHESIZE(PicContentTaskModel, HOST_URL)
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

/// 初始化所有任务
+ (BOOL)resetHalfWorkingTasks {
    [[DatabaseManager getDatabase] updateRowsInTable:[self tableName] onProperty:self.status withValue:@3 where:self.downloadedCount > 0 && self.downloadedCount == self.totalCount];
    return [[DatabaseManager getDatabase] updateRowsInTable:[self tableName] onProperty:self.status withValue:@0 where:self.downloadedCount >= 0 && self.status != 3];
}

+ (BOOL)deleteFromTableWithSourceTitle:(NSString *)sourceTitle {
    return [[DatabaseManager getDatabase] deleteObjectsFromTable:[self tableName] where:self.sourceTitle == sourceTitle];
}

+ (BOOL)deleteFromTableWithTitle:(NSString *)title {
    return [[DatabaseManager getDatabase] deleteObjectsFromTable:[self tableName] where:self.title == title];
}

@end