//
//  PPCustomAsyncOperation.m
//  PPCustomAsyncOperation
//
//  Created by pengpeng on 2024/1/22.
//

#import "PPCustomAsyncOperation.h"

@interface PPCustomAsyncOperation ()

@property(nonatomic, assign, readonly) BOOL hasStart;

@property(nonatomic, assign) BOOL operationExecuting;
@property(nonatomic, assign) BOOL operationFinished;

@end

@implementation PPCustomAsyncOperation

#pragma mark - 重写系统方法

- (void)start {
    _hasStart = YES;
    if ([self isCancelled]) {
        [self signKVOComplete];
        return;
    }

    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main)
                             toTarget:self withObject:nil];
    self.operationExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)main {
    @autoreleasepool {
        if (self.isCancelled) {
            return;
        }

        if (self.mainOperationDoBlock(self)) {
            [self finishOperation];
        }
    }
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    if (self.operationExecuting) {
        NSLog(@"---------%@ Start---------", NSStringFromClass([self class]));
    }
    return self.operationExecuting;
}

- (BOOL)isFinished {
    if (self.operationFinished) {
        NSLog(@"---------%@ End---------", NSStringFromClass([self class]));
    }
    return self.operationFinished;
}

- (void)cancel {
    @synchronized (self) {
        [super cancel];


        if ([self isExecuting]) {
            [self finishOperation];
        }
    }
}

#pragma mark - 自定义方法

- (void)finishOperation {
    @synchronized (self) {
        if (!self.operationExecuting && self.operationFinished) {
            return;
        }

        if (_hasStart) {
            [self signKVOComplete];
        }
    }
}

- (void)signKVOComplete {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];

    self.operationExecuting = NO;
    self.operationFinished = YES;

    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)dealloc {
    NSLog(@"===== %@ dealloc; identifier: %@ ======", NSStringFromClass([self class]), self.identifier);
}

@end
