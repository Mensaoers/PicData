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

@end
