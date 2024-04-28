//
//  NSFileManager+Ex.h
//  PicData
//
//  Created by Garenge on 2024/4/28.
//  Copyright © 2024 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (Ex)

/// 如果失败, 返回-1, 单位: byte
- (long long)getFileSize:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
