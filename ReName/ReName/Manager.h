//
//  Manager.h
//  ReName
//
//  Created by 鹏鹏 on 2021/6/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Manager : NSObject

+ (void)renameAllPicturesOfDirectoryAtPath:(NSString *)dirPath;

+ (void)removeAllTxtFileOfDirectoryAtPath:(NSString *)dirPath;

@end

NS_ASSUME_NONNULL_END
