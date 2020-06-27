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

singleton_implementation(ContentParserManager);

- (void)parserWithSourceModel:(PicSourceModel *)sourceModel ContentModel:(PicContentModel *)contentModel needDownload:(BOOL)needDownload {
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

    [self operationQueue:queue withUrl:contentModel.href targetHandle:targetHandle count:1 relativeToURL:[NSURL URLWithString:HOST_URL] WithSourceModel:sourceModel ContentModel:contentModel needDownload:needDownload];
}

- (void)operationQueue:(NSOperationQueue *)queue withUrl:(NSString *)url targetHandle:(NSFileHandle *)targetHandle count:(int)count relativeToURL:(NSURL *)baseURL WithSourceModel:(PicSourceModel *)sourceModel ContentModel:(PicContentModel *)contentModel needDownload:(BOOL)needDownload {
    __weak typeof(self) weakSelf = self;
    // 错误-1, 网络部分错误
    // 错误-2, 写入部分错误
    if ([url containsString:@".html"]) {
        [queue addOperationWithBlock:^{
            NSError *error = nil;
            NSString *content = [NSString stringWithContentsOfURL:[NSURL URLWithString:url relativeToURL:baseURL] encoding:NSUTF8StringEncoding error:&error];
            NSString *nextUrl = @"";
            if (error) {
                NSLog(@"第%d页, %@, 出现错误-1, %@", count, [NSURL URLWithString:url relativeToURL:baseURL].absoluteString, error);
            } else {
                NSLog(@"第%d页, %@, 完成", count, [NSURL URLWithString:url relativeToURL:baseURL].absoluteString);
                
                NSDictionary *result = [self dealWithHtmlData_xunqinji:content WithSourceModel:sourceModel ContentModel:contentModel needDownload:needDownload];
                nextUrl = result[@"nextUrl"];
                NSError *writeError = nil;
                [targetHandle writeData:[[NSString stringWithFormat:@"\n%@", [NSURL URLWithString:result[@"urls"] relativeToURL:baseURL].absoluteString] dataUsingEncoding:NSUTF8StringEncoding]];
                if (writeError) {
                    NSLog(@"%@, 出现错误-2, %@", [NSURL URLWithString:url relativeToURL:baseURL].absoluteString, writeError);
                }
            }
            if (![nextUrl containsString:@".html"]) {
                [targetHandle closeFile];
                NSLog(@"完成");
            } else {
                [weakSelf operationQueue:queue withUrl:nextUrl targetHandle:targetHandle count:count + 1 relativeToURL:baseURL WithSourceModel:sourceModel ContentModel:contentModel needDownload:needDownload];
            }
        }];
    }
}

- (NSDictionary *)dealWithHtmlData_xunqinji:(NSString *)htmlString WithSourceModel:(PicSourceModel *)sourceModel ContentModel:(PicContentModel *)contentModel needDownload:(BOOL)needDownload {
    NSString *url = @"";
    NSMutableString *urlsString = [NSMutableString string];
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
            [[PDDownloadManager sharedPDDownloadManager] downWithSource:sourceModel contentModel:contentModel urls:[urls copy]];
        }
    }
    
    if (url.length == 0) {
        NSLog(@"11");
    }

    return @{@"nextUrl" : url, @"urls" : [urlsString copy]};
}

@end
