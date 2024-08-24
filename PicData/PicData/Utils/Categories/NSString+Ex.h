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

- (NSArray <NSString *>*)splitStringsWithLeadingString:(NSString *)leadingString trailingString:(NSString *)trailingString error:(NSError **)error;

+ (NSString *)fileSizeFormat:(long long)value;

+ (NSString *)getUUID;

/// 生成随机文件名
/// - Parameter pathExtension: 提供文件后缀名, 只要点后面的字符串
+ (NSString *)ht_getRandomFileNameWithPathExtension:(NSString *)pathExtension;

/// 生成随机文件名 - 按格式
/// - Parameters:
///   - pathExtension: 提供文件后缀名, 只要点后面的字符串
///   - timeformat: 时间格式, 比如 yyyyMMddHHmmssSSS
///   - randomNumCount: 补充整数的位数, 比如自动补充四位整数
+ (NSString *)ht_getRandomFileNameWithPathExtension:(NSString *)pathExtension timeformat:(NSString *)timeformat randomNumCount:(NSInteger)randomNumCount;

@end

NS_ASSUME_NONNULL_END
