//
//  PicProgressModel.m
//  PicData
//
//  Created by 鹏鹏 on 2022/5/5.
//  Copyright © 2022 garenge. All rights reserved.
//

#import "PicProgressModel.h"

@implementation PicProgressModel

// TODO: 本地文件列表应该是对应任务列表 需要思考一下

- (NSMutableArray *)taskModels {
    if (nil == _taskModels) {
        _taskModels = [NSMutableArray array];
    }
    return _taskModels;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@%ld条", self.title, self.taskModels.count];
}

- (instancetype)initWithTitle:(NSString *)title {
    if (self = [super init]) {
        self.title = title;
        self.expand = YES;
    }
    return self;
}

+ (instancetype)ModelWithTitle:(NSString *)title {
    return [[PicProgressModel alloc] initWithTitle:title];
}

@end
