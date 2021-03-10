//
//  PicContentModel.m
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "PicContentModel.h"

@implementation PicContentModel

//+ (NSString *)primaryKey {
//    return @"href";
//}
//
//+ (NSArray *)ignoreColumnNames {
//    return @[@"downloadedCount"];
//}
+ (void)initialize {
    [super initialize];
    Class cls = [self class];
    [[JQFMDB shareDatabase] jq_createTable:NSStringFromClass(cls) dicOrModel:cls];
}

- (BOOL)updateTable {
    return [self updateTableWhere:[NSString stringWithFormat:@"where href = \"%@\"", self.href]];
}

- (BOOL)deleteFromTable {
    return [PicContentModel deleteFromTable_Where:[NSString stringWithFormat:@"where title = \"%@\"", self.title]];
}

+ (NSArray *)queryTableWithHref:(NSString *)href {
    return [self queryTableWhere:[NSString stringWithFormat:@"where href = \"%@\"", href]];
}

+ (BOOL)updateTableWithSourceTitle:(NSString *)sourceTitle WhenTitle:(NSString *)title {
    if (sourceTitle.length == 0) {
        return YES;
    }
    return [self updateTableWithSourceTitle:sourceTitle Where:[NSString stringWithFormat:@"where title = \"%@\"", title]];
}
+ (BOOL)updateTableWithSourceTitle:(NSString *)sourceTitle Where:(NSString *)where {
    if (sourceTitle.length == 0) {
        return YES;
    }
    return [self updateTableWithDicOrModel:@{@"sourceTitle": sourceTitle} Where:where];
}

@end

@implementation PicContentTaskModel

/// 利用已有的contentModel初始化一个子类对象
+ (instancetype)taskModelWithContentModel:(PicContentModel *)contentModel {
    NSMutableDictionary *keyValues = [contentModel mj_keyValues];
    PicContentTaskModel *taskModel = [PicContentTaskModel mj_objectWithKeyValues:keyValues];
    taskModel.status = 0;
    return taskModel;
}

/// 获取下一个任务
+ (NSArray *)queryNextTask {
    return [self queryTableWhere:[NSString stringWithFormat:@"where status = 0 order by href limit 1"]];
}

/// 初始化所有任务
+ (BOOL)resetHalfWorkingTasks {
    return [self updateTableWithStatus:0 Where:@"where status = 1"];
}
+ (BOOL)updateTableWithStatus:(int)status Where:(NSString *)where {
    return [self updateTableWithDicOrModel:@{@"status": @(status)} Where:where];
}

+ (BOOL)deleteFromTableWithSourceTitle:(NSString *)sourceTitle {
    return [self deleteFromTable_Where:[NSString stringWithFormat:@"where sourceTitle = \"%@\"", sourceTitle]];
}

+ (BOOL)deleteFromTableWithTitle:(NSString *)title {
    return [self deleteFromTable_Where:[NSString stringWithFormat:@"where title = \"%@\"", title]];
}

@end
