//
//  CustomAsyncOperation.h
//  CustomOperation
//
//  Created by 鹏鹏 on 2022/8/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomAsyncOperation : NSOperation

@property (nonatomic, strong) NSString *identifier;

- (void)finishOperation;

/// what you do in operation. You must call - (void)finishOperation to finish the operation if return NO.
/// "No" for async, "YES" for sync.
@property (nonatomic, copy) BOOL(^mainOperationDoBlock)(CustomAsyncOperation *operation);

@end

NS_ASSUME_NONNULL_END
