//
//  ParseOperation.h
//  PicData
//
//  Created by 鹏鹏 on 2022/8/5.
//  Copyright © 2022 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ParseOperation : PPCustomAsyncOperation

@property (nonatomic, strong) PicSourceModel *sourceModel;
@property (nonatomic, strong) PicContentTaskModel *contentTaskModel;
@property (nonatomic, copy) void(^middleWriteHandler)(NSURL *currentURL, NSString *urls);
@property (nonatomic, copy) void(^taskCompleteHandler)(int totalCount);

- (instancetype)initWithSourceModel:(PicSourceModel *)sourceModel contentTaskModel:(PicContentTaskModel *)contentTaskModel;
+ (instancetype)operationWithSourceModel:(PicSourceModel *)sourceModel contentTaskModel:(PicContentTaskModel *)contentTaskModel;

@end

NS_ASSUME_NONNULL_END
