//
//  PPCatalystHandle.h
//  PPCatalystTool
//
//  Created by 鹏鹏 on 2022/10/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PPCatalystHandle : NSObject

- (void)showLog;

+ (PPCatalystHandle *)sharedPPCatalystHandle;

- (NSNumber *)openFileOrDirWithPath:(nonnull NSString *)path;
- (nullable NSURL *)selectSingleFileWithFolderPath:(nonnull NSString *)folderPath;
- (nullable NSURL *)selectFolderWithPath:(nonnull NSString *)folderPath;

@end

NS_ASSUME_NONNULL_END
