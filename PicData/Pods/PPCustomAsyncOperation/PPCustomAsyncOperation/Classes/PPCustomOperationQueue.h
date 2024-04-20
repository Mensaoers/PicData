//
//  PPCustomOperationQueue.h
//  PPCustomAsyncOperation
//
//  Created by pengpeng on 2024/1/22.
//

#import <Foundation/Foundation.h>
#import "PPCustomAsyncOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface PPCustomOperationQueue : NSOperationQueue

@property (nonatomic, copy) void(^didFinishedOperationsBlock)(PPCustomOperationQueue *queue);

@end

NS_ASSUME_NONNULL_END
