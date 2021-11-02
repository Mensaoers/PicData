//
//  PicClassModel.m
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "PicClassModel.h"

@implementation PicClassModel

+ (instancetype)modelWithHOST_URL:(NSString *)HOST_URL Title:(NSString *)title sourceType:(NSString *)sourceType subTitles:(nullable NSArray<PicSourceModel *> *)subTitles {
    PicClassModel *classModel = [[PicClassModel alloc] init];
    classModel.title = title;
    classModel.HOST_URL = HOST_URL;
    classModel.sourceType = sourceType;
    classModel.subTitles = subTitles;
    return classModel;
}

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"subTitles" : [PicSourceModel class]};
}

- (NSArray<NSString *> *)subTitleStrings {
    NSArray *titleStrings = [self.subTitles valueForKeyPath:@"title"];
    // NSArray *titleStrings = [self valueForKeyPath:@"subTitles.title"];
    return titleStrings;
}

@end
