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

#define DOWNLOADSPATHKEY @"DOWNLOADSPATHKEY"
#define NOTICECHECKDOWNLOADPATHKEY @"NOTICECHECKDOWNLOADPATHKEY"
#define NOTICEPICDOWNLOADSUCCESS @"NOTICEPICDOWNLOADSUCCESS"

NS_ASSUME_NONNULL_BEGIN

@interface PDDownloadManager : NSObject

singleton_interface(PDDownloadManager);
/// 获取默认下载地址
- (NSString *)defaultDownloadPath;
- (nonnull NSString *)systemDownloadPath;
- (BOOL)checkSystemDownloadPathExistNeedNotice:(BOOL)need;
- (BOOL)checkDownloadPathExist:(NSString *)path;
/// 设置下载地址
- (BOOL)updateSystemDownloadPath:(nonnull NSString *)downloadPath;

/// 根据模型获取下载地址
- (NSString *)getDirPathWithSource:(nullable PicSourceModel *)sourceModel contentModel:(nullable PicContentModel *)contentModel;
/// 创建下载任务
- (void)downWithSource:(PicSourceModel *)sourceModel contentModel:(PicContentModel *)contentModel urls:(NSArray *)urls;

@end

NS_ASSUME_NONNULL_END
