//
//  Manager.m
//  ReName
//
//  Created by 鹏鹏 on 2021/6/12.
//

#import "Manager.h"

@implementation Manager

/// 一键重命名各个图片
+ (void)renameAllPicturesOfDirectoryAtPath:(NSString *)dirPath {

    NSFileManager *fileManager = [NSFileManager defaultManager];

    // 列举所有文件
    NSError *subError = nil;
    NSArray *targetPathExtension = @[@"jpg", @"jpeg", @"png"];
    NSArray *fileContents = [fileManager contentsOfDirectoryAtPath:dirPath error:&subError];
    if (subError) {
        return;
    }
    for (NSString *fileName in fileContents) {

        NSString *filePath = [dirPath stringByAppendingPathComponent:fileName];
        if ([self isDirectory:filePath]) {
            // 这是个文件夹
            [self renameAllPicturesOfDirectoryAtPath:filePath];
            continue;
        }

        // 如果这个文件是含有"-"的图片, 我们就来改一下文件名
        if ([targetPathExtension containsObject:fileName.pathExtension.lowercaseString] && [fileName containsString:@"-"]) {

            NSRange range = [fileName rangeOfString:@"-"];
            NSString *fileNameAfter = [fileName substringFromIndex:range.location + range.length];

            if ([fileManager fileExistsAtPath:[dirPath stringByAppendingPathComponent:fileNameAfter]]) {
                NSLog(@"目标文件%@已存在", fileNameAfter);
                [fileManager removeItemAtPath:filePath error:nil];
                continue;
            }


            NSString *afterPath = [dirPath stringByAppendingPathComponent:fileNameAfter];

            NSError *copyError = nil;
            [fileManager moveItemAtPath:filePath toPath:afterPath error:&copyError];
            if (copyError) {
                NSLog(@"移动文件夹下%@失败", fileName);
                continue;
            }
        }
    }

}

+ (BOOL)isDirectory:(NSString *)filePath {
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    return isDirectory;
}

+ (void)removeAllTxtFileOfDirectoryAtPath:(NSString *)dirPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // 列举所有文件
    NSError *subError = nil;
    NSArray *targetPathExtension = @[@"txt"];
    NSArray *fileContents = [fileManager contentsOfDirectoryAtPath:dirPath error:&subError];
    if (subError) {
        return;
    }
    for (NSString *fileName in fileContents) {

        NSString *filePath = [dirPath stringByAppendingPathComponent:fileName];
        if ([self isDirectory:filePath]) {
            // 这是个文件夹
            [self removeAllTxtFileOfDirectoryAtPath:filePath];
            continue;
        }

        // 如果这个文件是txt, 删除
        if ([targetPathExtension containsObject:fileName.pathExtension.lowercaseString]) {
            NSLog(@"%@", filePath);
            NSError *rmError = nil;
            [fileManager removeItemAtPath:filePath error:&rmError];
        }
    }
}
@end
