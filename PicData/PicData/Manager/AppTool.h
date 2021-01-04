//
//  AppTool.h
//  PicData
//
//  Created by Garenge on 2021/1/5.
//  Copyright © 2021 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppTool : NSObject

/// 获取当前是否支持横屏
+ (BOOL)getCanChangeOrientation;

/// 设置当前是否支持横屏
+ (BOOL)setCanChangeOrientation:(BOOL)value;

@end

NS_ASSUME_NONNULL_END
