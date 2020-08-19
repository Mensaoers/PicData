//
//  ContentParserManager.m
//  PicData
//
//  Created by Garenge on 2020/4/20.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "ContentParserManager.h"
#import "PDDownloadManager.h"

@implementation ContentParserManager

+ (void)tryToAddTaskWithSourceModel:(PicSourceModel *)sourceModel ContentModel:(PicContentModel *)contentModel needDownload:(BOOL)needDownload operationTips:(void (^)(BOOL, NSString * _Nonnull))operationTips {
    NSArray *results = [JKSqliteModelTool queryDataModel:[PicContentModel class] whereStr:[NSString stringWithFormat:@"href = \"%@\"", contentModel.href] uid:SQLite_USER];
    // 理论上一定有一条数据
    if (results.count == 0) {
        operationTips(NO, [NSString stringWithFormat:@"获取该内容: %@-%@ 数据异常", contentModel.sourceTitle, contentModel.title]);
        return;
    }
    PicContentModel *tmpModel = results[0];
    if (tmpModel.hasAdded) {
        operationTips(YES, @"任务已存在");
    } else {
        tmpModel.hasAdded = YES;
        [JKSqliteModelTool saveOrUpdateModel:tmpModel uid:SQLite_USER];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTICECHEADDNEWTASK object:nil userInfo:@{@"contentTitle": tmpModel.title, @"contentHref": tmpModel.href}];
//        ContentParserManager *manager = [[ContentParserManager alloc] init];
            [ContentParserManager parserWithSourceModel:sourceModel ContentModel:contentModel needDownload:YES];
//        });
        operationTips(YES, @"任务已添加");
    }
}

+ (void)parserWithSourceModel:(PicSourceModel *)sourceModel ContentModel:(PicContentModel *)contentModel needDownload:(BOOL)needDownload {
    NSString *targetPath = [[PDDownloadManager sharedPDDownloadManager] getDirPathWithSource:sourceModel contentModel:contentModel];
    
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2.设置最大并发操作数
    queue.maxConcurrentOperationCount = 1; // 串行队列
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
    
    NSFileHandle *targetHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];

    [self operationQueue:queue withUrl:contentModel.href targetHandle:targetHandle pageCount:1 picCount:0 WithSourceModel:sourceModel ContentModel:contentModel needDownload:needDownload];
}

+ (void)operationQueue:(NSOperationQueue *)queue withUrl:(NSString *)url targetHandle:(NSFileHandle *)targetHandle pageCount:(int)pageCount picCount:(int)picCount WithSourceModel:(PicSourceModel *)sourceModel ContentModel:(PicContentModel *)contentModel needDownload:(BOOL)needDownload {
//    __weak typeof(self) weakSelf = self;
    // 错误-1, 网络部分错误
    // 错误-2, 写入部分错误
    if ([url containsString:@".html"]) {
        [queue addOperationWithBlock:^{
//            __strong typeof(self) strongSelf = weakSelf;
            NSError *error = nil;
            NSURL *baseURL = [NSURL URLWithString:sourceModel.HOST_URL];
            NSString *content = [NSString stringWithContentsOfURL:[NSURL URLWithString:url relativeToURL:baseURL] encoding:NSUTF8StringEncoding error:&error];
            NSString *nextUrl = @"";
            int count = 0;
            if (error) {
                NSLog(@"第%d页, %@, 出现错误-1, %@", pageCount, [NSURL URLWithString:url relativeToURL:baseURL].absoluteString, error);
            } else {
                NSLog(@"第%d页, %@, 完成", pageCount, [NSURL URLWithString:url relativeToURL:baseURL].absoluteString);
                
                NSDictionary *result = [ContentParserManager dealWithHtmlData:content WithSourceModel:sourceModel ContentModel:contentModel needDownload:needDownload];
                nextUrl = result[@"nextUrl"];
                NSError *writeError = nil;
                count = [result[@"count"] intValue];
                [targetHandle writeData:[[NSString stringWithFormat:@"\n%@", [NSURL URLWithString:result[@"urls"] relativeToURL:baseURL].absoluteString] dataUsingEncoding:NSUTF8StringEncoding]];
                if (writeError) {
                    NSLog(@"%@, 出现错误-2, %@", [NSURL URLWithString:url relativeToURL:baseURL].absoluteString, writeError);
                }
            }

            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTICECHEADDNEWDETAILTASK object:nil userInfo:@{@"contentHref": contentModel.href, @"contentCount": @(picCount + count)}];
            if (![nextUrl containsString:@".html"]) {
                [targetHandle closeFile];
                NSLog(@"完成");
            } else {
                [ContentParserManager operationQueue:queue withUrl:nextUrl targetHandle:targetHandle pageCount:pageCount + 1 picCount:picCount + count WithSourceModel:sourceModel ContentModel:contentModel needDownload:needDownload];
            }
        }];
    }
}

+ (NSDictionary *)dealWithHtmlData:(NSString *)htmlString WithSourceModel:(PicSourceModel *)sourceModel ContentModel:(PicContentModel *)contentModel needDownload:(BOOL)needDownload {
    NSString *url = @"";
    NSMutableString *urlsString = [NSMutableString string];
    int count = 0;
    if (htmlString.length > 0) {
        
        OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];
        //        OCGumboElement *root = document.rootElement;
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
                        src = [src stringByReplacingOccurrencesOfString:@"img.aitaotu.cc:8089" withString:@"wapimg.aitaotu.cc:8090"];
//                        src = [src stringByReplacingOccurrencesOfString:@"wapimg.aitaotu.cc:8090" withString:@"img.aitaotu.cc:8089"];
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
                            src = [src stringByReplacingOccurrencesOfString:@"img.aitaotu.cc:8089" withString:@"wapimg.aitaotu.cc:8090"];
//                            src = [src stringByReplacingOccurrencesOfString:@"wapimg.aitaotu.cc:8090" withString:@"img.aitaotu.cc:8089"];
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
        
        if (needDownload) {
            count += urls.count;
            [[PDDownloadManager sharedPDDownloadManager] downWithSource:sourceModel contentModel:contentModel urls:[urls copy]];
        }
    }
    
    if (url.length == 0) {
        NSLog(@"获取到的下一个url是空的");
    }

    return @{@"nextUrl" : url, @"urls" : [urlsString copy], @"count": @(count)};
}

@end
