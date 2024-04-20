# PPCustomAsyncOperation

[![CI Status](https://img.shields.io/travis/pengpeng/PPCustomAsyncOperation.svg?style=flat)](https://travis-ci.org/pengpeng/PPCustomAsyncOperation)
[![Version](https://img.shields.io/cocoapods/v/PPCustomAsyncOperation.svg?style=flat)](https://cocoapods.org/pods/PPCustomAsyncOperation)
[![License](https://img.shields.io/cocoapods/l/PPCustomAsyncOperation.svg?style=flat)](https://cocoapods.org/pods/PPCustomAsyncOperation)
[![Platform](https://img.shields.io/cocoapods/p/PPCustomAsyncOperation.svg?style=flat)](https://cocoapods.org/pods/PPCustomAsyncOperation)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### 使用queue
导入头文件`#import <PPCustomAsyncOperation/PPCustomOperationQueue.h>`
### 只使用operation
导入头文件`#import <PPCustomAsyncOperation/PPCustomAsyncOperation.h>`

* 正常创建queue和operation
* 同步的任务, 直接`operation.mainOperationDoBlock`中`return YES;`
* 然后如果是异步的`operation`, 可以在`operation.mainOperationDoBlock`中返回NO, 并在合适的时候, 手动结束operation, 调用`[operation finishOperation];`
* 具体的看`Example`

```
for (NSInteger index = 0; index < 20; index ++) {

    PPCustomAsyncOperation *operation = [[PPCustomAsyncOperation alloc] init];
    operation.identifier = [NSString stringWithFormat:@"ide_%ld", index];

    operation.mainOperationDoBlock = ^BOOL(PPCustomAsyncOperation * _Nonnull operation) {

        if (index % 2 == 0) {

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"operation: %ld", index);
                [operation finishOperation];
            });

            return NO;
        } else {
            NSLog(@"operation: %ld", index);
            return YES;
        }
    };

    [self.queue addOperation:operation];
}
```

## Requirements

## Installation

PPCustomAsyncOperation is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PPCustomAsyncOperation'
```

## Author

pengpeng, garenge@outlook.com

## License

PPCustomAsyncOperation is available under the MIT license. See the LICENSE file for more info.
