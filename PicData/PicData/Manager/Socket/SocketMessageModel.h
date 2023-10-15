//
//  SocketMessageModel.h
//  PicData
//
//  Created by Garenge on 2023/5/29.
//  Copyright © 2023 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SocketMessageModel : NSObject

@property (nonatomic, strong) NSString *message; // 事件用到的值

/// 非空 事件名称
@property (nonatomic, strong) NSString *event; // 事件字符串
@property (nonatomic, strong) NSString *mark; // 备注

//- (instancetype)init NS_UNAVAILABLE;
- (instancetype)init __attribute__((unavailable("请使用initWithEvent:")));
- (instancetype)initWithEvent:(NSString *)event NS_DESIGNATED_INITIALIZER;

- (NSString *)description; // 同 toString
- (NSString *)toString;

@end

NS_ASSUME_NONNULL_END
