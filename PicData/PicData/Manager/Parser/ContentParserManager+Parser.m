//
//  ContentParserManager+Parser.m
//  PicData
//
//  Created by 鹏鹏 on 2022/5/28.
//  Copyright © 2022 garenge. All rights reserved.
//

#import "ContentParserManager+Parser.h"

@implementation ContentParserManager (Parser)

+ (NSString *)getHtmlStringWithData:(NSData *)data sourceType:(int)sourceType {
    switch (sourceType) {
        case 1:
        case 2:
            return [AppTool getStringWithGB_18030_2000Code:data];
            break;
        case 3:
            return [AppTool getStringWithUTF8Code:data];
        default:
            break;
    }
    return @"";
}

+ (NSArray <PicClassModel *>*)parseTagsWithHtmlString:(NSString *)htmlString HostModel:(PicNetModel *)hostModel {

    NSMutableArray *classModelsM = [NSMutableArray array];

    if (htmlString.length == 0) { return classModelsM; }

    OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];

    switch (hostModel.sourceType) {
        case 1: {

            OCQueryObject *tagsListEs = document.QueryClass(@"jigou");

            for (OCGumboElement *tagsListE in tagsListEs) {

                OCQueryObject *aEs = tagsListE.QueryElement(@"a");

                NSMutableArray *subTitles = [NSMutableArray array];
                for (OCGumboElement *aE in aEs) {
                    NSString *href = aE.attr(@"href");
                    NSString *subTitle = aE.text();

                    PicSourceModel *sourceModel = [[PicSourceModel alloc] init];
                    sourceModel.sourceType = hostModel.sourceType;
                    sourceModel.url = [hostModel.HOST_URL stringByAppendingPathComponent:href];
                    sourceModel.title = subTitle;
                    sourceModel.HOST_URL = hostModel.HOST_URL;
                    [sourceModel insertTable];

                    [subTitles addObject:sourceModel];
                }

                PicClassModel *classModel = [PicClassModel modelWithHOST_URL:hostModel.HOST_URL Title:@"标签" sourceType:hostModel.sourceType subTitles:subTitles];
                [classModelsM addObject:classModel];
            }
        }
            break;
        case 2: {
            OCQueryObject *tagsListEs = document.QueryClass(@"TagTop_Gs_r");

            for (OCGumboElement *tagsListE in tagsListEs) {

                OCQueryObject *aEs = tagsListE.QueryElement(@"a");

                NSMutableArray *subTitles = [NSMutableArray array];
                for (OCGumboElement *aE in aEs) {
                    NSString *href = aE.attr(@"href");
                    NSString *subTitle = aE.text();

                    PicSourceModel *sourceModel = [[PicSourceModel alloc] init];
                    sourceModel.sourceType = hostModel.sourceType;
                    sourceModel.url = href;// [self.host_url stringByAppendingPathComponent:href];
                    sourceModel.title = subTitle;
                    sourceModel.HOST_URL = hostModel.HOST_URL;
                    [sourceModel insertTable];

                    [subTitles addObject:sourceModel];
                }

                PicClassModel *classModel = [PicClassModel modelWithHOST_URL:hostModel.HOST_URL Title:@"标签" sourceType:hostModel.sourceType subTitles:subTitles];
                [classModelsM addObject:classModel];
            }
        }
            break;
        case 3: {

        }
            break;
        default:
            break;
    }

    return classModelsM;
}

+ (NSArray<PicContentModel *> *)parseContentListWithDocument:(OCGumboDocument *)document sourceModel:(PicSourceModel *)sourceModel {

    NSMutableArray *articleContents = [NSMutableArray array];

    switch (sourceModel.sourceType) {
        case 1: {
            OCGumboElement *listDiv = document.QueryClass(@"w1000").firstObject;
            OCQueryObject *articleEs = listDiv.QueryClass(@"post");

            for (OCGumboElement *articleE in articleEs) {

                OCGumboElement *aE = articleE.QueryElement(@"a").firstObject;
                NSString *title = aE.attr(@"title");

                // 部分查找结果会返回高亮语句<font color='red'>keyword</font>, 想了好几种方法, 不如直接替换了最快
                title = [title stringByReplacingOccurrencesOfString:@"<font color=\'red\'>" withString:@""];
                title = [title stringByReplacingOccurrencesOfString:@"</font>" withString:@""];

                NSString *href = aE.attr(@"href");

                OCGumboElement *imgE = aE.QueryElement(@"img").firstObject;
                NSString *thumbnailUrl = imgE.attr(@"src");

                PicContentModel *contentModel = [[PicContentModel alloc] init];
                contentModel.href = href;
                contentModel.sourceHref = sourceModel.url;
                contentModel.sourceTitle = sourceModel.title;
                contentModel.HOST_URL = sourceModel.HOST_URL;
                contentModel.title = title;
                contentModel.thumbnailUrl = thumbnailUrl;
                [contentModel insertTable];
                [articleContents addObject:contentModel];
            }
        }
            break;
        case 2: {
            OCGumboElement *listDiv = document.QueryClass(@"listMeinuT").firstObject;
            OCQueryObject *articleEs = listDiv.QueryElement(@"li");

            for (OCGumboElement *articleE in articleEs) {

                OCGumboElement *aE = articleE.QueryElement(@"a").firstObject;
                NSString *title = aE.attr(@"title");
                NSString *href = aE.attr(@"href");

                OCGumboElement *imgE = aE.QueryElement(@"img").firstObject;
                NSString *thumbnailUrl = imgE.attr(@"src");

                PicContentModel *contentModel = [[PicContentModel alloc] init];
                contentModel.href = href;
                contentModel.sourceHref = sourceModel.url;
                contentModel.sourceTitle = sourceModel.title;
                contentModel.HOST_URL = sourceModel.HOST_URL;
                contentModel.title = title;
                contentModel.thumbnailUrl = thumbnailUrl;
                [contentModel insertTable];
                [articleContents addObject:contentModel];
            }
        }
            break;
        case 3: {
            OCGumboElement *listDiv = document.QueryClass(@"videos").firstObject;
            OCQueryObject *articleEs = listDiv.QueryClass(@"thcovering-video");

            for (OCGumboElement *articleE in articleEs) {

                OCGumboElement *aE = articleE.QueryElement(@"a").firstObject;
                NSString *title = aE.attr(@"title");
                NSString *href = aE.attr(@"href");

                OCGumboElement *imgE = aE.QueryClass(@"xld").firstObject;
                NSString *thumbnailUrl = imgE.attr(@"src");

                PicContentModel *contentModel = [[PicContentModel alloc] init];
                contentModel.href = href;
                contentModel.sourceHref = sourceModel.url;
                contentModel.sourceTitle = sourceModel.title;
                contentModel.HOST_URL = sourceModel.HOST_URL;
                contentModel.title = title;
                contentModel.thumbnailUrl = thumbnailUrl;
                [contentModel insertTable];
                [articleContents addObject:contentModel];
            }
        }
            break;
        default:
            break;
    }

    return [articleContents copy];
}

+ (void)parseContentListWithHtmlString:(NSString *)htmlString sourceModel:(nonnull PicSourceModel *)sourceModel completeHandler:(void(^)(NSArray <PicContentModel *>* _Nonnull contentList, NSURL * _Nullable nextPageURL))completeHandler {

    if (htmlString.length == 0) {
        PPIsBlockExecute(completeHandler, @[], nil);
        return;
    }
    
    OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];

    NSArray *results = [self parseContentListWithDocument:document sourceModel:sourceModel];

    BOOL find = NO;
    NSURL *nextPageURL = nil;

    switch (sourceModel.sourceType) {
        case 1: {
            OCGumboElement *nextE = document.QueryClass(@"pageart").firstObject;
            if (nextE) {
                OCQueryObject *aEs = nextE.QueryElement(@"a");
                for (OCGumboElement *aE in aEs) {
                    if ([aE.text() isEqualToString:@"下一页"]) {
                        find = YES;
                        NSString *nextPage = aE.attr(@"href");

                        nextPageURL = [NSURL URLWithString:[sourceModel.url stringByAppendingPathComponent:nextPage]];
                        break;
                    }
                }
            }
        }
            break;
        case 2: {
            OCGumboElement *nextE = document.QueryClass(@"TagPage").firstObject;
            if (nextE) {
                OCQueryObject *aEs = nextE.QueryElement(@"a");
                for (OCGumboElement *aE in aEs) {
                    if ([aE.text() isEqualToString:@"下一页"]) {
                        find = YES;
                        NSString *nextPage = aE.attr(@"href");

                        nextPageURL = [NSURL URLWithString:[sourceModel.url stringByReplacingOccurrencesOfString:sourceModel.url.lastPathComponent withString:nextPage]];
                        break;
                    }
                }
            }
        }
            break;
        case 3: {
            OCGumboElement *nextE = document.QueryClass(@"pag").firstObject;
            if (nextE) {
                OCQueryObject *aEs = nextE.QueryElement(@"a");
                for (OCGumboElement *aE in aEs) {
                    if ([aE.text() isEqualToString:@"Next »"]) {
                        find = YES;
                        NSString *nextPage = aE.attr(@"href");

                        nextPageURL = [NSURL URLWithString:nextPage relativeToURL:[NSURL URLWithString:sourceModel.HOST_URL]];
                        break;
                    }
                }
            }
        }
            break;
        default:
            break;
    }

    if (!find) {
        nextPageURL = nil;
    }

    PPIsBlockExecute(completeHandler, results, nextPageURL)
}

+ (void)parseDetailWithHtmlString:(NSString *)htmlString sourceModel:(nonnull PicSourceModel *)sourceModel preNextUrl:(NSString *)preNextUrl needSuggest:(BOOL)needSuggest completeHandler:(void(^)(NSArray <NSString *>* _Nonnull imageUrls, NSString * _Nonnull nextPage, NSArray <PicContentModel *> * _Nullable suggestArray))completeHandler {

    if (htmlString.length == 0) {
        PPIsBlockExecute(completeHandler, @[], @"", @[]);
        return;
    }

    OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];

    NSMutableArray *urls = [NSMutableArray array];
    NSMutableArray *suggesM = [NSMutableArray array];

    OCGumboElement *contentE;

    switch (sourceModel.sourceType) {
        case 1:{
            contentE = document.QueryClass(@"contents").firstObject;
        }
            break;
        case 2: {
            contentE = document.QueryClass(@"content").firstObject;
        }
            break;
        case 3: {
            contentE = document.QueryClass(@"contentme").firstObject;
        }
            break;
        default:
            break;
    }

    OCQueryObject *es = contentE.Query(@"img");
    for (OCGumboElement *e in es) {
        NSString *src = e.attr(@"src");
        if (src.length > 0) {
            [urls addObject:src];
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
            break;
        case 3: {
            nextE = document.QueryClass(@"pag").firstObject;
        }
            break;
        default:
            break;
    }

    NSString *nextPage = @"";
    BOOL find = NO;
    if (nextE) {
        OCQueryObject *aEs = nextE.QueryElement(@"a");

        NSString *nextPageTitle = @"下一页";
        switch (sourceModel.sourceType) {
            case 1:
            case 2:
                nextPageTitle = @"下一页";
                break;
            case 3:
                nextPageTitle = @"Next >";
                break;
            default:
                break;
        }

        for (OCGumboElement *aE in aEs) {
            if ([aE.text() isEqualToString:nextPageTitle]) {
                find = YES;
                nextPage = aE.attr(@"href");
                break;
            }
        }
    }

    if (nextPage.length > 0) {
        switch (sourceModel.sourceType) {
            case 1: {
                nextPage = [preNextUrl stringByReplacingOccurrencesOfString:preNextUrl.lastPathComponent withString:nextPage];
            }
                break;
            case 2: {
                nextPage = [preNextUrl stringByReplacingOccurrencesOfString:preNextUrl.lastPathComponent withString:nextPage];
            }
                break;
            case 3: {
                nextPage = [NSURL URLWithString:nextPage relativeToURL:[NSURL URLWithString:sourceModel.HOST_URL]].absoluteString;
            }
                break;
            default:
                break;
        }
    } else {
        nextPage = @"";
    }

    if (!needSuggest) {
        PPIsBlockExecute(completeHandler, urls, nextPage, suggesM);
        return;
    }

    // TODO: contentModel这块可以封装一下
    switch (sourceModel.sourceType) {
        case 1: {

            // 推荐
            OCGumboElement *listDiv = document.QueryClass(@"w980").firstObject;
            OCQueryObject *articleEs = listDiv.QueryClass(@"post");


            for (OCGumboElement *articleE in articleEs) {

                OCGumboElement *aE = articleE.QueryElement(@"a").firstObject;
                NSString *title = aE.attr(@"title");
                NSString *href = aE.attr(@"href");

                OCGumboElement *imgE = aE.QueryElement(@"img").firstObject;
                NSString *thumbnailUrl = imgE.attr(@"src");

                PicContentModel *contentModel = [[PicContentModel alloc] init];
                contentModel.href = href;
                contentModel.sourceHref = sourceModel.url;
                contentModel.sourceTitle = sourceModel.title;
                contentModel.HOST_URL = sourceModel.HOST_URL;
                contentModel.title = title;
                contentModel.thumbnailUrl = thumbnailUrl;
                [contentModel insertTable];
                [suggesM addObject:contentModel];
            }
        }
            break;
        case 2: {

            // 推荐
            OCGumboElement *listDiv = document.QueryClass(@"articleV4PicList").firstObject;
            OCQueryObject *articleEs = listDiv.QueryElement(@"li");

            for (OCGumboElement *articleE in articleEs) {

                OCGumboElement *aE = articleE.QueryElement(@"a").firstObject;
                NSString *title = aE.attr(@"title");
                NSString *href = aE.attr(@"href");

                OCGumboElement *imgE = aE.QueryElement(@"img").firstObject;
                NSString *thumbnailUrl = imgE.attr(@"src");

                PicContentModel *contentModel = [[PicContentModel alloc] init];
                contentModel.href = href;
                contentModel.sourceHref = sourceModel.url;
                contentModel.sourceTitle = sourceModel.title;
                contentModel.HOST_URL = sourceModel.HOST_URL;
                contentModel.title = title;
                contentModel.thumbnailUrl = thumbnailUrl;
                [contentModel insertTable];
                [suggesM addObject:contentModel];
            }
        }
            break;
        case 3: {

            // 推荐
            OCGumboElement *listDiv = document.QueryClass(@"videos").firstObject;
            OCQueryObject *articleEs = listDiv.QueryClass(@"thcovering-video");

            NSMutableArray *suggesM = [NSMutableArray array];
            for (OCGumboElement *articleE in articleEs) {

                OCGumboElement *aE = articleE.QueryElement(@"a").firstObject;
                NSString *title = aE.attr(@"title");
                NSString *href = aE.attr(@"href");

                OCGumboElement *imgE = aE.QueryClass(@"xld").firstObject;
                NSString *thumbnailUrl = imgE.attr(@"src");

                PicContentModel *contentModel = [[PicContentModel alloc] init];
                contentModel.href = href;
                contentModel.sourceHref = sourceModel.url;
                contentModel.sourceTitle = sourceModel.title;
                contentModel.HOST_URL = sourceModel.HOST_URL;
                contentModel.title = title;
                contentModel.thumbnailUrl = thumbnailUrl;
                [contentModel insertTable];
                [suggesM addObject:contentModel];
            }
        }
            break;
        default:
            break;
    }

    PPIsBlockExecute(completeHandler, urls, nextPage, suggesM);

}

@end
