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

+ (PicContentModel *)getContentModelWithSourceModel:(PicSourceModel *)sourceModel withArticleElement:(OCGumboElement *)articleElement {

    OCGumboElement *aE = articleElement.QueryElement(@"a").firstObject;
    NSString *title = aE.attr(@"title");

    NSString *href = aE.attr(@"href");

    OCGumboElement *imgE;

    switch (sourceModel.sourceType) {
        case 1:
        case 2:
            imgE = aE.QueryElement(@"img").firstObject;
            break;
        case 3:
            imgE = aE.QueryClass(@"xld").firstObject;
            break;
        default:
            break;
    }

    NSString *thumbnailUrl = imgE.attr(@"src");

    PicContentModel *contentModel = [[PicContentModel alloc] init];
    contentModel.href = href;
    contentModel.sourceHref = sourceModel.url;
    contentModel.sourceTitle = sourceModel.title;
    contentModel.HOST_URL = sourceModel.HOST_URL;
    contentModel.title = title;
    contentModel.thumbnailUrl = thumbnailUrl;

    return contentModel;
}

+ (PicClassModel *)getClassModelWithHostModel:(PicNetModel *)hostModel withTagsListElement:(OCGumboElement *)tagsListE {

    OCQueryObject *aEs = tagsListE.QueryElement(@"a");

    NSMutableArray *subTitles = [NSMutableArray array];
    for (OCGumboElement *aE in aEs) {
        NSString *href = aE.attr(@"href");
        NSString *subTitle = aE.text();

        PicSourceModel *sourceModel = [[PicSourceModel alloc] init];
        sourceModel.sourceType = hostModel.sourceType;

        NSString *url;
        switch (hostModel.sourceType) {
            case 1: {
                url = [hostModel.HOST_URL stringByAppendingPathComponent:href];
            }
                break;
            case 2: {
                url = href;
            }
                break;
            default:
                break;
        }
        sourceModel.url = [hostModel.HOST_URL stringByAppendingPathComponent:href];
        sourceModel.title = subTitle;
        sourceModel.HOST_URL = hostModel.HOST_URL;
        [sourceModel insertTable];

        [subTitles addObject:sourceModel];
    }

    PicClassModel *classModel = [PicClassModel modelWithHOST_URL:hostModel.HOST_URL Title:@"标签" sourceType:hostModel.sourceType subTitles:subTitles];

    return classModel;

}

+ (NSArray <PicClassModel *>*)parseTagsWithHtmlString:(NSString *)htmlString HostModel:(PicNetModel *)hostModel {

    NSMutableArray *classModelsM = [NSMutableArray array];

    if (htmlString.length == 0) { return classModelsM; }

    OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];

    OCQueryObject *tagsListEs;
    switch (hostModel.sourceType) {
        case 1: {
            tagsListEs = document.QueryClass(@"jigou");
        }
            break;
        case 2: {
            tagsListEs = document.QueryClass(@"TagTop_Gs_r");
        }
            break;
        case 3: {

        }
            break;
        default:
            break;
    }

    for (OCGumboElement *tagsListE in tagsListEs) {

        PicClassModel *classModel = [self getClassModelWithHostModel:hostModel withTagsListElement:tagsListE];
        [classModelsM addObject:classModel];
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

                PicContentModel *contentModel = [self getContentModelWithSourceModel:sourceModel withArticleElement:articleE];

                // 部分查找结果会返回高亮语句<font color='red'>keyword</font>, 想了好几种方法, 不如直接替换了最快
                NSString *title = contentModel.title;
                title = [title stringByReplacingOccurrencesOfString:@"<font color=\'red\'>" withString:@""];
                title = [title stringByReplacingOccurrencesOfString:@"</font>" withString:@""];
                contentModel.title = title;

                [contentModel insertTable];
                [articleContents addObject:contentModel];
            }
        }
            break;
        case 2: {
            OCGumboElement *listDiv = document.QueryClass(@"listMeinuT").firstObject;
            OCQueryObject *articleEs = listDiv.QueryElement(@"li");

            for (OCGumboElement *articleE in articleEs) {

                PicContentModel *contentModel = [self getContentModelWithSourceModel:sourceModel withArticleElement:articleE];

                [contentModel insertTable];
                [articleContents addObject:contentModel];
            }
        }
            break;
        case 3: {
            OCGumboElement *listDiv = document.QueryClass(@"videos").firstObject;
            OCQueryObject *articleEs = listDiv.QueryClass(@"thcovering-video");

            for (OCGumboElement *articleE in articleEs) {

                PicContentModel *contentModel = [self getContentModelWithSourceModel:sourceModel withArticleElement:articleE];

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

    NSURL *nextPageURL = nil;

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
                nextPage = aE.attr(@"href");
                break;
            }
        }
    }

    if (nextPage.length > 0) {
        switch (sourceModel.sourceType) {
            case 1: {
                nextPageURL = [NSURL URLWithString:[sourceModel.url stringByAppendingPathComponent:nextPage]];
            }
                break;
            case 2: {
                nextPageURL = [NSURL URLWithString:[sourceModel.url stringByReplacingOccurrencesOfString:sourceModel.url.lastPathComponent withString:nextPage]];
            }
                break;
            case 3: {
                nextPageURL = [NSURL URLWithString:nextPage relativeToURL:[NSURL URLWithString:sourceModel.HOST_URL]];
            }
                break;
            default:
                break;
        }
    } else {
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

    switch (sourceModel.sourceType) {
        case 1: {

            // 推荐
            OCGumboElement *listDiv = document.QueryClass(@"w980").firstObject;
            OCQueryObject *articleEs = listDiv.QueryClass(@"post");


            for (OCGumboElement *articleE in articleEs) {

                PicContentModel *contentModel = [self getContentModelWithSourceModel:sourceModel withArticleElement:articleE];

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

                PicContentModel *contentModel = [self getContentModelWithSourceModel:sourceModel withArticleElement:articleE];

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

                PicContentModel *contentModel = [self getContentModelWithSourceModel:sourceModel withArticleElement:articleE];

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

+ (NSString *)parsePageForTitle:(NSString *)htmlString sourceModel:(PicSourceModel *)sourceModel {

    NSString *title = @"";
    if (htmlString.length > 0) {

        OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];

        switch (sourceModel.sourceType) {
            case 1: {
                OCGumboElement *divE = document.QueryClass(@"Title9").firstObject;
                OCGumboElement *h9E = divE.childNodes.firstObject;
                title = h9E.text();
            }
                break;
            case 2: {
                OCGumboElement *h1E = document.QueryClass(@"articleV4Tit").firstObject;
                title = h1E.text();
            }
                break;
            case 3: {
                OCGumboElement *headE = document.QueryElement(@"head").firstObject;
                OCGumboElement *titleE = headE.QueryElement(@"title").firstObject;
                if (titleE) {
                    NSString *title1 = titleE.text();
                    // title1 => "Hit-x-Hot: Vol. 4832 可乐Vicky | Page 1/5"
                    NSString *regex = @"(?<=Hit-x-Hot: ).*?(?= | Page)";
                    NSError *error;
                    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
                    // 对str字符串进行匹配
                    NSString *title2 = [title1 substringWithRange:[regular firstMatchInString:title1 options:0 range:NSMakeRange(0, title1.length)].range];
                    title = title2;
                }
            }
            default:
                break;
        }
    }

    return title ?: @"";
}

@end
