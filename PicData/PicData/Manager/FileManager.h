//
//  FileManager.h
//  PicData
//
//  Created by 鹏鹏 on 2021/10/12.
//  Copyright © 2021 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileManager : NSFileManager

/// 判断是否是文件夹
+ (BOOL)isDirectory:(NSString *)filePath;
/// 根据目标路径, 拼接基于document目录的完整路径
+ (NSString *)getDocumentPathWithTarget:(NSString *)targetPath;

/// 判断文件路径是否存在, 如果不存在, 则创建
+ (BOOL)checkFolderPathExistOrCreate:(NSString *)folderPath;

/// 根据文件格式判断文件是不是图片
+ (BOOL)isFileTypePicture:(NSString *)fileExtension;
/// 根据文件格式判断文件是不是文档
+ (BOOL)isFileTypeDocument:(NSString *)fileExtension;
/// 根据项目需要判断是不是文档和图片
+ (BOOL)isFileTypeDocAndPic:(NSString *)fileExtension;
@end

NS_ASSUME_NONNULL_END
