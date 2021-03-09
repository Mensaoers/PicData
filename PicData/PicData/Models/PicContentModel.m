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

@end

@implementation PicContentTaskModel

/// 利用已有的contentModel初始化一个子类对象
+ (instancetype)taskModelWithContentModel:(PicContentModel *)contentModel {
    NSMutableDictionary *keyValues = [contentModel mj_keyValues];
    PicContentTaskModel *taskModel = [PicContentTaskModel mj_objectWithKeyValues:keyValues];
    taskModel.status = 0;
    return taskModel;
}

/// 获取是否已添加任务
+ (NSArray *)queryTableWhereHasAddedWithHref:(NSString *)href {
    return [self queryTableWhere:[NSString stringWithFormat:@"where href = \"%@\"", href]];
}

+ (BOOL)deleteFromTableWithSourceTitle:(NSString *)sourceTitle {
    return [self deleteFromTable_Where:[NSString stringWithFormat:@"where sourceTitle = \"%@\"", sourceTitle]];
}

+ (BOOL)deleteFromTableWithTitle:(NSString *)title {
    return [self deleteFromTable_Where:[NSString stringWithFormat:@"where title = \"%@\"", title]];
}

@end
