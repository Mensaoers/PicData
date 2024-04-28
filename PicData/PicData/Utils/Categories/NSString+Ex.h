//
//  NSString+Ex.h
//  PicData
//
//  Created by 鹏鹏 on 2022/8/22.
//  Copyright © 2022 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Ex)

/// 提取指定字符串中间的字符串, 比如 "-abc-" -> "abc"
- (NSString *)splitStringWithLeadingString:(NSString *)leadingString trailingString:(NSString *)trailingString error:(NSError **)error;

+ (NSString *)fileSizeFormat:(long long)value;

+ (NSString *)getUUID;

@end

NS_ASSUME_NONNULL_END
