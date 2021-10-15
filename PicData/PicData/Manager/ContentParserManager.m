//
//  ContentParserManager.m
//  PicData
//
//  Created by Garenge on 2020/4/20.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "ContentParserManager.h"
#import "PDDownloadManager.h"

@interface ContentParserManager()

@property (nonatomic, assign) int maxConcurrentTasksLimit; // 默认为5
@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation ContentParserManager

singleton_implementation(ContentParserManager)

+ (void)cancelAll {
    [ContentParserManager.sharedContentParserManager.queue cancelAllOperations];
    [PDDownloadManager.sharedPDDownloadManager totalCancel];
}

- (int)maxConcurrentTasksLimit {
    return 2;
}
- (NSOperationQueue *)queue {
    if (nil == _queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = self.maxConcurrentTasksLimit; // 串行队列
    }
    return _queue;
}

/// 新增套图下载任务
+ (void)tryToAddTaskWithSourceModel:(PicSourceModel *)sourceModel ContentModel:(PicContentModel *)contentModel operationTips:(void (^)(BOOL, NSString * _Nonnull))operationTips {
    NSArray *results = [PicContentTaskModel queryTableWithHref:contentModel.href];

    if (results.count == 0) {
        // 没有查到, 说明没有添加过
        PicContentTaskModel *taskModel = [PicContentTaskModel taskModelWithContentModel:contentModel];

        // 这里判断过, 那么就没必要重写这个insert方法
        [taskModel insertTable];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICECHEADDNEWTASK object:nil userInfo:@{@"contentModel": contentModel}];
        [ContentParserManager parserWithSourceModel:sourceModel ContentTaskModel:taskModel];
        operationTips(YES, @"任务已添加");
    } else {
        operationTips(YES, @"任务已存在");
    }
}

/// 从数据库某条数据创建任务
+ (void)tryToAddTaskWithContentTaskModel:(PicContentTaskModel *)contentModel operationTips:(void (^)(BOOL, NSString * _Nonnull))operationTips {
    PicSourceModel *sourceModel = [[PicSourceModel queryTableWithTitle:contentModel.sourceTitle] firstObject];
    if (sourceModel != nil) {
        [self parserWithSourceModel:sourceModel ContentTaskModel:contentModel];
    }
}

/// app启动的时候, 将所有1的任务取出来开始进行
+ (void)prepareForAppLaunch {
    [PicContentTaskModel resetHalfWorkingTasks];
    [self prepareToDoNextTask];
}
/// 查询接下来要开始的任务
+ (void)prepareToDoNextTask {
    NSArray *results = [PicContentTaskModel queryNextTask];
    if (results.count > 0) {
        PicContentTaskModel *nextTaskModel = results.firstObject;
        PicSourceModel *sourceModel = [[PicSourceModel queryTableWithTitle:nextTaskModel.sourceTitle] firstObject];
        if (sourceModel != nil) {
            [self parserWithSourceModel:sourceModel ContentTaskModel:nextTaskModel];
        }
    }
}

/// 准备下载 解析对应的数据, 开始创建下载任务
+ (void)parserWithSourceModel:(PicSourceModel *)sourceModel ContentTaskModel:(PicContentTaskModel *)contentTaskModel {
    NSString *targetPath = [[PDDownloadManager sharedPDDownloadManager] getDirPathWithSource:sourceModel contentModel:contentTaskModel];

    NSOperationQueue *queue = [ContentParserManager sharedContentParserManager].queue;

    if (queue.maxConcurrentOperationCount > queue.operationCount) {

        NSString *filePath = [targetPath stringByAppendingPathComponent:@"urlList.txt"];
        NSLog(@"%@", filePath);

        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSError *removeError = nil;
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&removeError];
            if (removeError) {
                return;
            }
        }
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];

        contentTaskModel.status = 1;
        [contentTaskModel updateTable];

        [queue addOperationWithBlock:^{

            //创建信号量并设置计数默认为0
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            NSFileHandle *targetHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
            [ContentParserManager dealWithUrl:contentTaskModel.href targetHandle:targetHandle pageCount:1 picCount:0 WithSourceModel:sourceModel ContentTaskModel:contentTaskModel taskCompleteHandler:^{

                dispatch_semaphore_signal(sema);
                // 我们需要做一个操作, 是让他继续下一个任务
                [ContentParserManager prepareToDoNextTask];
            }];
            //若计数为0则一直等待
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }];
        [ContentParserManager prepareToDoNextTask];
    }
}

/// 处理页面源码, 提取页面数据
+ (void)dealWithUrl:(NSString *)url targetHandle:(NSFileHandle *)targetHandle pageCount:(int)pageCount picCount:(int)picCount WithSourceModel:(PicSourceModel *)sourceModel ContentTaskModel:(PicContentTaskModel *)contentTaskModel taskCompleteHandler:(void(^)(void))taskCompleteHandler {
    // 错误-1, 网络部分错误
    // 错误-2, 写入部分错误
    if ([url containsString:@".html"]) {
        NSURL *baseURL = [NSURL URLWithString:sourceModel.HOST_URL];

        [PDRequest getWithURL:[NSURL URLWithString:url relativeToURL:baseURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

            NSString *nextUrl = @"";
            int count = 0;
            if (nil == error) {
                // 获取字符串
                NSString *content = [AppTool getStringWithGB_18030_2000Code:data];

                NSLog(@"第%d页, %@, 完成", pageCount, [NSURL URLWithString:url relativeToURL:baseURL].absoluteString);

                NSDictionary *result = [ContentParserManager dealWithHtmlData:content WithSourceModel:sourceModel ContentTaskModel:contentTaskModel];
                nextUrl = result[@"nextUrl"];
                if (nextUrl.length > 0) {
                    nextUrl = [url stringByReplacingOccurrencesOfString:url.lastPathComponent withString:nextUrl];
                }
                NSError *writeError = nil;
                count = [result[@"count"] intValue];
                [targetHandle writeData:[[NSString stringWithFormat:@"\n%@", [NSURL URLWithString:result[@"urls"] relativeToURL:baseURL].absoluteString] dataUsingEncoding:NSUTF8StringEncoding]];
                if (writeError) {
                    NSLog(@"%@, 出现错误-2, %@", [NSURL URLWithString:url relativeToURL:baseURL].absoluteString, writeError);
                }
            } else {
                NSLog(@"第%d页, %@, 出现错误-1, %@", pageCount, [NSURL URLWithString:url relativeToURL:baseURL].absoluteString, error);
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:NOTICECHEADDNEWDETAILTASK object:nil userInfo:@{@"contentModel": contentTaskModel}];
            if (![nextUrl containsString:@".html"]) {
                [targetHandle closeFile];
                NSLog(@"完成");
                // 获取到最后一页一直到这一行, 都是同步运行, 所以下载肯定会晚于遍历结束
                contentTaskModel.totalCount = picCount + count;
                contentTaskModel.status = 2;
                // 遍历完成
                if (contentTaskModel.totalCount > 0 && contentTaskModel.downloadedCount == contentTaskModel.totalCount) {
                    contentTaskModel.status = 3;
                }
                [contentTaskModel updateTable];

                PPIsBlockExecute(taskCompleteHandler)
            } else {
                [ContentParserManager dealWithUrl:nextUrl targetHandle:targetHandle pageCount:pageCount + 1 picCount:picCount + count WithSourceModel:sourceModel ContentTaskModel:contentTaskModel taskCompleteHandler:taskCompleteHandler];
            }
        }];
    }
}

/// 处理html标签, 创建下载图片任务开始下载
+ (NSDictionary *)dealWithHtmlData:(NSString *)htmlString WithSourceModel:(PicSourceModel *)sourceModel ContentTaskModel:(PicContentTaskModel *)contentTaskModel {
    NSString *url = @"";
    NSMutableString *urlsString = [NSMutableString string];
    int count = 0;
    if (htmlString.length > 0) {

        OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];
        NSMutableArray *urls = [NSMutableArray array];

        OCGumboElement *contentE = document.Query(@".article-content").firstObject;
        if (nil != contentE) {
            OCQueryObject *es = contentE.Query(@"img");
            for (OCGumboElement *e in es) {
                NSString *src = e.attr(@"src");
                if (src.length > 0) {
                    [urls addObject:src];
                }
            }
        }

        OCGumboElement *next = document.Query(@".next-page").firstObject;
        if (nil != next) {
            OCGumboElement *aE = next.Query(@"a").firstObject;
            if (nil != aE) {
                NSString *href = aE.attr(@"href");
                if (href.length > 0 && [href.lastPathComponent containsString:@"_"]) {
                    url = href;
                }
            }
        }

        count += urls.count;
        // 这边没必要异步添加任务了, 就直接添加即可, 本身这个解析过程就是异步的
        [[PDDownloadManager sharedPDDownloadManager] downWithSource:sourceModel ContentTaskModel:contentTaskModel urls:[urls copy]];

    }

    if (url.length == 0) {
        NSLog(@"获取到的下一个url是空的");
    }

    return @{@"nextUrl" : url, @"urls" : [urlsString copy], @"count": @(count)};
}

@end
