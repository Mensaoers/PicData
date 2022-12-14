//
//  PicSourceModel.m
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "PicSourceModel+WCTTableCoding.h"

@implementation PicSourceModel

WCDB_IMPLEMENTATION(PicSourceModel)
WCDB_SYNTHESIZE(PicSourceModel, title)
WCDB_SYNTHESIZE(PicSourceModel, systemTitle)
WCDB_SYNTHESIZE(PicSourceModel, HOST_URL)
WCDB_SYNTHESIZE(PicSourceModel, url)
WCDB_SYNTHESIZE(PicSourceModel, sourceType)

WCDB_PRIMARY(PicSourceModel, url)

WCDB_INDEX(PicSourceModel, "_index", url)

- (id)copy {
    PicSourceModel *sourceModel = [PicSourceModel mj_objectWithKeyValues:[self mj_keyValues]];
    return sourceModel;
}

+ (NSArray *)queryTableWithUrl:(NSString *)url {
    return [[DatabaseManager getDatabase] getObjectsOfClass:self fromTable:[self tableName] where:self.url == url];
}

@end
