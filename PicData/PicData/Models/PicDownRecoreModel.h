//
//  PicDownRecoreModel.h
//  PicData
//
//  Created by CleverPeng on 2020/8/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "PicBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PicDownRecoreModel : PicBaseModel// <JKSqliteProtocol>

@property (nonatomic, strong) NSString *contentUrl;
@property (nonatomic, strong) NSString *contentName;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) int isFinished;

+ (int)queryCountWithContentUrl:(NSString *)contentUrl;

@end

NS_ASSUME_NONNULL_END
