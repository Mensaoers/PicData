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
        case 3:
        case 4:
        case 10:
            return [AppTool getStringWithUTF8Code:data];
            break;
        default:
            break;
    }
    return @"";
}

#pragma mark - 开始处理, 获取套图数组
/// 开放接口, 获取套图数组, 以及下一页等
+ (void)parseContentListWithHtmlString:(NSString *)htmlString sourceModel:(nonnull PicSourceModel *)sourceModel completeHandler:(void(^)(NSArray <PicContentModel *>* _Nonnull contentList, NSURL * _Nullable nextPageURL))completeHandler {

    if (htmlString.length == 0) {
        PPIsBlockExecute(completeHandler, @[], nil);
        return;
    }
    
    OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];

    // 获取套图数组, 看这里
    NSArray *results = [self parseContentListWithDocument:document sourceModel:sourceModel];

    NSURL *nextPageURL = nil;

    OCGumboElement *nextE;

    switch (sourceModel.sourceType) {
        case 3: {
            nextE = document.QueryClass(@"pag").firstObject;
        }
            break;
        case 4: {
            nextE = document.QueryClass(@"page").firstObject;
        }
            break;
        case 10: {
            nextE = document.QueryClass(@"pagination-next").firstObject;
        }
            break;
        default:
            break;
    }

    NSString *nextPage = @"";
    
    if (nextE) {
        switch (sourceModel.sourceType) {
            case 10: {
                nextPage = nextE.attr(@"href");
            }
                break;
            default: {
                OCQueryObject *aEs = nextE.QueryElement(@"a");
                
                NSString *nextPageTitle = @"下一页";
                switch (sourceModel.sourceType) {
                    case 3:
                        nextPageTitle = @"Next »";
                        break;
                    case 4:
                        nextPageTitle = @"下页";
                        break;
                    case 10:
                        nextPageTitle = @"Next";
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
                break;
        }
    }

    if (nextPage.length > 0) {
        switch (sourceModel.sourceType) {
            case 3:
            case 4:
            case 10: {
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

/// 获取套图列表
+ (NSArray<PicContentModel *> *)parseContentListWithDocument:(OCGumboDocument *)document sourceModel:(PicSourceModel *)sourceModel {

    NSMutableArray *articleContents = [NSMutableArray array];
    OCQueryObject *articleEs;

    switch (sourceModel.sourceType) {
        case 3: {
            OCGumboElement *listDiv = document.QueryID(@"content").firstObject;
            articleEs = listDiv.QueryElement(@"article");
        }
            break;
        case 4:{
            OCGumboElement *listDiv = document.QueryClass(@"update_area_content").firstObject;
            articleEs = listDiv.QueryClass(@"i_list");
        }
            break;
        case 5: {
            OCGumboElement *listDiv = document.QueryClass(@"list").firstObject;
            if(nil == listDiv) {return @[];}
            articleEs = listDiv.QueryClass(@"piece");
        }
            break;
        case 10: {
            NSMutableArray *array = [NSMutableArray array];
            for (OCGumboElement *listDiv in document.QueryClass(@"blog")) {
                [array addObjectsFromArray:listDiv.QueryClass(@"items-row")];
            }
            articleEs = (OCQueryObject *)array;
        }
            break;
        default:
            break;
    }

    for (OCGumboElement *articleE in articleEs) {

        PicContentModel *contentModel = [self getContentModelWithSourceModel:sourceModel withArticleElement:articleE];
        if (nil == contentModel) { continue; }
        [contentModel insertTable];
        [articleContents addObject:contentModel];
    }

    return [articleContents copy];
}

#pragma mark 获取单个套图的信息
/// 获取单个套图的信息
+ (PicContentModel *)getContentModelWithSourceModel:(PicSourceModel *)sourceModel withArticleElement:(OCGumboElement *)articleElement {

    OCGumboElement *aE = articleElement.QueryElement(@"a").firstObject;
    if (nil == aE) { return nil; }
    OCGumboElement *imgE;
    NSString *href = aE.attr(@"href");
    NSString *title = aE.attr(@"title");
    switch (sourceModel.sourceType) {
        case 10:{
            imgE = aE.QueryElement(@"img").firstObject;
            title = imgE.attr(@"alt");
        }
            break;
        case 3: {
            imgE = articleElement.QueryElement(@"img").firstObject;
            title = aE.text();
        }
            break;
        case 4: {
            imgE = aE.QueryElement(@"img").firstObject;
            OCGumboElement *tE = articleElement.QueryClass(@"meta-title").firstObject;
            title = tE.text();
        }
            break;
        default:
            break;
    }
    if (imgE == nil) { return nil; }
    

    title = [self updateCustomContentName:title contentHref:href sourceModel:sourceModel];

    NSString *thumbnailUrl = imgE.attr(@"src");
    thumbnailUrl = [thumbnailUrl stringByReplacingOccurrencesOfString:@"i0.wp.com/" withString:@""];

    PicContentModel *contentModel = [[PicContentModel alloc] init];
    contentModel.href = href;
    contentModel.sourceType = sourceModel.sourceType;
    contentModel.sourceHref = sourceModel.url;
    contentModel.referer = sourceModel.referer;
    contentModel.sourceTitle = sourceModel.title;
    contentModel.HOST_URL = sourceModel.HOST_URL;
    contentModel.title = title;
    contentModel.thumbnailUrl = thumbnailUrl;

    return contentModel;
}

#pragma mark 开始解析网页详情数据
/// 开始解析网页详情数据
+ (void)parseDetailWithHtmlString:(NSString *)htmlString href:(NSString *)href sourceModel:(PicSourceModel *)sourceModel preNextUrl:(NSString *)preNextUrl needSuggest:(BOOL)needSuggest completeHandler:(void (^)(NSArray<NSString *> * _Nonnull, NSString * _Nonnull, NSArray<PicContentModel *> * _Nullable, NSString * _Nullable))completeHandler {

    if (htmlString.length == 0) {
        PPIsBlockExecute(completeHandler, @[], @"", @[], @"");
        return;
    }

    OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];

    NSMutableArray *urls = [NSMutableArray array];
    NSMutableArray *suggesM = [NSMutableArray array];

    OCGumboElement *contentE;

    switch (sourceModel.sourceType) {
        case 3: {
            contentE = document.QueryClass(@"entry-content").firstObject;
        }
            break;
        case 4: {
            contentE = document.QueryClass(@"content").firstObject;
        }
            break;
        case 10: {
            contentE = document.QueryClass(@"article-fulltext").firstObject;
        }
            break;
        default:
            break;
    }

    if (nil == contentE) {
        PPIsBlockExecute(completeHandler, @[], @"", @[], @"");
        return;
    }
    OCQueryObject *es = contentE.Query(@"img");
    for (OCGumboElement *e in es) {
        NSString *src;
        switch (sourceModel.sourceType) {
            case 3: {
                src = e.attr(@"src");
                src = [src stringByReplacingOccurrencesOfString:@"i0.wp.com/" withString:@""];
            }
                break;
            default:
                src = e.attr(@"src");
                break;
        }
        if (src.length > 0) {
            [urls addObject:src];
        }
    }

    OCGumboElement *nextE;

    switch (sourceModel.sourceType) {
        case 3: {
            nextE = document.QueryClass(@"page-numbers").firstObject;
        }
            break;
        case 4: {
            nextE = document.QueryClass(@"page").firstObject;
        }
            break;
        case 10: {
            nextE = document.QueryClass(@"pagination-list").firstObject;
        }
        default:
            break;
    }

    NSString *nextPage = @"";
    if (nextE) {
        OCQueryObject *aEs = nextE.QueryElement(@"a");

        switch (sourceModel.sourceType) {
            case 10: {
                NSInteger count = aEs.count;
                NSInteger currentIndex = -1;
                for (NSInteger index = 0; index < count; index ++) {
                    OCGumboElement *aE = aEs[index];
                    if ([aE.attr(@"class") containsString:@"is-current"]) {
                        currentIndex = index;
                        break;
                    }
                }
                if (currentIndex >= 0 && currentIndex < count - 1) {
                    OCGumboElement *aE = aEs[currentIndex + 1];
                    nextPage = aE.attr(@"href");
                }
            }
                break;
                
            default: {
                NSString *nextPageTitle = @"下一页";
                switch (sourceModel.sourceType) {
                    case 3:
                        nextPageTitle = @"Next >";
                        break;
                    case 4:
                        nextPageTitle = @"下页";
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
                break;
        }
    }

    if (nextPage.length > 0) {
        switch (sourceModel.sourceType) {
            case 3: {
                nextPage = [NSURL URLWithString:nextPage relativeToURL:[NSURL URLWithString:sourceModel.HOST_URL]].absoluteString;
            }
                break;
            case 4: {
                nextPage = [NSURL URLWithString:nextPage relativeToURL:[NSURL URLWithString:sourceModel.HOST_URL]].absoluteString;
            }
                break;
            default:
                break;
        }
    } else {
        nextPage = @"";
    }

    NSString *contentTitle = [self parsePageForTitleWithDocument:document href:href sourceModel:sourceModel];

    if (!needSuggest) {
        PPIsBlockExecute(completeHandler, urls, nextPage, suggesM, contentTitle);
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
        case 3: {

            // 推荐
            OCGumboElement *listDiv = document.QueryID(@"recent-posts-2").firstObject;
            OCQueryObject *articleEs = listDiv.QueryID(@"li");

            for (OCGumboElement *articleE in articleEs) {

                PicContentModel *contentModel = [self getContentModelWithSourceModel:sourceModel withArticleElement:articleE];

                [contentModel insertTable];
                [suggesM addObject:contentModel];
            }
        }
            break;
        case 4: {

            // 推荐
            OCGumboElement *listDiv = document.QueryClass(@"update_area_lists").firstObject;
            OCQueryObject *articleEs = listDiv.QueryClass(@"i_list");

            for (OCGumboElement *articleE in articleEs) {

                PicContentModel *contentModel = [self getContentModelWithSourceModel:sourceModel withArticleElement:articleE];

                [contentModel insertTable];
                [suggesM addObject:contentModel];
            }
        }
            break;
        case 10: {

            // 推荐
            NSMutableArray *array = [NSMutableArray array];
            for (OCGumboElement *listDiv in document.QueryClass(@"blog")) {
                [array addObjectsFromArray:listDiv.QueryClass(@"items-row")];
            }
            OCQueryObject *articleEs = (OCQueryObject *)array;

            for (OCGumboElement *articleE in articleEs) {

                PicContentModel *contentModel = [self getContentModelWithSourceModel:sourceModel withArticleElement:articleE];
                if (nil == contentModel) { continue; }
                [contentModel insertTable];
                [suggesM addObject:contentModel];
            }
        }
            break;
        default:
            break;
    }

    PPIsBlockExecute(completeHandler, urls, nextPage, suggesM, contentTitle);

}

#pragma mark tag, 标签数据

/// 解析tag标签页, 获取tag数组
+ (NSArray <PicClassModel *>*)parseTagsWithHtmlString:(NSString *)htmlString HostModel:(PicNetModel *)hostModel {

    NSMutableArray *classModelsM = [NSMutableArray array];

    if (htmlString.length == 0) { return classModelsM; }

    OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];

    OCQueryObject *tagsListEs;
    switch (hostModel.sourceType) {
        case 4: {
            tagsListEs = document.QueryClass(@"tag_cloud");
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

/// 获取分类, tag页面模型数据
+ (PicClassModel *)getClassModelWithHostModel:(PicNetModel *)hostModel withTagsListElement:(OCGumboElement *)tagsListE {

    OCQueryObject *aEs = tagsListE.QueryElement(@"a");

    NSMutableArray *subTitles = [NSMutableArray array];
    for (OCGumboElement *aE in aEs) {
        NSString *href = aE.attr(@"href");

        PicSourceModel *sourceModel = [[PicSourceModel alloc] init];
        sourceModel.sourceType = hostModel.sourceType;

        NSString *url;
        NSString *subTitle;
        switch (hostModel.sourceType) {
            case 4: {
                url = [[hostModel.HOST_URL stringByAppendingPathComponent:href] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                subTitle = aE.text();
            }
                break;
            default:
                break;
        }
        sourceModel.url = url;
        sourceModel.title = subTitle;
        sourceModel.HOST_URL = hostModel.HOST_URL;
        [sourceModel insertTable];

        [subTitles addObject:sourceModel];
    }

    PicClassModel *classModel = [PicClassModel modelWithHOST_URL:hostModel.HOST_URL Title:@"标签" sourceType:hostModel.sourceType subTitles:subTitles];

    return classModel;

}

/// 获取套图的title
+ (NSString *)parsePageForTitleWithDocument:(OCGumboDocument *)document href:(NSString *)href sourceModel:(PicSourceModel *)sourceModel {

    NSString *title = @"";

    switch (sourceModel.sourceType) {
        case 3: {
            OCGumboElement *headE = document.QueryElement(@"head").firstObject;
            OCGumboElement *titleE = headE.QueryElement(@"title").firstObject;
            if (titleE) {
                NSString *title1 = titleE.text();
                // title1 => "Hit-x-Hot: Vol. 4832 可乐Vicky | Page 1/5"
                if ([title1 containsString:@" | Page"]) {
                    // 对str字符串进行匹配
                    title = [title1 splitStringWithLeadingString:@" Hit-x-Hot: " trailingString:@" | Page" error:nil];
                } else {
                    title = [title1 stringByReplacingOccurrencesOfString:@" Hit-x-Hot: " withString:@""];
                }
            }
        }
            break;
        default:
            break;
    }

    title = [self updateCustomContentName:title contentHref:href sourceModel:sourceModel];

    return title;
}

/// 封装补充随机名称的代码
+ (NSString *)updateCustomContentName:(NSString *)preContentTitle contentHref:(NSString *)contentHref sourceModel:(PicSourceModel *)sourceModel {

    if (preContentTitle.length == 0) { return preContentTitle; }

    NSString *title = preContentTitle;
    NSString *href = contentHref;

    switch (sourceModel.sourceType) {
        case 3: {
            // 追加指定名称 提高唯一性
            NSString *identifier = [href.lastPathComponent stringByDeletingPathExtension];
            title = [NSString stringWithFormat:@"%@ %@", title, identifier];
        }
            break;
        case 4: break;
        case 10: {
            NSString *midString = [preContentTitle splitStringsWithLeadingString:@"\\(" trailingString:@"\\)" error:nil].lastObject;
            title = [title stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"(%@)", midString] withString:@""];
            
            NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
            title = [title stringByTrimmingCharactersInSet:whitespace];
//        https://cdn.buondua.com/wes.misskon.com/images/2024/08/24/JVID-Hana-MissKON.com-051cad39372b653975d.webp?1cfd9d65d58e14a1c23e80e9492ce6c3
            NSString *identifier = [href splitStringWithLeadingString:@".com-" trailingString:@".webp?" error:nil];
            if (identifier.length > 0) {
                title = [NSString stringWithFormat:@"%@ %@", title, identifier];
            }
        }
            break;
        default:
            break;
    }
    return title;
}

/// 解析网页获取网页title
+ (NSString *)parsePageForTitle:(NSString *)htmlString href:(NSString *)href sourceModel:(PicSourceModel *)sourceModel {

    NSString *title = @"";
    if (htmlString.length > 0) {

        OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];
        title = [self parsePageForTitleWithDocument:document href: href sourceModel:sourceModel];
    }

    return title ?: @"";
}

@end
