//
//  ContentParserManager.m
//  PicData
//
//  Created by Garenge on 2020/4/20.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "ContentParserManager.h"
#import "PDDownloadManager.h"
#import "ParseOperation.h"

@interface ContentParserManager()

@property (nonatomic, assign) int maxConcurrentTasksLimit; // 默认为5
@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation ContentParserManager

singleton_implementation(ContentParserManager)

+ (void)cancelAll {
    [ContentParserManager.sharedContentParserManager.queue cancelAllOperations];
    [PDDownloadManager.sharedPDDownloadManager cancelAllDownloads];
}

- (void)cancelDownloadsByIdentifiers:(NSArray <NSString *>*)identifiers {
    [self.queue setSuspended:YES];
    for (ParseOperation *operation in self.queue.operations) {
        if ([identifiers containsObject:operation.identifier]) {
            [operation cancel];
        }
    }

    [[PDDownloadManager sharedPDDownloadManager] cancelDownloadsByIdentifiers:identifiers];
    [self.queue setSuspended:NO];

    [ContentParserManager prepareToDoNextTask];
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
        NSLog(@"taskModel filepath: %@", targetPath);

        [taskModel insertTable];
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNameAddNewTask object:nil userInfo:@{@"contentModel": contentModel}];
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

    [NSNotificationCenter.defaultCenter addObserver:[ContentParserManager sharedContentParserManager] selector:@selector(receiveNoticeCompleteATask:) name:NotificationNameCompleteDownTask object:nil];
    [NSNotificationCenter.defaultCenter addObserver:[ContentParserManager sharedContentParserManager] selector:@selector(receiveNoticeFailedATask:) name:NotificationNameFailedDownTask object:nil];
    [NSNotificationCenter.defaultCenter addObserver:[ContentParserManager sharedContentParserManager] selector:@selector(receiveNoticeCancelTasks:) name:NotificationNameCancelDownTasks object:nil];
}

- (void)receiveNoticeCompleteATask:(NSNotification *)notification {
    [ContentParserManager prepareToDoNextTask:YES];
}

- (void)receiveNoticeFailedATask:(NSNotification *)notification {
    [ContentParserManager prepareToDoNextTask:YES];
}

- (void)receiveNoticeCancelTasks:(NSNotification *)notification {
    NSArray *identifiers = notification.userInfo[@"identifiers"];
    [self cancelDownloadsByIdentifiers:identifiers];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNameStartScaneTask object:nil userInfo:@{@"contentModel": contentTaskModel}];

//        //创建信号量并设置计数默认为0
//        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
//        {
//        // 模拟异步耗时操作
//        dispatch_semaphore_signal(sema);
//        }
//        //若计数为0则一直等待
//        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

        NSFileHandle *targetHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];

        ParseOperation *operation = [ParseOperation operationWithSourceModel:sourceModel contentTaskModel:contentTaskModel];
        operation.middleWriteHandler = ^ (NSURL *currentURL, NSString *urls) {
            NSError *writeError = nil;
            [targetHandle seekToEndOfFile];
            [targetHandle writeData:[urls dataUsingEncoding:NSUTF8StringEncoding] error:&writeError];

            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNameCompleteScaneTaskNewPage object:nil userInfo:@{@"contentModel": contentTaskModel}];
            if (writeError) {
                NSLog(@"%@, 出现错误-2, %@", currentURL.absoluteString, writeError);
            }
        };
        operation.taskCompleteHandler = ^ (int totalCount) {

            [targetHandle closeFile];
            // 获取到最后一页一直到这一行, 都是同步运行, 所以下载肯定会晚于遍历结束
            contentTaskModel.totalCount = totalCount;
            contentTaskModel.status = 2;
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNameCompleteScaneTask object:nil userInfo:@{@"contentModel": contentTaskModel}];
            // 遍历完成
            if (contentTaskModel.totalCount > 0 && contentTaskModel.downloadedCount == contentTaskModel.totalCount) {
                contentTaskModel.status = 3;
            }
            [contentTaskModel updateTable];

            // 我们需要做一个操作, 是让他继续下一个任务
            [ContentParserManager prepareToDoNextTask];
        };
        operation.identifier = contentTaskModel.href;
        [queue addOperation:operation];

        [ContentParserManager prepareToDoNextTask];
    }
}

/// 处理html标签, 创建下载图片任务开始下载
+ (NSDictionary *)dealWithHtmlData:(NSString *)htmlString nextUrl:(NSString *)nextUrl WithSourceModel:(PicSourceModel *)sourceModel ContentTaskModel:(PicContentTaskModel *)contentTaskModel picCount:(int)picCount {
    __block NSString *url = @"";
    NSMutableString *urlsString = [NSMutableString string];
    __block int count = 0;

    [self parseDetailWithHtmlString:htmlString sourceModel:sourceModel preNextUrl:nextUrl needSuggest:NO completeHandler:^(NSArray<NSString *> * _Nonnull imageUrls, NSString * _Nonnull nextPage, NSArray<PicContentModel *> * _Nullable suggestArray, NSString * _Nullable contentTitle) {

        // 这边没必要异步添加任务了, 就直接添加即可, 本身这个解析过程就是异步的
        // TODO: 这边需要思考下, 是否需要串行队列添加任务
        NSMutableArray *suggestNames = [NSMutableArray array];
        NSInteger imageCount = imageUrls.count;
        if (imageCount > 0) {
            for (NSInteger index = 1; index <= imageCount; index ++) {
                [suggestNames addObject:[NSString stringWithFormat:@"%ld.jpg", picCount + index]];
                [urlsString appendFormat:@"%@\n", imageUrls[index - 1]];
            }
        }

        count += imageCount;
        url = nextPage;

        [[PDDownloadManager sharedPDDownloadManager] downWithSource:sourceModel ContentTaskModel:contentTaskModel urls:[imageUrls copy] suggestNames:suggestNames];

    }];

    if (url.length == 0) {
        NSLog(@"获取到的下一个url是空的");
        url = @"";
    }

    return @{@"nextUrl" : url, @"urls" : [urlsString copy], @"count": @(count)};
}

@end
