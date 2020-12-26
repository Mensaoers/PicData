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
    NSLog(@"当前下载地址为: %@\n完整地址: %@", downloadPath, fullPath);
    return fullPath;
}

+ (NSString *)getDocumentPathWithTarget:(NSString *)targetPath {
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *resultPath = [documentDir stringByAppendingPathComponent: targetPath];
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

- (void)downWithSource:(PicSourceModel *)sourceModel contentModel:(PicContentModel *)contentModel urls:(NSArray *)urls {

    if (![self checksystemDownloadFullPathExistNeedNotice:YES]) {
        return;
    }

    NSInteger count = urls.count;
    for (NSInteger index = 0; index < count; index ++) {
        NSString *url = urls[index];
        
        NSString *fileName = url.lastPathComponent;
        NSLog(@"文件%@开始下载", fileName);

            //        PicDownRecoreModel *recordModel = [[PicDownRecoreModel alloc] init];
            //        recordModel.HOST_URL = contentModel.HOST_URL;
            //        recordModel.contentUrl = contentModel.href;
            //        recordModel.contentName = contentModel.title;
            //        recordModel.url = url;
            //        recordModel.title = fileName;
            //        recordModel.isFinished = 0;
            ////        [JKSqliteModelTool saveOrUpdateModel:recordModel uid:SQLite_USER];
            //        [recordModel insertTable];
        PDBlockSelf

        // 研究了一下web端下载图片时候的header, 添加一些字段, 这样可以下载大图
        NSDictionary *headers = @{
            @"User-Agent" : @"Mozilla/5.0 (Macintosh; Intel Mac OS X 11_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.66 Safari/537.36 Edg/87.0.664.41",
            @"Sec-Fetch-Site" : @"cross-site",
            @"Sec-Fetch-Mode" : @"no-cors",
            @"Sec-Fetch-Dest" : @"image",
            @"Referer" : @"https://www.aitaotu.com/",
        };
        [[[[[self.sessionManager downloadWithUrl:url headers:headers fileName:nil] progressOnMainQueue:YES handler:^(TRDownloadTask * _Nonnull task) {
            if (task.error) {
                NSLog(@"task.error:%@", task.error);
            }
        }] successOnMainQueue:YES handler:^(TRDownloadTask * _Nonnull task) {
            
            dispatch_async(self.disDownFinishQueue, ^{
                NSError *copyError = nil;
                NSString *targetPath = [[weakSelf getDirPathWithSource:sourceModel contentModel:contentModel] stringByAppendingPathComponent:url.lastPathComponent];
                [[NSFileManager defaultManager] copyItemAtPath:task.filePath toPath:targetPath error:&copyError];
                if (nil == copyError) {
                    NSLog(@"文件%@下载完成", fileName);
                        //                recordModel.isFinished = 1;
                        //                [recordModel updateTable];
                        //                [JKSqliteModelTool saveOrUpdateModel:recordModel uid:SQLite_USER];
                        //                [[NSNotificationCenter defaultCenter] postNotificationName:NOTICEPICDOWNLOADSUCCESS object:nil userInfo:@{@"recordModel": recordModel}];
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
