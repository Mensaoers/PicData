//
//  PPDownloadTaskOperation.m
//  PicData
//
//  Created by 鹏鹏 on 2022/4/20.
//  Copyright © 2022 garenge. All rights reserved.
//

#import "PPDownloadTaskOperation.h"

@interface PPDownloadTaskOperation()

@property(nonatomic, assign, readonly) BOOL hasStart;

// 上传任务标识
@property(nonatomic, assign) BOOL operationExecuting;
@property(nonatomic, assign) BOOL operationFinished;

@property (nonatomic, strong) NSDictionary *headers;

@end

@implementation PPDownloadTaskOperation

- (instancetype)initWithUrl:(NSString *)url headers:(NSDictionary *)headers downloadFinishedBlock:(nonnull DownloadFinishedBlock)downloadFinishedBlock {
    if (self = [super init]) {
        self.url = url;
        self.downloadFinishedBlock = downloadFinishedBlock;
        self.headers = headers;
    }
    return self;
}

+ (instancetype)operationWithUrl:(NSString *)url headers:(NSDictionary *)headers downloadFinishedBlock:(nonnull DownloadFinishedBlock)downloadFinishedBlock {
    return [[PPDownloadTaskOperation alloc] initWithUrl:url headers:headers downloadFinishedBlock:downloadFinishedBlock];
}

#pragma mark - 重写系统方法

- (void)start {
    _hasStart = YES;
    if ([self isCancelled]) {
        [self signKVOComplete];
        return;
    }

    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main)
                             toTarget:self withObject:nil];
    self.operationExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)main {
    @autoreleasepool {
        if (self.isCancelled) {
            return;
        }

        __weak typeof(self) weakSelf = self;

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
        for (NSString *key in self.headers.allKeys) {
            [request setValue:self.headers[key] forHTTPHeaderField:key];
        }
        NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession] downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {

            PPIsBlockExecute(self.downloadFinishedBlock, location, response, error);
            [weakSelf finishOperation];
        }];
        [downloadTask resume];
    }
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    if (self.operationExecuting) {
        NSLog(@"---------%@ Start---------", NSStringFromClass([self class]));
    }
    return self.operationExecuting;
}

- (BOOL)isFinished {
    if (self.operationFinished) {
        NSLog(@"---------%@ End---------", NSStringFromClass([self class]));
    }
    return self.operationFinished;
}

- (void)cancel {
    @synchronized (self) {
        [super cancel];


        if ([self isExecuting]) {
            [self finishOperation];
        }
    }
}

#pragma mark - 自定义方法

- (void)finishOperation {
    @synchronized (self) {
        if (!self.operationExecuting && self.operationFinished) {
            return;
        }

        if (_hasStart) {
            [self signKVOComplete];
        }
    }
}

- (void)signKVOComplete {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];

    self.operationExecuting = NO;
    self.operationFinished = YES;

    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end
