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
        NSString *targetPath = [[PDDownloadManager sharedPDDownloadManager] getDirPathWithSource:sourceModel contentModel:taskModel];

        // 这里判断过, 那么就没必要重写这个insert方法
        [taskModel insertTable];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICECHEADDNEWTASK object:nil userInfo:@{@"contentModel": contentModel}];
        [ContentParserManager prepareToDoNextTask];
        operationTips(YES, @"任务已添加");
    } else {
        operationTips(YES, @"任务已存在");
    }
}

/// app启动的时候, 将所有1的任务取出来开始进行
+ (void)prepareForAppLaunch {
    [PicContentTaskModel resetHalfWorkingTasks];
    [self prepareToDoNextTask];

    [NSNotificationCenter.defaultCenter addObserver:[ContentParserManager sharedContentParserManager] selector:@selector(receiveNoticeCompleteATask:) name:NOTICECHECOMPLETEDOWNATASK object:nil];
    [NSNotificationCenter.defaultCenter addObserver:[ContentParserManager sharedContentParserManager] selector:@selector(receiveNoticeFailedATask:) name:NOTICECHEFAILEDDOWNATASK object:nil];
}

- (void)receiveNoticeCompleteATask:(NSNotification *)notification {
    [ContentParserManager prepareToDoNextTask:YES];
}

- (void)receiveNoticeFailedATask:(NSNotification *)notification {
    [ContentParserManager prepareToDoNextTask:YES];
}

/// 查询接下来要开始的任务
+ (void)prepareToDoNextTask {
    [self prepareToDoNextTask:NO];
}

/// 查询接下来要开始的任务(强制添加)
+ (void)prepareToDoNextTask:(BOOL)force {

    if (!force) {
        // 为了防止剩余任务无限执行(解析网页比下载图片快得多, 时间一长会有大量任务堆积)
        NSInteger ingCount = [PicContentTaskModel queryCountForTaskInStatus12];
        if (ingCount > 2) {
            return;
        }
    }

    NSArray *results = [PicContentTaskModel queryNextTask];
    if (results.count > 0) {
        PicContentTaskModel *nextTaskModel = results.firstObject;
        PicSourceModel *sourceModel = [[PicSourceModel queryTableWithUrl:nextTaskModel.sourceHref] firstObject];
        if (sourceModel != nil) {
            [self parserWithSourceModel:sourceModel ContentTaskModel:nextTaskModel];
        }
    }
}

/// 准备下载 解析对应的数据, 开始创建下载任务
+ (void)parserWithSourceModel:(PicSourceModel *)sourceModel ContentTaskModel:(PicContentTaskModel *)contentTaskModel {
    NSString *targetPath = [[PDDownloadManager sharedPDDownloadManager] getDirPathWithSource:sourceModel contentModel:contentTaskModel];

    NSOperationQueue *queue = [ContentParserManager sharedContentParserManager].queue;

    // 防止任务数过多导致的压力
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
        [contentTaskModel updateTableWithStatus];

        [queue addOperationWithBlock:^{

            //创建信号量并设置计数默认为0
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            NSFileHandle *targetHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
            // 网页请求获取一组套图, 创建下载任务
            [ContentParserManager dealWithUrl:contentTaskModel.href targetHandle:targetHandle pageCount:1 picCount:0 WithSourceModel:sourceModel ContentTaskModel:contentTaskModel taskCompleteHandler:^{

                dispatch_semaphore_signal(sema);
                // 我们需要做一个操作, 是让他继续下一个任务
                [ContentParserManager prepareToDoNextTask];
            }];
            //若计数为0则一直等待
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }];
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

                NSDictionary *result = [ContentParserManager dealWithHtmlData:content WithSourceModel:sourceModel ContentTaskModel:contentTaskModel picCount:picCount];
                nextUrl = result[@"nextUrl"];
                if (nextUrl.length > 0) {
                    nextUrl = [url stringByReplacingOccurrencesOfString:url.lastPathComponent withString:nextUrl];
                }
                NSError *writeError = nil;
                count = [result[@"count"] intValue];
                [targetHandle seekToEndOfFile];
                [targetHandle writeData:[[NSString stringWithFormat:@"\n%@", result[@"urls"]] dataUsingEncoding:NSUTF8StringEncoding] error:&writeError];
//                [targetHandle writeData:[[NSString stringWithFormat:@"\n%@", [NSURL URLWithString:result[@"urls"] relativeToURL:baseURL].absoluteString] dataUsingEncoding:NSUTF8StringEncoding] error:&writeError];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTICECHEADDNEWDETAILTASK object:nil userInfo:@{@"contentModel": contentTaskModel}];
                if (writeError) {
                    NSLog(@"%@, 出现错误-2, %@", [NSURL URLWithString:url relativeToURL:baseURL].absoluteString, writeError);
                }
            } else {
                NSLog(@"第%d页, %@, 出现错误-1, %@", pageCount, [NSURL URLWithString:url relativeToURL:baseURL].absoluteString, error);
            }

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
+ (NSDictionary *)dealWithHtmlData:(NSString *)htmlString WithSourceModel:(PicSourceModel *)sourceModel ContentTaskModel:(PicContentTaskModel *)contentTaskModel picCount:(int)picCount {
    NSString *url = @"";
    NSMutableString *urlsString = [NSMutableString string];
    int count = 0;
    if (htmlString.length > 0) {

        OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];
        NSMutableArray *urls = [NSMutableArray array];
        NSMutableArray *suggestNames = [NSMutableArray array];
        
        OCGumboElement *contentE;

        switch (sourceModel.sourceType) {
            case 1:{
                contentE = document.QueryClass(@"contents").firstObject;
            }
                break;
            case 2: {
                contentE = document.QueryClass(@"content").firstObject;
            }
            default:
                break;
        }

        OCQueryObject *es = contentE.Query(@"img");
        NSInteger index = 1;
        for (OCGumboElement *e in es) {
            NSString *src = e.attr(@"src");
            if (src.length > 0) {
                [urls addObject:src];
                [suggestNames addObject:[NSString stringWithFormat:@"%ld.jpg", picCount + index]];
                index ++;
                [urlsString appendFormat:@"%@\n", src];
            }
        }

        OCGumboElement *nextE;

        switch (sourceModel.sourceType) {
            case 1:{
                nextE = document.QueryClass(@"pageart").firstObject;
            }
                break;
            case 2: {
                nextE = document.QueryClass(@"page-tag").firstObject;
            }
            default:
                break;
        }

        BOOL find = NO;
        if (nextE) {
            OCQueryObject *aEs = nextE.QueryElement(@"a");
            for (OCGumboElement *aE in aEs) {
                if ([aE.text() isEqualToString:@"下一页"]) {
                    find = YES;
                    NSString *nextPage = aE.attr(@"href");

                    url = nextPage;
                    break;
                }
            }
        }

        count += urls.count;
        // 这边没必要异步添加任务了, 就直接添加即可, 本身这个解析过程就是异步的
        [[PDDownloadManager sharedPDDownloadManager] downWithSource:sourceModel ContentTaskModel:contentTaskModel urls:[urls copy] suggestNames:suggestNames];

    }

    if (url.length == 0) {
        NSLog(@"获取到的下一个url是空的");
        url = @"";
    }

    return @{@"nextUrl" : url, @"urls" : [urlsString copy], @"count": @(count)};
}

@end
