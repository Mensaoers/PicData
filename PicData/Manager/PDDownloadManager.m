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

        _sessionManager = ((AppDelegate *)[UIApplication sharedApplication].delegate).sessionManager;
    }
    return _sessionManager;
}

- (NSString *)getDirPathWithSource:(PicSourceModel *)sourceModel contentModel:(PicContentModel *)contentModel {
    
    if (sourceModel == nil) {
        return DOWNLOADSPATH;
    }
    
    NSString *targetPath = [DOWNLOADSPATH stringByAppendingPathComponent:sourceModel.title];
    BOOL isDir = YES;
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
//    [[DGDownloadManager shareManager] setCachePath:[self getDirPathWithSource:sourceModel contentModel:contentModel]];
//    NSInteger count = urls.count;
//    for (NSInteger index = 0; index < count; index ++) {
//        NSString *url = urls[index];
//        [[DGDownloadManager shareManager] DG_DownloadWithUrl:url withCustomCacheName:url.lastPathComponent];
//    }
    [[DGDownloadManager shareManager] setCachePath:[self getDirPathWithSource:sourceModel contentModel:contentModel]];
    NSInteger count = urls.count;
    for (NSInteger index = 0; index < count; index ++) {
        NSString *url = urls[index];
        
        [[[[[self.sessionManager downloadWithUrl:url headers:@{@"User-Agent" : @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4)"} fileName:nil] progressOnMainQueue:YES handler:^(TRDownloadTask * _Nonnull task) {
            NSLog(@"task.error:%@", task.error);
        }] successOnMainQueue:YES handler:^(TRDownloadTask * _Nonnull task) {
            NSError *copyError = nil;
            [[NSFileManager defaultManager] copyItemAtPath:task.filePath toPath:[[self getDirPathWithSource:sourceModel contentModel:contentModel] stringByAppendingPathComponent:url.lastPathComponent] error:&copyError];
            if (nil == copyError) {
                
            }
        }] failureOnMainQueue:YES handler:^(TRDownloadTask * _Nonnull task) {
            NSLog(@"task.error:%@", task.error);
        }] validateFileWithCode:@"9e2a3650530b563da297c9246acaad5c" type:TRFileVerificationTypeMd5 onMainQueue:YES handler:^(TRDownloadTask * _Nonnull task) {
            NSLog(@"task.error:%@", task.error);
            
        }];
    }
}

@end
