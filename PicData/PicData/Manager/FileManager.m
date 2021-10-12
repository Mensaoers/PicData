//
//  FileManager.m
//  PicData
//
//  Created by 鹏鹏 on 2021/10/12.
//  Copyright © 2021 garenge. All rights reserved.
//

#import "FileManager.h"

@implementation FileManager

/// 判断是否是文件夹
+ (BOOL)isDirectory:(NSString *)filePath {
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    return isDirectory;
}

/// 根据目标路径, 拼接基于document目录的完整路径
+ (NSString *)getDocumentPathWithTarget:(NSString *)targetPath {
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *resultPath = targetPath.length > 0 ? [documentDir stringByAppendingPathComponent: targetPath] : documentDir;
    return resultPath;
}

/// 判断文件路径是否存在, 如果不存在, 则创建
+ (BOOL)checkFolderPathExistOrCreate:(NSString *)folderPath {
    BOOL isDir = YES;

    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:folderPath isDirectory:&isDir];

    if (!isExist) {
        NSError *createError = nil;
        BOOL result =  [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&createError];
        if (createError) {
            NSLog(@"- checkFilePathExist - 创建文件失败: %@", createError);
        }
        return result;
    }

    return isExist;
}
@end
