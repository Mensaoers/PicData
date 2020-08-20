//
//  PicDownRecoreModel.m
//  PicData
//
//  Created by CleverPeng on 2020/8/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "PicDownRecoreModel.h"

@implementation PicDownRecoreModel

//+ (NSString *)primaryKey {
//    return @"url";
//}
+ (void)initialize {
    [super initialize];
    Class cls = [self class];
    [[JQFMDB shareDatabase] jq_createTable:NSStringFromClass(cls) dicOrModel:cls];
}
- (BOOL)updateTable {
    return [self updateTableWhere:[NSString stringWithFormat:@"where url = \"%@\"", self.url]];
}

@end
