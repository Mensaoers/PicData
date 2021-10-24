//
//  PicSourceModel.m
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "PicSourceModel.h"

@implementation PicSourceModel

//+ (NSString *)primaryKey {
//    return @"title";
//}

+ (void)initialize {
    [super initialize];
    Class cls = [self class];
    [[JQFMDB shareDatabase] jq_createTable:NSStringFromClass(cls) dicOrModel:cls];
}

- (BOOL)deleteFromTable {
    [PicContentModel deleteFromTable_Where:[NSString stringWithFormat:@"where sourceTitle = \"%@\"", self.title]];
    return [PicSourceModel deleteFromTable_Where:[NSString stringWithFormat:@"where title = \"%@\"", self.title]];
}

- (id)copy {
    PicSourceModel *sourceModel = [PicSourceModel mj_objectWithKeyValues:[self mj_keyValues]];
    return sourceModel;
}

@end
