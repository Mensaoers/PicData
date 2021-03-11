//
//  Plugin.h
//  PicData_macPlugin
//
//  Created by 鹏鹏 on 2021/3/11.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Plugin : NSObject

- (BOOL)openFileOrDirWithPath:(NSString *)path;
+ (BOOL)openFileOrDirWithPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
