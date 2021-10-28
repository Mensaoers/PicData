//
//  Manager.m
//  ReName
//
//  Created by 鹏鹏 on 2021/6/12.
//

#import "Manager.h"

@implementation Manager

/// 一键重命名各个图片
+ (void)renameAllPicturesOfDirectoryAtPath:(NSString *)dirPath andTxtFileRemove:(BOOL)together {

    NSFileManager *fileManager = [NSFileManager defaultManager];

    // 列举所有文件
    NSError *subError = nil;
    NSArray *picExtensions = @[@"jpg", @"jpeg", @"png"];
    NSArray *txtExtensions = @[@"txt"];

    NSLog(@"当前正在遍历文件夹: %@", dirPath);

    // 获取所有子文件数组
    NSArray *fileContents = [fileManager contentsOfDirectoryAtPath:dirPath error:&subError];
    if (subError) {

        NSLog(@"获取路径下所有文件失败: %@, error: %@", dirPath, subError);
        return;
    }

    for (NSString *fileName in fileContents) {

        NSString *filePath = [dirPath stringByAppendingPathComponent:fileName];

        if ([self isDirectory:filePath]) {
            // 这是个文件夹
            NSLog(@"当前文件: %@是一个文件夹", filePath);
            [self renameAllPicturesOfDirectoryAtPath:filePath andTxtFileRemove:together];
            continue;
        }

        // 如果这个文件是含有"-"的图片, 我们就来改一下文件名
        if ([picExtensions containsObject:fileName.pathExtension.lowercaseString] && [fileName containsString:@"-"]) {
            NSLog(@"当前判断文件: %@", filePath);
            NSLog(@"图片需要重命名");
            NSRange range = [fileName rangeOfString:@"-"];
            NSString *fileNameAfter = [fileName substringFromIndex:range.location + range.length];

            if ([fileManager fileExistsAtPath:[dirPath stringByAppendingPathComponent:fileNameAfter]]) {
                NSLog(@"目标文件%@已存在", fileNameAfter);
                [fileManager removeItemAtPath:filePath error:nil];
                NSLog(@"图片已删除");
                continue;
            }

            NSString *afterPath = [dirPath stringByAppendingPathComponent:fileNameAfter];

            NSError *mvError = nil;
            [fileManager moveItemAtPath:filePath toPath:afterPath error:&mvError];
            if (mvError) {
                NSLog(@"重命名失败, error: %@", mvError);
                continue;
            } else {
                NSLog(@"重命名成功, 修改后图片路径: %@", afterPath);
            }
        } else if (together && [txtExtensions containsObject:fileName.pathExtension.lowercaseString]) {
            // 如果这个文件是txt, 删除
            NSLog(@"当前判断文件: %@", filePath);
            NSLog(@"文档需要删除");
            NSError *rmError = nil;
            [fileManager removeItemAtPath:filePath error:&rmError];
            if (rmError) {
                NSLog(@"删除失败: error: %@", rmError);
            } else {
                NSLog(@"删除成功");
            }
        }
    }

}

+ (BOOL)isDirectory:(NSString *)filePath {
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    return isDirectory;
}

@end
