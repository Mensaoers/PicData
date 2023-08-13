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

@end
