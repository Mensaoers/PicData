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

@end
