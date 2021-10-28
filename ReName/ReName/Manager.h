//
//  Manager.h
//  ReName
//
//  Created by 鹏鹏 on 2021/6/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Manager : NSObject

/// 重命名指定路径下的所有图片, 并且选择是否一同删除txt文档
+ (void)renameAllPicturesOfDirectoryAtPath:(NSString *)dirPath andTxtFileRemove:(BOOL)together;

@end

NS_ASSUME_NONNULL_END
