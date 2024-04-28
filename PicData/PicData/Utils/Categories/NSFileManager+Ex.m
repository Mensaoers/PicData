//
//  NSFileManager+Ex.m
//  PicData
//
//  Created by Garenge on 2024/4/28.
//  Copyright © 2024 garenge. All rights reserved.
//

#import "NSFileManager+Ex.h"

@implementation NSFileManager (Ex)

- (long long)getFileSize:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:path error:nil];
        NSNumber *fileSize;
        if ((fileSize = [attributes objectForKey:NSFileSize]))
            return [fileSize longLongValue];
        else
            return -1;
    } else {
        return -1;
    }
}

@end
