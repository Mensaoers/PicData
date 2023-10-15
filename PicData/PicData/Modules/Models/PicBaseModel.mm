//
//  PicBaseModel.m
//  PicData
//
//  Created by CleverPeng on 2020/8/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "PicBaseModel+WCTTableCoding.h"

@implementation PicBaseModel

+ (NSString *)tableName {
    return NSStringFromClass(self);
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _systemTitle = [_title stringByReplacingOccurrencesOfString:@"/" withString:@":"];
}

- (BOOL)insertTable {
//    return [[DatabaseManager getDatabase] insertOrReplaceObject:self into:[self.class tableName]];
    return [[DatabaseManager getDatabase] insertObject:self into:[self.class tableName]];
}
+ (NSArray *)queryAll {
    return [[DatabaseManager getDatabase] getAllObjectsOfClass:self fromTable:[self tableName]];
}
+ (NSArray *)queryTableWithTitle:(NSString *)title {
    return [[DatabaseManager getDatabase] getObjectsOfClass:self fromTable:[self tableName] where:self.title == title];
}

- (BOOL)deleteFromTable {
    return [self.class deleteFromTableWithTitle:self.title];
}
+ (BOOL)deleteFromTableWithTitle:(NSString *)title {
    return [[DatabaseManager getDatabase] deleteObjectsFromTable:[self tableName] where:self.title == title];
}
+ (BOOL)deleteFromTable_All {
    return [[DatabaseManager getDatabase] deleteAllObjectsFromTable:[self tableName]];
}
- (BOOL)updateTable {
    return [[DatabaseManager getDatabase] updateRowsInTable:[self.class tableName] onProperties:[self.class AllProperties] withObject:self where:self.class.title == self.title];
}
@end
