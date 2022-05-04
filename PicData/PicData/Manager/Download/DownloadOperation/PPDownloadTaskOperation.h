//
//  PPDownloadTaskOperation.h
//  PicData
//
//  Created by 鹏鹏 on 2022/4/20.
//  Copyright © 2022 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DownloadFinishedBlock)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error);

@interface PPDownloadTaskOperation : NSOperation

@property (nonatomic, strong) NSString *url;
@property (nonatomic, copy) DownloadFinishedBlock downloadFinishedBlock;

- (instancetype)initWithUrl:(NSString *)url headers:(NSDictionary *)headers downloadFinishedBlock:(DownloadFinishedBlock)downloadFinishedBlock;
+ (instancetype)operationWithUrl:(NSString *)url headers:(NSDictionary *)headers downloadFinishedBlock:(DownloadFinishedBlock)downloadFinishedBlock;

@end

NS_ASSUME_NONNULL_END
