//
//  ContentParserManager+Parser.h
//  PicData
//
//  Created by 鹏鹏 on 2022/5/28.
//  Copyright © 2022 garenge. All rights reserved.
//

#import "ContentParserManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContentParserManager (Parser)

+ (NSString *)getHtmlStringWithData:(NSData *)data sourceType:(int)sourceType;

/// 解析tag列表
+ (NSArray <PicClassModel *>*)parseTagsWithHtmlString:(NSString *)htmlString HostModel:(PicNetModel *)hostModel;

@end

NS_ASSUME_NONNULL_END
