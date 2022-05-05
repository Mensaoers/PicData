    //
    //  PDDownloadManager.m
    //  PicData
    //
    //  Created by Garenge on 2020/4/19.
    //  Copyright © 2020 garenge. All rights reserved.
    //

#import "PDDownloadManager.h"
#import "PPDownloadTaskOperation.h"

@interface PDDownloadManager()

/// 用不到 作废
@property (nonatomic, strong) dispatch_queue_t didDownFinishQueue API_DEPRECATED("因为下载之后临时文件超时自动删除, 所以下载完成必须立马拷贝, 不能放到异步里面再拷贝, 故而作废", ios(2.0, 3.0));

@property (nonatomic, strong) NSOperationQueue *downloadQueue;

@end

@implementation PDDownloadManager

- (NSOperationQueue *)downloadQueue {
    if (nil == _downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.maxConcurrentOperationCount = 3;
    }
    return _downloadQueue;
}

/// 用不到, 作废
- (dispatch_queue_t)didDownFinishQueue {
    if (nil == _didDownFinishQueue) {
        // 异步队列
        dispatch_queue_t diapatchQueue = dispatch_queue_create("com.test.queue.downFinished", DISPATCH_QUEUE_CONCURRENT);
        // DISPATCH_QUEUE_SERIAL
        // DISPATCH_QUEUE_CONCURRENT
        _didDownFinishQueue = diapatchQueue;
    }
    return _didDownFinishQueue;
}

/// 数据库文件名
- (NSString *)databaseFileName {
    return @"picdata.db";
}

/// 数据库文件路径
- (NSString *)databaseFilePath {
    return [FileManager getDocumentPathWithTarget:self.databaseFileName];
}

+ (void)prepareDatabase {
    [DatabaseManager prepareDatabase];
}

+ (BOOL)deleteDatabase {
    [DatabaseManager closeDatabase];

    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[PDDownloadManager sharedPDDownloadManager].databaseFilePath error:&error];
    if (error) {
        return NO;
    } else {
        return YES;
    }
}

+ (BOOL)clearAllData:(BOOL)andFiles {

    [PicContentTaskModel deleteFromTable_All];

    if (andFiles) {

        if (![FileManager checkFolderPathExistOrCreate:[[PDDownloadManager sharedPDDownloadManager] systemDownloadFullPath]]) {
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

- (void)totalCancel {
    [self.downloadQueue cancelAllOperations];
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

    NSString *fullPath = [FileManager getDocumentPathWithTarget:downloadPath];
    return fullPath;
}

- (NSString *)systemDownloadFullDirectory {
    return [[self systemDownloadFullPath] lastPathComponent];
}

- (BOOL)checksystemDownloadFullPathExistNeedNotice:(BOOL)need {

    BOOL isExist = [FileManager checkFolderPathExistOrCreate:[self systemDownloadFullPath]];
    if (!isExist && need) {
            // 不存在
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICECHECKDOWNLOADPATHKEY object:nil];
    }
    return isExist;
}

    /// 设置下载地址
- (BOOL)updatesystemDownloadPath:(nonnull NSString *)downloadPath {

    NSString *fullPath = [FileManager getDocumentPathWithTarget:downloadPath];
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
    
    NSString *targetPath = [[self systemDownloadFullPath] stringByAppendingPathComponent:sourceModel.systemTitle];

    if (![[NSFileManager defaultManager] fileExistsAtPath:targetPath isDirectory:&isDir]) {
        NSError *createDirError = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:targetPath withIntermediateDirectories:YES attributes:nil error:&createDirError];
    }
    
    if (contentModel == nil) {
        return targetPath;
    }

    // 替换文件夹名称中的"/"为":", 可以创建带有斜线的文件夹, 创建完之后, 显示为预期名称
    NSString *contentPath = [targetPath stringByAppendingPathComponent:contentModel.systemTitle];
    if (![[NSFileManager defaultManager] fileExistsAtPath:contentPath isDirectory:&isDir]) {
        NSError *createDirError = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:contentPath withIntermediateDirectories:YES attributes:nil error:&createDirError];
    }
    
    return contentPath;
}

- (void)downWithSource:(PicSourceModel *)sourceModel ContentTaskModel:(PicContentTaskModel *)contentTaskModel urls:(NSArray *)urls suggestNames:(nullable NSArray<NSString *> *)suggestNames {

    if (![self checksystemDownloadFullPathExistNeedNotice:YES]) {
        return;
    }

    NSInteger count = urls.count;
    for (NSInteger index = 0; index < count; index ++) {
        NSString *url = urls[index];
        
        NSString *fileName = url.lastPathComponent;

        NSString *suggestName = [suggestNames objectOrNilAtIndex:index];
        if (suggestName.length > 0) {
            fileName = suggestName;
        }

        NSLog(@"文件%@开始下载", fileName);
        
        PDBlockSelf

        // 研究了一下web端下载图片时候的header, 添加一些字段, 这样可以下载大图
        NSDictionary *headers = @{
            @"User-Agent" : @"Mozilla/5.0 (Macintosh; Intel Mac OS X 11_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.66 Safari/537.36"
        };

        void(^downloadSuccessBlock)(void) = ^{
            NSLog(@"文件%@下载完成", fileName);
            contentTaskModel.downloadedCount += 1;

            // 我们是开始遍历的时候就开始下载了
            if (contentTaskModel.status == 1) {

            } else if (contentTaskModel.status == 2) {
                // 遍历完成
                if (contentTaskModel.totalCount > 0 && contentTaskModel.downloadedCount == contentTaskModel.totalCount) {
                    contentTaskModel.status = 3;
                    [contentTaskModel updateTable];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNameCompleteDownTask object:nil userInfo:@{@"contentModel": contentTaskModel}];
                }
            }
        };

        NSString *targetPath = [[weakSelf getDirPathWithSource:sourceModel contentModel:contentTaskModel] stringByAppendingPathComponent:fileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
            NSLog(@"文件:%@ 已存在, 跳过下载", targetPath);
            downloadSuccessBlock();
            continue;
        }

        PPDownloadTaskOperation *operation = [PPDownloadTaskOperation operationWithUrl:url headers:headers downloadFinishedBlock:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {

            if (nil == error) {

                if ([[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
                    NSLog(@"文件:%@ 已存在, 下载完成", targetPath);
                    downloadSuccessBlock();
                    return;
                } else {
                    NSError *copyError = nil;
                    [[NSFileManager defaultManager] copyItemAtPath:location.path toPath:targetPath error:&copyError];
                    if (nil == copyError) {
                        downloadSuccessBlock();
                    }
                }
            } else {
                NSLog(@"task.error:%@", error);
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNameFailedDownTask object:nil userInfo:@{@"contentModel": contentTaskModel}];
            }
        }];
        [self.downloadQueue addOperation:operation];
    }
}

@end
