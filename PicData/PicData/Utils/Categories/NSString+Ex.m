//
//  NSString+Ex.m
//  PicData
//
//  Created by 鹏鹏 on 2022/8/22.
//  Copyright © 2022 garenge. All rights reserved.
//

#import "NSString+Ex.h"

@implementation NSString (Ex)

- (NSString *)splitStringWithLeadingString:(NSString *)leadingString trailingString:(NSString *)trailingString error:(NSError **)error {
    NSString *regex = [NSString stringWithFormat:@"(?<=(%@)).*?(?=(%@))", leadingString, trailingString];
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:error];
    // 对str字符串进行匹配
    NSString *result = [self substringWithRange:[regular firstMatchInString:self options:0 range:NSMakeRange(0, self.length)].range];
    return result;
}

- (NSArray <NSString *>*)splitStringsWithLeadingString:(NSString *)leadingString trailingString:(NSString *)trailingString error:(NSError **)error {
    NSString *regex = [NSString stringWithFormat:@"(?<=(%@)).*?(?=(%@))", leadingString, trailingString];
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:error];
    // 对str字符串进行匹配
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSTextCheckingResult *match in [regular matchesInString:self options:0 range:NSMakeRange(0, self.length)]) {
        NSString *result = [self substringWithRange:match.range];
        
        [array addObject:result];
    }
    return array;
}

+ (NSString *)fileSizeFormat:(long long)value
{
    if (value < 0) {
        return @"0B";
    }

    NSString *sizeString = @"";

    NSArray *formatArray = @[@"B", @"KB", @"MB", @"GB", @"TB", @"PB"];
    NSInteger count = formatArray.count;

    NSInteger index = 0;
    double size = value;
    while (index < count && size >= 1024) {
        size = size / 1024;
        index ++;
    }

    // 输出当前 格式
    if (index == 0) {
        sizeString = [NSString stringWithFormat:@"%d%@", (int)size, formatArray[index]];
    } else {
        sizeString = [NSString stringWithFormat:@"%@%@", [self removeFloatAllZeroByString:[NSString stringWithFormat:@"%.2f", size]], formatArray[index]];
    }

    return sizeString;
}

+ (NSString*)removeFloatAllZeroByString:(NSString *)testNumber{
    NSString * outNumber = [NSString stringWithFormat:@"%@",@(testNumber.floatValue)];
    return outNumber;
}

+ (NSString *)getUUID {
    NSString * result;
    CFUUIDRef uuid;
    CFStringRef uuidStr;
    uuid = CFUUIDCreate(NULL);
    uuidStr = CFUUIDCreateString(NULL, uuid);
    result =[NSString stringWithFormat:@"%@", uuidStr];
    CFRelease(uuidStr);
    CFRelease(uuid);
    return result;
}

+ (NSString *)ht_UUID {
    return NSUUID.UUID.UUIDString;
}

/// 生成随机文件名
/// - Parameter pathExtension: 提供文件后缀名, 只要点后面的字符串
+ (NSString *)ht_getRandomFileNameWithPathExtension:(NSString *)pathExtension {
    return [self ht_getRandomFileNameWithPathExtension:pathExtension timeformat:@"yyyyMMddHHmmssSSS" randomNumCount:4];
}

/// 生成随机文件名 - 按格式
/// - Parameters:
///   - pathExtension: 提供文件后缀名, 只要点后面的字符串
///   - timeformat: 时间格式, 比如 yyyyMMddHHmmssSSS
///   - randomNumCount: 补充整数的位数, 比如自动补充四位整数
+ (NSString *)ht_getRandomFileNameWithPathExtension:(NSString *)pathExtension timeformat:(NSString *)timeformat randomNumCount:(NSInteger)randomNumCount {
    NSDateFormatter *var_dateFormatter = [[NSDateFormatter alloc] init];
    var_dateFormatter.dateFormat = timeformat;
    NSString *var_timeString = [var_dateFormatter stringFromDate:[NSDate date]];
    NSString *var_inteFormat = [NSString stringWithFormat:@"%%%ldld", randomNumCount];
    NSString *var_format = [NSString stringWithFormat:@"%%@%@.%@", var_inteFormat, pathExtension];
    NSString *var_fileName = [NSString stringWithFormat:var_format, var_timeString, arc4random() % (long)pow(10, randomNumCount)];
    return var_fileName;
}

@end
