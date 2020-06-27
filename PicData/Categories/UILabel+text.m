//
//  UILabel+text.m
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "UILabel+text.h"

@implementation UILabel (text)

///根据宽度计算文字的高度
- (CGFloat)textheight:(NSString *)string {
    NSString *text = string;
    UIFont *font = self.font;//跟label的字体大小一样
    CGSize size = CGSizeMake(self.frame.size.width, MAXFLOAT);//跟label的宽设置一样
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
    size = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return size.height;
}

///根据高度计算文字的宽度
- (CGFloat)textWidth:(NSString *)string {
    NSString *text = string;
    UIFont *font = self.font;//跟label的字体大小一样
    CGSize size = CGSizeMake(MAXFLOAT, self.frame.size.height);//跟label的宽设置一样
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
    size = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return size.width;
}

@end
