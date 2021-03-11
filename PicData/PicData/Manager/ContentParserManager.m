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

@property (nonatomic, strong) dispatch_queue_t disToDownQueue;

@property (nonatomic, assign) int maxConcurrentTasksLimit; // 默认为5
@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation ContentParserManager

singleton_implementation(ContentParserManager)

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
            NSFileHandle *targetHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
            [ContentParserManager dealWithUrl:contentTaskModel.href targetHandle:targetHandle pageCount:1 picCount:0 WithSourceModel:sourceModel ContentTaskModel:contentTaskModel];
        }];
        [ContentParserManager prepareToDoNextTask];
    }
}

/// 处理页面源码, 提取页面数据
+ (void)dealWithUrl:(NSString *)url targetHandle:(NSFileHandle *)targetHandle pageCount:(int)pageCount picCount:(int)picCount WithSourceModel:(PicSourceModel *)sourceModel ContentTaskModel:(PicContentTaskModel *)contentTaskModel {
    // 错误-1, 网络部分错误
    // 错误-2, 写入部分错误
    if ([url containsString:@".html"]) {
        NSError *error = nil;
        NSURL *baseURL = [NSURL URLWithString:sourceModel.HOST_URL];
        NSString *content = [NSString stringWithContentsOfURL:[NSURL URLWithString:url relativeToURL:baseURL] encoding:NSUTF8StringEncoding error:&error];
        NSString *nextUrl = @"";
        int count = 0;
        if (error) {
            NSLog(@"第%d页, %@, 出现错误-1, %@", pageCount, [NSURL URLWithString:url relativeToURL:baseURL].absoluteString, error);
        } else {
            NSLog(@"第%d页, %@, 完成", pageCount, [NSURL URLWithString:url relativeToURL:baseURL].absoluteString);

            NSDictionary *result = [ContentParserManager dealWithHtmlData:content WithSourceModel:sourceModel ContentTaskModel:contentTaskModel];
            nextUrl = result[@"nextUrl"];
            NSError *writeError = nil;
            count = [result[@"count"] intValue];
            [targetHandle writeData:[[NSString stringWithFormat:@"\n%@", [NSURL URLWithString:result[@"urls"] relativeToURL:baseURL].absoluteString] dataUsingEncoding:NSUTF8StringEncoding]];
            if (writeError) {
                NSLog(@"%@, 出现错误-2, %@", [NSURL URLWithString:url relativeToURL:baseURL].absoluteString, writeError);
            }
        }

        picCount += count;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICECHEADDNEWDETAILTASK object:nil userInfo:@{@"contentModel": contentTaskModel}];
        if (![nextUrl containsString:@".html"]) {
            [targetHandle closeFile];
            NSLog(@"完成");
            // 获取到最后一页一直到这一行, 都是同步运行, 所以下载肯定会晚于遍历结束
            contentTaskModel.totalCount = picCount;
            contentTaskModel.status = 2;
            // 遍历完成
            if (contentTaskModel.totalCount > 0 && contentTaskModel.downloadedCount == contentTaskModel.totalCount) {
                contentTaskModel.status = 3;
            }
            [contentTaskModel updateTable];
            // 我们需要做一个操作, 是让他继续下一个任务
            [ContentParserManager prepareToDoNextTask];
        } else {
            [ContentParserManager dealWithUrl:nextUrl targetHandle:targetHandle pageCount:pageCount + 1 picCount:picCount WithSourceModel:sourceModel ContentTaskModel:contentTaskModel];
        }
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

        OCQueryObject *liResults = document.Query(@".tal");
        if (liResults.count > 0) {
            OCGumboElement *liE = [liResults firstObject];
            OCQueryObject *aEs = liE.Query(@"a");
            for (OCGumboElement *aE in aEs) {
                NSString *href = aE.attr(@"href");
                if (href.length > 0 && [href.lastPathComponent containsString:@"_"]) {
                    url = href;
                }
                
                OCQueryObject *imgEs = aE.Query(@"img");
                if (imgEs.count > 0) {
                    OCGumboElement *imgE = imgEs.firstObject;
                    NSString *src = imgE.attr(@"src");
                    if (src.length > 0) {
                        // img.aitaotu.cc:8089 是大图
                        // wapimg.aitaotu.cc:8090 是小图
                        src = [src stringByReplacingOccurrencesOfString:@"wapimg.aitaotu.cc:8090" withString:@"img.aitaotu.cc:8089"];
                        [urls addObject:src];
                        if (urlsString.length > 0) {
                            [urlsString appendString:@"\n"];
                        }
                        [urlsString appendFormat:@"%@", src];
                    }
                }
            }
        } else {
            OCQueryObject *picResults = document.Query(@".big-pic");
            if (picResults.count > 0) {
                OCGumboElement *divE = [picResults firstObject];
                OCQueryObject *aEs = divE.Query(@"a");
                for (OCGumboElement *aE in aEs) {
                    NSString *href = aE.attr(@"href");
                    if (href.length > 0 && [href.lastPathComponent containsString:@"_"]) {
                        url = href;
                    }
                    
                    OCQueryObject *imgEs = aE.Query(@"img");
                    if (imgEs.count > 0) {
                        OCGumboElement *imgE = imgEs.firstObject;
                        NSString *src = imgE.attr(@"src");
                        if (src.length > 0) {
                            // img.aitaotu.cc:8089 是大图
                            // wapimg.aitaotu.cc:8090 是小图
                            src = [src stringByReplacingOccurrencesOfString:@"wapimg.aitaotu.cc:8090" withString:@"img.aitaotu.cc:8089"];
                            [urls addObject:src];
                            if (urlsString.length > 0) {
                                [urlsString appendString:@"\n"];
                            }
                            [urlsString appendFormat:@"%@", src];
                        }
                    }
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
