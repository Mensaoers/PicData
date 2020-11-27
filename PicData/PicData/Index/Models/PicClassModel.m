//
//  PicClassModel.m
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "PicClassModel.h"

@implementation PicClassModel

+ (instancetype)modelWithHOST_URL:(NSString *)HOST_URL Title:(NSString *)title sourceType:(NSString *)sourceType subTitles:(NSArray *)subTitles {
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

@end
