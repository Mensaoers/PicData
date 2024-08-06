    //
    //  PDDownloadManager.m
    //  PicData
    //
    //  Created by Garenge on 2020/4/19.
    //  Copyright © 2020 garenge. All rights reserved.
    //

#import "PDDownloadManager.h"
#import "PPDownloadTaskOperation.h"

#define DOWNLOADSPATHKEY @"DOWNLOADSPATHKEY"
#define KMaxDownloadOperationCount @"KMaxDownloadOperationCount"

@interface PDDownloadManager()

/// 用不到 作废
@property (nonatomic, strong) dispatch_queue_t didDownFinishQueue API_DEPRECATED("因为下载之后临时文件超时自动删除, 所以下载完成必须立马拷贝, 不能放到异步里面再拷贝, 故而作废", ios(2.0, 3.0));

@property (nonatomic, strong) PPCustomOperationQueue *downloadQueue;

@end

@implementation PDDownloadManager

@synthesize maxDownloadOperationCount = _maxDownloadOperationCount;

- (NSInteger)defaultMinDownloadOperationCount {
    return 6;
}

- (NSInteger)defaultMaxDownloadOperationCount {
#if TARGET_OS_MACCATALYST
    return 20;
#else
    return 12;
#endif
}

- (BOOL)checkDownloadOperationCountCorrect:(NSInteger)willSetValue {
    return willSetValue >= [self defaultMinDownloadOperationCount] && willSetValue <= [self defaultMaxDownloadOperationCount];
}

- (NSInteger)getDownloadOperationCountCorrect:(NSInteger)willSetValue {
    return MAX(MIN(willSetValue, [self defaultMaxDownloadOperationCount]), [self defaultMinDownloadOperationCount]);
}

- (void)setMaxDownloadOperationCount:(NSInteger)maxDownloadOperationCount {
    maxDownloadOperationCount = [self getDownloadOperationCountCorrect:maxDownloadOperationCount];
    _maxDownloadOperationCount = maxDownloadOperationCount;

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:maxDownloadOperationCount forKey:KMaxDownloadOperationCount];
    [userDefaults synchronize];

    self.downloadQueue.maxConcurrentOperationCount = maxDownloadOperationCount;
}

- (NSInteger)maxDownloadOperationCount {

    if (_maxDownloadOperationCount > 0) {

    } else {
        _maxDownloadOperationCount = [[NSUserDefaults standardUserDefaults] integerForKey:KMaxDownloadOperationCount];
    }
    if (![self checkDownloadOperationCountCorrect:_maxDownloadOperationCount]) {
        [self setMaxDownloadOperationCount:6];
    }
    return _maxDownloadOperationCount;
}

- (PPCustomOperationQueue *)downloadQueue {
    if (nil == _downloadQueue) {
        _downloadQueue = [[PPCustomOperationQueue alloc] init];
        _downloadQueue.maxConcurrentOperationCount = self.maxDownloadOperationCount;
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
    return [PPFileManager getDocumentPathWithTarget:self.databaseFileName];
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

        if (![PPFileManager checkFolderPathExistOrCreate:[[PDDownloadManager sharedPDDownloadManager] systemDownloadFullPath]]) {
            return NO;
        }

        NSError *rmError = nil;
        [[NSFileManager defaultManager] removeItemAtPath:[[[PDDownloadManager sharedPDDownloadManager] systemDownloadFullPath] stringByAppendingPathComponent:@"."] error:&rmError];//可以删除该路径下所有文件包括该文件夹本身
        if (rmError) {
            NSLog(@"======%@", rmError);
        }
        return YES;
    }

    return YES;
}

singleton_implementation(PDDownloadManager);

- (void)cancelAllDownloads {
    [self.downloadQueue setSuspended:YES];
    [self.downloadQueue cancelAllOperations];
    [self.downloadQueue setSuspended:NO];
}

- (void)cancelDownloadsByIdentifiers:(NSArray<NSString *> *)identifiers {
    [self.downloadQueue setSuspended:YES];
    for (PPDownloadTaskOperation *operation in self.downloadQueue.operations) {

        if ([identifiers containsObject:operation.identifier]) {
            [operation cancel];
        }
    }
    [self.downloadQueue setSuspended:NO];
}

- (BOOL)resetDownloadPath {
    return [self updatesystemDownloadPath:[self defaultDownloadPath]];
}

- (nonnull NSString *)defaultDownloadPath {
    NSString *targetName = @"PicDownloads";
#if TARGET_OS_MACCATALYST
    return [PPFileManager getDocumentPathWithTarget:targetName];;
#else
    return targetName;
#endif
}

/// 如果是mac端, 保存全路径, 如果是iOS端, 保存相对路径
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

    NSString *fullPath;
    // @"/Volumes/T7/.12AC169F959B49C89E3EE409191E2EF1/Program Files (x86)/Program File";
#if TARGET_OS_MACCATALYST
    fullPath = downloadPath;
#else
    fullPath = [PPFileManager getDocumentPathWithTarget:downloadPath];
#endif
    return fullPath;
}

- (NSString *)systemDownloadFullDirectory {
    return [[self systemDownloadFullPath] lastPathComponent];
}

static NSString *favoriteFolderName = @"我的收藏";
- (NSString *)systemFavoriteFolderPath {
    return [[self systemDownloadFullPath] stringByAppendingPathComponent:favoriteFolderName];
}

- (NSString *)systemFavoriteFolderName {
    return favoriteFolderName;
}

static NSString *shareFolderName = @"myShare";
/// 获取当前系统分享文件夹路径
- (nonnull NSString *)systemShareFolderPath {
    NSString *folderPath = [[self systemDownloadFullPath] stringByAppendingPathComponent:shareFolderName];
    [PPFileManager checkFolderPathExistOrCreate:folderPath];
    return folderPath;
}
/// 获取当前系统分享文件夹名称
- (nonnull NSString *)systemShareFolderName {
    return shareFolderName;
}

- (BOOL)checksystemDownloadFullPathExistNeedNotice:(BOOL)need {

    BOOL isExist = [PPFileManager checkFolderPathExistOrCreate:[self systemDownloadFullPath]];
    if (!isExist && need) {
            // 不存在
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICECHECKDOWNLOADPATHKEY object:nil];
    }
    return isExist;
}

    /// 设置下载地址
- (BOOL)updatesystemDownloadPath:(nonnull NSString *)downloadPath {

    NSString *fullPath;
#if TARGET_OS_MACCATALYST
    fullPath = [PPFileManager getDocumentPathWithTarget:downloadPath];
#else
    fullPath = downloadPath;
#endif

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

    NSString *targetPath = [[self systemDownloadFullPath] stringByAppendingPathComponent:contentModel.isFavor ? [self systemFavoriteFolderName] : sourceModel.systemTitle];

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

- (void)downWithSource:(PicSourceModel *)sourceModel ContentTaskModel:(PicContentTaskModel *)contentTaskModel urls:(NSArray *)urls referer:(NSString *)referer suggestNames:(NSArray<NSString *> *)suggestNames {

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
        NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:@{
            @"User-Agent" : @"Mozilla/5.0 (Macintosh; Intel Mac OS X 11_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.66 Safari/537.36",
        }];
        // 部分网页是不需要设置referer的
        if ([AppTool.sharedAppTool.referTypes containsObject:@(sourceModel.sourceType)] && referer.length > 0) {
            [headers setValue:referer forKey:@"referer"];
        }

        void(^downloadSuccessBlock)(void) = ^{
            NSLog(@"文件%@下载完成", fileName);
            contentTaskModel.downloadedCount += 1;

            // 我们是开始遍历的时候就开始下载了
            if (contentTaskModel.status == 1) {

            } else if (contentTaskModel.status == 2) {
                // 遍历完成
                if (contentTaskModel.totalCount > 0 && contentTaskModel.downloadedCount == contentTaskModel.totalCount) {
                    contentTaskModel.status = 3;
                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNameCompleteDownTask object:nil userInfo:@{@"contentModel": contentTaskModel}];
                }
            }

            [contentTaskModel updateTable];
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNameCompleteDownPicture object:nil userInfo:@{@"contentModel": contentTaskModel}];
        };

        NSString *targetPath = [[weakSelf getDirPathWithSource:sourceModel contentModel:contentTaskModel] stringByAppendingPathComponent:fileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
            NSLog(@"文件:%@ 已存在, 跳过下载", targetPath);
            downloadSuccessBlock();
            continue;
        }

        PPDownloadTaskOperation *operation = [PPDownloadTaskOperation operationWithUrl:url identifier:contentTaskModel.href headers:headers downloadFinishedBlock:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {

            if (error) {
                NSLog(@"task.error:%@", error);
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNameFailedDownPicture object:nil userInfo:@{@"contentModel": contentTaskModel}];
                return;
            }
            if ([[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
                NSLog(@"文件:%@ 已存在, 下载完成", targetPath);
                downloadSuccessBlock();
                return;
            } else {
                NSError *moveError = nil;
                [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:targetPath] error:&moveError];
                if (nil == moveError) {
                    downloadSuccessBlock();
                } else {
                    NSLog(@"task. move error:%@", moveError);
                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNameFailedDownPicture object:nil userInfo:@{@"contentModel": contentTaskModel}];
                }
            }
        }];
        [self.downloadQueue addOperation:operation];
    }
}

@end
