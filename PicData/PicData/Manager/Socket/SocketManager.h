//
//  SocketManager.h
//  PicData
//
//  Created by Garenge on 2023/5/29.
//  Copyright © 2023 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SocketManager : NSObject

singleton_interface(SocketManager)

- (void)connect;
- (void)sendMessage:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
