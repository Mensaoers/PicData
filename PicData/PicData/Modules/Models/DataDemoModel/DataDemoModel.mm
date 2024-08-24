//
//  DataDemoModel.m
//  PicData
//
//  Created by Garenge on 2024/8/16.
//  Copyright © 2024 garenge. All rights reserved.
//

#import "DataDemoModel+WCTTableCoding.h"

@implementation DataDemoModel

WCDB_IMPLEMENTATION(DataDemoModel)
WCDB_SYNTHESIZE(DataDemoModel, name)

+ (NSString *)tableName {
    return @"Model";
}

+ (NSArray *)queryAllModelsWithDBUrl:(NSString *)dbUrl {
    WCTDatabase *getDatabase = [[WCTDatabase alloc] initWithPath:dbUrl];
    return [getDatabase getAllObjectsOfClass:self fromTable:[self tableName]];
}

+ (DataDemoModel *)queryModelsWithDBUrl:(NSString *)dbUrl andTitle:(NSString *)title {
    WCTDatabase *getDatabase = [[WCTDatabase alloc] initWithPath:dbUrl];
    return [getDatabase getObjectsOfClass:self fromTable:[self tableName] where:self.name == title limit:1].firstObject;
}

@end
