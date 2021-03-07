//
//  ViewerFileModel.m
//  PicData
//
//  Created by 鹏鹏 on 2020/11/5.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "ViewerFileModel.h"

@implementation ViewerFileModel

- (instancetype)initWithName:(NSString *)fileName isFolder:(BOOL)isFolder {
    if (self = [super init]) {
        self.fileName = fileName;
        self.isFolder = isFolder;
        self.fileCount = 0;
        self.fileSize = 0;
    }
    return self;
}

+ (instancetype)modelWithName:(NSString *)fileName isFolder:(BOOL)isFolder {
    return [[ViewerFileModel alloc] initWithName:fileName isFolder:isFolder];
}
@end
