//
//  ParseOperation.m
//  PicData
//
//  Created by 鹏鹏 on 2022/8/5.
//  Copyright © 2022 garenge. All rights reserved.
//

#import "ParseOperation.h"

@interface ParseOperation()

@property (nonatomic, weak) NSURLSessionDataTask *dataTask;

@property (nonatomic, assign) int pageCount;
@property (nonatomic, assign) int picCount;

@end

@implementation ParseOperation

+ (instancetype)operationWithSourceModel:(PicSourceModel *)sourceModel contentTaskModel:(PicContentTaskModel *)contentTaskModel {
    return [[ParseOperation alloc] initWithSourceModel:sourceModel contentTaskModel:contentTaskModel];
}

- (instancetype)initWithSourceModel:(PicSourceModel *)sourceModel contentTaskModel:(PicContentTaskModel *)contentTaskModel {
    if (self = [super init]) {
        self.sourceModel = sourceModel;
        self.contentTaskModel = contentTaskModel;
        self.picCount = 0;
        self.pageCount = 1;

        __weak typeof(self) weakSelf = self;
        self.mainOperationDoBlock = ^BOOL(PPCustomAsyncOperation * _Nonnull operation) {
            [weakSelf requestHtmlStringWithUrl:weakSelf.contentTaskModel.href];
            return NO;
        };
    }
    return self;
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

- (void)finishOperation {
    [self.dataTask cancel];
    self.dataTask = nil;
    [super finishOperation];
}

- (void)requestHtmlStringWithUrl:(NSString *)url {
    // 错误-1, 网络部分错误
    // 错误-2, 写入部分错误
    if (nil == url || url.length == 0) {
        [self finishOperation];
        return;
    }
    NSURL *baseURL = [NSURL URLWithString:self.sourceModel.HOST_URL];
    NSURL *taskURL = [NSURL URLWithString:url relativeToURL:baseURL];

    PDBlockSelf
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

        if (nil == nextUrl || nextUrl.length == 0) {

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

@end
