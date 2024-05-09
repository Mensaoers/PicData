//
//  PPFileManager.h
//  PicData
//
//  Created by 鹏鹏 on 2021/10/12.
//  Copyright © 2021 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PPFileManager : NSFileManager

/// 判断是否是文件夹
+ (BOOL)isDirectory:(NSString *)filePath;
/// 根据目标路径, 拼接基于document目录的完整路径
+ (NSString *)getDocumentPathWithTarget:(NSString *)targetPath;

/// 判断文件路径是否存在, 如果不存在, 则创建
+ (BOOL)checkFolderPathExistOrCreate:(NSString *)folderPath;

/// 图片格式数组默认["jpg", "jpeg", "png"]
+ (NSArray <NSString *>*)picturePathExtensions;
/// 根据文件格式判断文件是不是图片, 根据 + picturePathExtensions
+ (BOOL)isFileTypePicture:(NSString *)fileExtension;
/// 文档格式数组默认@["txt", "md", "html", "doc"]
+ (NSArray <NSString *>*)documentPathExtensions;
/// 根据文件格式判断文件是不是文档, 根据 + documentPathExtensions
+ (BOOL)isFileTypeDocument:(NSString *)fileExtension;
/// 根据项目需要判断是不是文档和图片
+ (BOOL)isFileTypeDocAndPic:(NSString *)fileExtension;

+ (NSString *)getResourceBundleName;
+ (NSBundle *)getResourceBundle;
+ (NSBundle *)getBundleForResource:(nullable NSString *)name ofType:(nullable NSString *)ext;
@end

NS_ASSUME_NONNULL_END
