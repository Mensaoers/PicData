//
//  PicBaseModel.m
//  PicData
//
//  Created by CleverPeng on 2020/8/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "PicBaseModel.h"

@implementation PicBaseModel

- (NSString *)identifier {
    if (nil == _identifier || _identifier.length == 0) {
        _identifier = [self createUUID];
    }
    return _identifier;
}

- (NSString *)createUUID {
    NSString * result;
    CFUUIDRef uuid;
    CFStringRef uuidStr;
    uuid = CFUUIDCreate(NULL);
    uuidStr = CFUUIDCreateString(NULL, uuid);
    result =[NSString stringWithFormat:@"%@", uuidStr];
    CFRelease(uuidStr);
    CFRelease(uuid);
    return result;
}

//- (BOOL)insertTable:(Class)clsPre {
//    Class cls = clsPre == nil ? [self class] : clsPre;
//    return [[JQFMDB shareDatabase] jq_insertTable:NSStringFromClass(cls) dicOrModel:self];
//}
//+ (NSArray *)queryTable:(Class)clsPre Where:(NSString *)where {
//    Class cls = clsPre == nil ? [self class] : clsPre;
//    return [[JQFMDB shareDatabase] jq_lookupTable:NSStringFromClass(cls) dicOrModel:cls whereFormat:where];
//}
//+ (NSArray *)queryTable:(Class)clsPre WithTitle:(nonnull NSString *)title {
//    return [self queryTable:clsPre Where:[NSString stringWithFormat:@"where title = \"%@\"", title]];
//}
//+ (int)queryCount:(Class)clsPre Where:(NSString *)where {
//    Class cls = clsPre == nil ? [self class] : clsPre;
//    return [[JQFMDB shareDatabase] jq_totalCount:NSStringFromClass(cls) whereFormat:where];
//}
//
//- (BOOL)deleteFromTable:(Class)clsPre {
//    return YES;
//}
//+ (BOOL)deleteFromTable:(Class)clsPre Where:(NSString *)where {
//    Class cls = clsPre == nil ? [self class] : clsPre;
//    return [[JQFMDB shareDatabase] jq_deleteTable:NSStringFromClass(cls) whereFormat:where];
//}
//+ (BOOL)deleteFromTable_All:(Class)clsPre {
//    Class cls = clsPre == nil ? [self class] : clsPre;
//    return [[JQFMDB shareDatabase] jq_deleteAllDataFromTable:NSStringFromClass(cls)];
//}
//+ (BOOL)updateTable:(Class)clsPre WithDicOrModel:(id)parameters Where:(NSString *)where {
//    Class cls = clsPre == nil ? [self class] : clsPre;
//    return [[JQFMDB shareDatabase] jq_updateTable:NSStringFromClass(cls) dicOrModel:parameters whereFormat:where];
//}
//- (BOOL)updateTable:(Class)clsPre Where:(NSString *)where {
//    Class cls = clsPre == nil ? [self class] : clsPre;
//    return [[JQFMDB shareDatabase] jq_updateTable:NSStringFromClass(cls) dicOrModel:self whereFormat:where];
//}
//- (BOOL)updateTable:(Class)clsPre {
//    return true;
//}

- (BOOL)insertTable {
    Class cls = [self class];
    return [[JQFMDB shareDatabase] jq_insertTable:NSStringFromClass(cls) dicOrModel:self];
}
+ (NSArray *)queryAll {
    return [self queryTableWhere:@""];
}
+ (NSArray *)queryTableWhere:(NSString *)where {
    Class cls = [self class];
    return [[JQFMDB shareDatabase] jq_lookupTable:NSStringFromClass(cls) dicOrModel:cls whereFormat:where];
}
+ (NSArray *)queryTableWithTitle:(NSString *)title {
    return [self queryTableWhere:[NSString stringWithFormat:@"where title = \"%@\"", title]];
}
+ (int)queryCountWhere:(NSString *)where {
    Class cls = [self class];
    return [[JQFMDB shareDatabase] jq_totalCount:NSStringFromClass(cls) whereFormat:where];
}

- (BOOL)deleteFromTable {
    return YES;
}
+ (BOOL)deleteFromTable_Where:(NSString *)where {
    Class cls = [self class];
    return [[JQFMDB shareDatabase] jq_deleteTable:NSStringFromClass(cls) whereFormat:where];
}
+ (BOOL)deleteFromTable_All {
    Class cls = [self class];
    return [[JQFMDB shareDatabase] jq_deleteAllDataFromTable:NSStringFromClass(cls)];
}
+ (BOOL)updateTableWithDicOrModel:(id)parameters Where:(NSString *)where {
    Class cls = [self class];
    return [[JQFMDB shareDatabase] jq_updateTable:NSStringFromClass(cls) dicOrModel:parameters whereFormat:where];
}
- (BOOL)updateTableWhere:(NSString *)where {
    Class cls = [self class];
    [[JQFMDB shareDatabase] jq_inDatabase:^{
        [[JQFMDB shareDatabase] jq_updateTable:NSStringFromClass(cls) dicOrModel:self whereFormat:where];
    }];
    return YES;
//    return [[JQFMDB shareDatabase] jq_updateTable:NSStringFromClass(cls) dicOrModel:self whereFormat:where];
}
- (BOOL)updateTable {
    return true;
}
@end
