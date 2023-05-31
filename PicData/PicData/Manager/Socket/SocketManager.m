//
//  SocketManager.m
//  PicData
//
//  Created by Garenge on 2023/5/29.
//  Copyright © 2023 garenge. All rights reserved.
//

#import "SocketManager.h"

@interface SocketManager() <GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;

@end

@implementation SocketManager

singleton_implementation(SocketManager)

- (GCDAsyncSocket *)socket {
    if (nil == _socket) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _socket;
}

- (void)connect {
    if (!self.socket.isConnected) {
        NSError *error = nil;
        [self.socket connectToHost:@"127.0.0.1" onPort:12138 error:&error];
        if (error) {
            NSLog(@"SocketManager: 连接socket服务器失败, 请先打开DataDemo");
        }
    } else {
        [self sendMessage:@"Hello, dataDemo!"];
    }
}

- (void)sendMessage:(NSString *)message {
    SocketMessageModel *model = [[SocketMessageModel alloc] initWithEvent:@"Test"];
    model.message = message;
    NSData *data = [model.toString dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:data withTimeout:-1 tag:10086];
    NSLog(@"SocketManager: 已发送消息: %@, tag: %d", model.toString, 10086);
}

#pragma mark - func
- (void)scan {
    SocketMessageModel *model = [[SocketMessageModel alloc] initWithEvent:@"scan"];
    NSData *data = [model.toString dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:data withTimeout:-1 tag:10086];
    NSLog(@"SocketManager: 已发送消息: %@, tag: %d", model.toString, 10086);
}

#pragma mark - delegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"SocketManager: 已连接: %@, port: %d", host, port);
    [self.socket readDataWithTimeout:-1 tag:10086];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"SocketManager: 已断开连接: %@", err);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"SocketManager: 已收到消息: %@, tag: %ld", string, tag);
    [self.socket readDataWithTimeout:-1 tag:10086];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"SocketManager: 已发送消息, tag: %ld", tag);
}

@end
