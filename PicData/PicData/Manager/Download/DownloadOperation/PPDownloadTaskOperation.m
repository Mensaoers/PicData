//
//  PPDownloadTaskOperation.m
//  PicData
//
//  Created by 鹏鹏 on 2022/4/20.
//  Copyright © 2022 garenge. All rights reserved.
//

#import "PPDownloadTaskOperation.h"

@interface PPDownloadTaskOperation()

@property (nonatomic, strong) NSDictionary *headers;

@property (nonatomic, weak) NSURLSessionDownloadTask *downloadTask;

@end

@implementation PPDownloadTaskOperation

- (instancetype)initWithUrl:(NSString *)url identifier:(nonnull NSString *)identifier headers:(nonnull NSDictionary *)headers downloadFinishedBlock:(nonnull DownloadFinishedBlock)downloadFinishedBlock {
    if (self = [super init]) {
        self.url = url;
        self.identifier = identifier;
        self.downloadFinishedBlock = downloadFinishedBlock;
        self.headers = headers;

        __weak typeof(self) weakSelf = self;
        self.mainOperationDoBlock = ^BOOL(PPCustomAsyncOperation * _Nonnull operation) {
            [weakSelf requestToDownloadFile];
            return NO;
        };
    }
    return self;
}

+ (instancetype)operationWithUrl:(NSString *)url identifier:(nonnull NSString *)identifier headers:(nonnull NSDictionary *)headers downloadFinishedBlock:(nonnull DownloadFinishedBlock)downloadFinishedBlock {
    return [[PPDownloadTaskOperation alloc] initWithUrl:url  identifier:identifier headers:headers downloadFinishedBlock:downloadFinishedBlock];
}

- (void)requestToDownloadFile {
    __weak typeof(self) weakSelf = self;

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    for (NSString *key in self.headers.allKeys) {
        [request setValue:self.headers[key] forHTTPHeaderField:key];
    }
    NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession] downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        PPIsBlockExecute(self.downloadFinishedBlock, location, response, error);
        [weakSelf finishOperation];
    }];
    self.downloadTask = downloadTask;
    [downloadTask resume];
}

- (void)cancel {
    [self.downloadTask cancel];
    [super cancel];
}

- (void)finishOperation {
    [self.downloadTask cancel];
    self.downloadTask = nil;
    [super finishOperation];
}

@end
