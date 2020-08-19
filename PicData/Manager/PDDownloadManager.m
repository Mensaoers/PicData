//
//  PDDownloadManager.m
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "PDDownloadManager.h"
#import "AppDelegate.h"

@interface PDDownloadManager()

@property (nonatomic, strong) TRSessionManager *sessionManager;

@end

@implementation PDDownloadManager

singleton_implementation(PDDownloadManager);

- (TRSessionManager *)sessionManager {
    if (nil == _sessionManager) {
        TRSessionManager.logLevel = TRLogLevelSimple;

        dispatch_sync(dispatch_get_main_queue(), ^{
            _sessionManager = ((AppDelegate *)[UIApplication sharedApplication].delegate).sessionManager;
        });
    }
    return _sessionManager;
}

- (NSString *)defaultDownloadPath {
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *targetPath = [documentDir stringByAppendingPathComponent:@"PicDownloads"];
    [[NSFileManager defaultManager] createDirectoryAtPath:targetPath withIntermediateDirectories:YES attributes:nil error:nil];
    return targetPath;
}

/// 获取默认下载地址
- (nonnull NSString *)systemDownloadPath {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *downloadPath = [defaults valueForKey:DOWNLOADSPATHKEY];

    if (nil == downloadPath || downloadPath.length == 0) {
        downloadPath = [self defaultDownloadPath];
        [self updateSystemDownloadPath:downloadPath];
    }

    NSLog(@"当前下载地址为%@", downloadPath);
    return downloadPath;
}

- (BOOL)checkSystemDownloadPathExistNeedNotice:(BOOL)need {

    BOOL isExist = [self checkDownloadPathExist:[self systemDownloadPath]];
    if (!isExist && need) {
        // 不存在
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICECHECKDOWNLOADPATHKEY object:nil];
    }
    return isExist;
}

- (BOOL)checkDownloadPathExist:(NSString *)path {
    BOOL isDir = YES;

    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];

    if (!isExist) {
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (!result) {
            return NO;
        } else {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            return YES;
        }
    }

    return isExist;
}

/// 设置下载地址
- (BOOL)updateSystemDownloadPath:(nonnull NSString *)downloadPath {
    BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:downloadPath withIntermediateDirectories:YES attributes:nil error:nil];
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
        NSString *path = [self systemDownloadPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
            NSError *createDirError = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&createDirError];
        }
        return path;
    }
    
    NSString *targetPath = [[self systemDownloadPath] stringByAppendingPathComponent:sourceModel.title];

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

    if (![self checkSystemDownloadPathExistNeedNotice:YES]) {
        return;
    }

    NSInteger count = urls.count;
    for (NSInteger index = 0; index < count; index ++) {
        NSString *url = urls[index];
        
        NSString *fileName = url.lastPathComponent;
        NSLog(@"文件%@开始下载", fileName);
        [[[[[self.sessionManager downloadWithUrl:url headers:@{@"User-Agent" : @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4)"} fileName:nil] progressOnMainQueue:YES handler:^(TRDownloadTask * _Nonnull task) {
            if (task.error) {
                NSLog(@"task.error:%@", task.error);
            }
        }] successOnMainQueue:YES handler:^(TRDownloadTask * _Nonnull task) {
            NSError *copyError = nil;
            NSString *targetPath = [[self getDirPathWithSource:sourceModel contentModel:contentModel] stringByAppendingPathComponent:url.lastPathComponent];
            [[NSFileManager defaultManager] copyItemAtPath:task.filePath toPath:targetPath error:&copyError];
            if (nil == copyError) {
                NSLog(@"文件%@下载完成", fileName);
            }
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
