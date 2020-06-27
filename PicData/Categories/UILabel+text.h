//
//  UILabel+text.h
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (text)

///根据宽度计算文字的高度
-(CGFloat)textheight:(NSString *)string;

///根据高度计算文字的宽度
-(CGFloat)textWidth:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
