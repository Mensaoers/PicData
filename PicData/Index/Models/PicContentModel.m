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
@end
