    //
    //  PDDownloadManager.m
    //  PicData
    //
    //  Created by Garenge on 2020/4/19.
    //  Copyright © 2020 garenge. All rights reserved.
    //

#import "PDDownloadManager.h"

@interface PDDownloadManager()

@property (nonatomic, strong) dispatch_queue_t disDownFinishQueue;

@end

@implementation PDDownloadManager

- (dispatch_queue_t)disDownFinishQueue {
    if (nil == _disDownFinishQueue) {
        dispatch_queue_t diapatchQueue = dispatch_queue_create("com.test.queue.downFinished", DISPATCH_QUEUE_CONCURRENT);
        // DISPATCH_QUEUE_SERIAL
        // DISPATCH_QUEUE_CONCURRENT
        _disDownFinishQueue = diapatchQueue;
    }
    return _disDownFinishQueue;
}

/// 数据库文件名
- (NSString *)databaseFileName {
    return @"picdata.sqlite";
}

/// 数据库文件路径
- (NSString *)databaseFilePath {
    return [PDDownloadManager getDocumentPathWithTarget:self.databaseFileName];
}

+ (void)prepareDataBase {
    [JQFMDB shareDatabase:[PDDownloadManager sharedPDDownloadManager].databaseFileName path:[PDDownloadManager getDocumentPathWithTarget:@""]];
}

+ (BOOL)deleteDataBase {
    [[JQFMDB shareDatabase] close];
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[PDDownloadManager sharedPDDownloadManager].databaseFilePath error:&error];
    if (error) {
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)clearAllData:(BOOL)andFiles {
    [PDDownloadManager.sharedPDDownloadManager.sessionManager totalCancel];
    [PDDownloadManager.sharedPDDownloadManager.sessionManager totalRemove];

    if (![PDDownloadManager deleteDataBase]) {
        return NO;
    }
    if (andFiles) {

        if (![[PDDownloadManager sharedPDDownloadManager] checkFilePathExist:[[PDDownloadManager sharedPDDownloadManager] systemDownloadFullPath]]) {
            return NO;
        }

        NSError *rmError = nil;
        [[NSFileManager defaultManager] removeItemAtPath:[[PDDownloadManager sharedPDDownloadManager] systemDownloadFullPath] error:&rmError];//可以删除该路径下所有文件包括该文件夹本身
        if (rmError) {
            return NO;
        }
    }

    return YES;
}

singleton_implementation(PDDownloadManager);

- (TRSessionManager *)sessionManager {
    if (nil == _sessionManager) {
        TRSessionManager.logLevel = TRLogLevelSimple;
        _sessionManager = ((AppDelegate *)[UIApplication sharedApplication].delegate).sessionManager;
    }
    return _sessionManager;
}

- (void)totalCancel {
    [self.sessionManager totalCancel];
}

- (BOOL)resetDownloadPath {
    return [self updatesystemDownloadPath:[self defaultDownloadPath]];
}

- (nonnull NSString *)defaultDownloadPath {
    NSString *targetPath = @"PicDownloads";
    return targetPath;
}

- (nonnull NSString *)systemDownloadPath {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *downloadPath = [defaults valueForKey:DOWNLOADSPATHKEY];
    if (nil == downloadPath || downloadPath.length == 0) {
        downloadPath = [self defaultDownloadPath];
        [self updatesystemDownloadPath:downloadPath];
    }
    return downloadPath;
}

/// 获取默认下载地址
- (nonnull NSString *)systemDownloadFullPath {

    NSString *downloadPath = [self systemDownloadPath];

    NSString *fullPath = [PDDownloadManager getDocumentPathWithTarget:downloadPath];
    return fullPath;
}

+ (NSString *)getDocumentPathWithTarget:(NSString *)targetPath {
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *resultPath = targetPath.length > 0 ? [documentDir stringByAppendingPathComponent: targetPath] : documentDir;
    return resultPath;
}

- (NSString *)systemDownloadFullDirectory {
    return [[self systemDownloadFullPath] lastPathComponent];
}

- (BOOL)checksystemDownloadFullPathExistNeedNotice:(BOOL)need {

    BOOL isExist = [self checkFilePathExist:[self systemDownloadFullPath]];
    if (!isExist && need) {
            // 不存在
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICECHECKDOWNLOADPATHKEY object:nil];
    }
    return isExist;
}

- (BOOL)checkFilePathExist:(NSString *)path {
    BOOL isDir = YES;

    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];

    if (!isExist) {
        NSError *createError = nil;
        BOOL result =  [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&createError];
        if (createError) {
            NSLog(@"- checkFilePathExist - 创建文件失败: %@", createError);
        }
        return result;
    }

    return isExist;
}

    /// 设置下载地址
- (BOOL)updatesystemDownloadPath:(nonnull NSString *)downloadPath {

    NSString *fullPath = [PDDownloadManager getDocumentPathWithTarget:downloadPath];
    BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:nil];
    if (!result) {
        return NO;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (downloadPath.length == 0) {
        downloadPath = [self defaultDownloadPath];
    }
    [defaults setValue:downloadPath forKey:DOWNLOADSPATHKEY];
    return [defaults synchronize];
}

- (NSString *)getDirPathWithSource:(PicSourceModel *)sourceModel contentModel:(PicContentModel *)contentModel {

    BOOL isDir = YES;

    if (sourceModel == nil) {
        NSString *path = [self systemDownloadFullPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
            NSError *createDirError = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&createDirError];
        }
        return path;
    }
    
    NSString *targetPath = [[self systemDownloadFullPath] stringByAppendingPathComponent:sourceModel.title];

    if (![[NSFileManager defaultManager] fileExistsAtPath:targetPath isDirectory:&isDir]) {
        NSError *createDirError = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:targetPath withIntermediateDirectories:YES attributes:nil error:&createDirError];
    }
    
    if (contentModel == nil) {
        return targetPath;
    }
    
    NSString *contentPath = [targetPath stringByAppendingPathComponent:contentModel.title];
    if (![[NSFileManager defaultManager] fileExistsAtPath:contentPath isDirectory:&isDir]) {
        NSError *createDirError = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:contentPath withIntermediateDirectories:YES attributes:nil error:&createDirError];
    }
    
    return contentPath;
}

- (void)downWithSource:(PicSourceModel *)sourceModel ContentTaskModel:(PicContentTaskModel *)contentTaskModel urls:(NSArray *)urls {

    if (![self checksystemDownloadFullPathExistNeedNotice:YES]) {
        return;
    }

    NSInteger count = urls.count;
    for (NSInteger index = 0; index < count; index ++) {
        NSString *url = urls[index];
        
        NSString *fileName = url.lastPathComponent;
        NSLog(@"文件%@开始下载", fileName);
        
        PDBlockSelf

        // 研究了一下web端下载图片时候的header, 添加一些字段, 这样可以下载大图
        NSDictionary *headers = @{
            @"User-Agent" : @"Mozilla/5.0 (Macintosh; Intel Mac OS X 11_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.66 Safari/537.36 Edg/87.0.664.41",
            @"Sec-Fetch-Site" : @"cross-site",
            @"Sec-Fetch-Mode" : @"no-cors",
            @"Sec-Fetch-Dest" : @"image"
        };
        [[[[[self.sessionManager downloadWithUrl:url headers:headers fileName:nil] progressOnMainQueue:YES handler:^(TRDownloadTask * _Nonnull task) {
            if (task.error) {
                NSLog(@"task.error:%@", task.error);
            }
        }] successOnMainQueue:YES handler:^(TRDownloadTask * _Nonnull task) {
            
            dispatch_async(self.disDownFinishQueue, ^{
                NSError *copyError = nil;
                NSString *targetPath = [[weakSelf getDirPathWithSource:sourceModel contentModel:contentTaskModel] stringByAppendingPathComponent:url.lastPathComponent];
                [[NSFileManager defaultManager] copyItemAtPath:task.filePath toPath:targetPath error:&copyError];
                if (nil == copyError) {
                    NSLog(@"文件%@下载完成", fileName);
                    contentTaskModel.downloadedCount += 1;

                    // 我们是开始遍历的时候就开始下载了
                    if (contentTaskModel.status == 1) {

                    } else if (contentTaskModel.status == 2) {
                        // 遍历完成
                        if (contentTaskModel.totalCount > 0 && contentTaskModel.downloadedCount == contentTaskModel.totalCount) {
                            contentTaskModel.status = 3;
                            [contentTaskModel updateTable];
                        }
                    }
//                    [contentTaskModel updateTable];
                }
            });
        }] failureOnMainQueue:YES handler:^(TRDownloadTask * _Nonnull task) {
            if (task.error) {
                NSLog(@"task.error:%@", task.error);
            }
        }] validateFileWithCode:@"9e2a3650530b563da297c9246acaad5c" type:TRFileVerificationTypeMd5 onMainQueue:YES handler:^(TRDownloadTask * _Nonnull task) {
            
            if (task.error) {
                NSLog(@"task.error:%@", task.error);
            }
        }];
    }
}

@end
