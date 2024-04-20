//
//  PPCustomAsyncOperation.h
//  PPCustomAsyncOperation
//
//  Created by pengpeng on 2024/1/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PPCustomAsyncOperation : NSOperation

@property (nonatomic, strong) NSString *identifier;

/// 手动结束任务
- (void)finishOperation;

/// what you do in operation. You must call - (void)finishOperation to finish the operation if return NO.
/// "No" for async, "YES" for sync.
@property (nonatomic, copy) BOOL(^mainOperationDoBlock)(PPCustomAsyncOperation *operation);

@end

NS_ASSUME_NONNULL_END
