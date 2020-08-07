//
//  PicClassModel.m
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "PicClassModel.h"

@implementation PicClassModel

+ (instancetype)modelWithTitle:(NSString *)title sourceType:(NSString *)sourceType subTitles:(NSArray *)subTitles {
    PicClassModel *classModel = [[PicClassModel alloc] init];
    classModel.title = title;
    classModel.sourceType = sourceType;
    classModel.subTitles = subTitles;
    return classModel;
}

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"subTitles" : [PicSourceModel class]};
}

@end
