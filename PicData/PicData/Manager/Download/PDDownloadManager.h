//
//  PDDownloadManager.h
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PicSourceModel.h"
#import "PicContentModel.h"
#import "AppDelegate.h"

#define DOWNLOADSPATHKEY @"DOWNLOADSPATHKEY"
#define NOTICECHECKDOWNLOADPATHKEY @"NOTICECHECKDOWNLOADPATHKEY"
#define NOTICEPICDOWNLOADSUCCESS @"NOTICEPICDOWNLOADSUCCESS"

NS_ASSUME_NONNULL_BEGIN

@interface PDDownloadManager : NSObject

singleton_interface(PDDownloadManager);

/// 重置当前下载相对地址
- (BOOL)resetDownloadPath;
/// 获取默认下载相对地址
- (nonnull NSString *)defaultDownloadPath;
/// 获取系统下载相对地址
- (nonnull NSString *)systemDownloadPath;
/// 获取当前系统的完整下载地址
- (nonnull NSString *)systemDownloadFullPath;
/// 获取当前系统的文件夹名
- (nonnull NSString *)systemDownloadFullDirectory;
/// 获取当前系统收藏文件夹路径
- (nonnull NSString *)systemFavoriteFolderPath;
/// 获取当前系统收藏文件夹名称
- (nonnull NSString *)systemFavoriteFolderName;
/// 数据库文件名
@property (nonatomic, strong) NSString *databaseFileName;
/// 数据库文件路径
@property (nonatomic, strong) NSString *databaseFilePath;
/// 配置数据库
+ (void)prepareDatabase;
/// 删除数据库
+ (BOOL)deleteDatabase;

+ (BOOL)clearAllData:(BOOL)andFiles;

- (BOOL)checksystemDownloadFullPathExistNeedNotice:(BOOL)need;

/// 设置下载地址
- (BOOL)updatesystemDownloadPath:(nonnull NSString *)downloadPath;

/// 根据模型获取下载地址
- (NSString *)getDirPathWithSource:(nullable PicSourceModel *)sourceModel contentModel:(nullable PicContentModel *)contentModel;
/// 创建下载任务
- (void)downWithSource:(PicSourceModel *)sourceModel ContentTaskModel:(PicContentTaskModel *)contentTaskModel urls:(NSArray *)urls suggestNames:(nullable NSArray <NSString *> *)suggestNames;

/// 全部取消
- (void)cancelAllDownloads;
/// 取消某个任务
- (void)cancelDownloadsByIdentifiers:(NSArray <NSString *>*)indentifiers;

@end

NS_ASSUME_NONNULL_END
