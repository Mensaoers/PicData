//
//  PDDownloadManager.h
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "PicSourceModel.h"
#import "PicContentModel.h"
#import "PicDownRecoreModel.h"
#import "AppDelegate.h"

#define DOWNLOADSPATHKEY @"DOWNLOADSPATHKEY"
#define NOTICECHECKDOWNLOADPATHKEY @"NOTICECHECKDOWNLOADPATHKEY"
#define NOTICEPICDOWNLOADSUCCESS @"NOTICEPICDOWNLOADSUCCESS"

NS_ASSUME_NONNULL_BEGIN

@interface PDDownloadManager : NSObject

@property (nonatomic, strong) TRSessionManager *sessionManager;

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
/// 根据目标路径, 拼接基于document目录的完整路径
+ (NSString *)getDocumentPathWithTarget:(NSString *)targetPath;

- (BOOL)checksystemDownloadFullPathExistNeedNotice:(BOOL)need;
- (BOOL)checkFilePathExist:(NSString *)path;
/// 设置下载地址
- (BOOL)updatesystemDownloadPath:(nonnull NSString *)downloadPath;

/// 根据模型获取下载地址
- (NSString *)getDirPathWithSource:(nullable PicSourceModel *)sourceModel contentModel:(nullable PicContentModel *)contentModel;
/// 创建下载任务
- (void)downWithSource:(PicSourceModel *)sourceModel contentModel:(PicContentModel *)contentModel urls:(NSArray *)urls;

/// 全部取消
- (void)totalCancel;

@end

NS_ASSUME_NONNULL_END
