//
//  NSString+string.m
//  PicData
//
//  Created by Garenge on 2021/3/7.
//  Copyright © 2021 garenge. All rights reserved.
//

#import "NSString+string.h"

@implementation NSString (string)

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

@end
