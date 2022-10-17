//
//  NSString+string.h
//  PicData
//
//  Created by Garenge on 2021/3/7.
//  Copyright © 2021 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (string)

+ (NSString *)fileSizeFormat:(long long)value;

+ (NSString *)getUUID;

@end

NS_ASSUME_NONNULL_END
