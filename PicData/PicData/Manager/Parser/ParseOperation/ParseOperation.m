//
//  ParseOperation.m
//  PicData
//
//  Created by 鹏鹏 on 2022/8/5.
//  Copyright © 2022 garenge. All rights reserved.
//

#import "ParseOperation.h"

@interface ParseOperation()

@property(nonatomic, assign, readonly) BOOL hasStart;

// 上传任务标识
@property(nonatomic, assign) BOOL operationExecuting;
@property(nonatomic, assign) BOOL operationFinished;

@property (nonatomic, weak) NSURLSessionDataTask *dataTask;

@property (nonatomic, assign) int pageCount;
@property (nonatomic, assign) int picCount;


@end

@implementation ParseOperation

- (instancetype)initWithSourceModel:(PicSourceModel *)sourceModel contentTaskModel:(PicContentTaskModel *)contentTaskModel {
    if (self = [super init]) {
        self.sourceModel = sourceModel;
        self.contentTaskModel = contentTaskModel;
        self.picCount = 0;
        self.pageCount = 1;
    }
    return self;
}

+ (instancetype)operationWithSourceModel:(PicSourceModel *)sourceModel contentTaskModel:(PicContentTaskModel *)contentTaskModel {
    return [[ParseOperation alloc] initWithSourceModel:sourceModel contentTaskModel:contentTaskModel];
}

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

        [self requestHtmlStringWithUrl:self.contentTaskModel.href];
    }
}

- (void)requestHtmlStringWithUrl:(NSString *)url {
    // 错误-1, 网络部分错误
    // 错误-2, 写入部分错误
    if ([url containsString:@".html"]) {
        NSURL *baseURL = [NSURL URLWithString:self.sourceModel.HOST_URL];

        PDBlockSelf
        NSURL *taskURL = [NSURL URLWithString:url relativeToURL:baseURL];
        self.dataTask = [PDRequest getWithURL:taskURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

            if (weakSelf.isCancelled) {
                [weakSelf finishOperation];
                return;
            }

            NSString *nextUrl = @"";
            int count = 0;
            if (nil == error) {
                // 获取字符串
                NSString *content = [ContentParserManager getHtmlStringWithData:data sourceType:weakSelf.sourceModel.sourceType];

                NSLog(@"第%d页, %@, 完成", weakSelf.pageCount, [NSURL URLWithString:url relativeToURL:baseURL].absoluteString);

                NSDictionary *result = [ContentParserManager dealWithHtmlData:content referer:taskURL.absoluteString nextUrl:url WithSourceModel:weakSelf.sourceModel ContentTaskModel:weakSelf.contentTaskModel picCount:weakSelf.picCount];
                nextUrl = result[@"nextUrl"];

                count = [result[@"count"] intValue];

                PPIsBlockExecute(weakSelf.middleWriteHandler, [NSURL URLWithString:url relativeToURL:baseURL], [NSString stringWithFormat:@"\n%@", result[@"urls"]]);

            } else {
                NSLog(@"第%d页, %@, 出现错误-1, %@", weakSelf.pageCount, [NSURL URLWithString:url relativeToURL:baseURL].absoluteString, error);
            }

            if (![nextUrl containsString:@".html"]) {

                NSLog(@"%@ - %@ 完成", weakSelf.contentTaskModel.title, weakSelf.contentTaskModel.href);
                PPIsBlockExecute(weakSelf.taskCompleteHandler, weakSelf.picCount + count)

                [weakSelf finishOperation];
            } else {
                weakSelf.pageCount += 1;
                weakSelf.picCount += count;
                [weakSelf requestHtmlStringWithUrl:nextUrl];
            }
        }];
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

        [self.dataTask cancel];
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

- (void)dealloc {
    NSLog(@"ParseOperation dealloc ======");
}

@end
