//
//  PicClassifyTagsFrame.h
//  TagsDemo
//
//  Created by Administrator on 16/1/21.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PicClassifyTagsFrame : NSObject
/** 标签名字数组 */
@property (nonatomic, strong) NSArray *tagsArray;
/** 标签frame数组 */
@property (nonatomic, strong) NSMutableArray *tagsFrames;
/** 全部标签的高度 */
@property (nonatomic, assign) CGFloat tagsHeight;
/** 标签间距 default is 10*/
@property (nonatomic, assign) CGFloat tagsMargin;
/** 标签行间距 default is 10*/
@property (nonatomic, assign) CGFloat tagsLineSpacing;
/** 标签最小内边距 default is 10*/
@property (nonatomic, assign) CGFloat tagsMinPadding;

@property (nonatomic, assign) CGFloat currWidth;

@end
