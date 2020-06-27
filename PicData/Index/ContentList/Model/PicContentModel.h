//
//  PicContentModel.h
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PicContentModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *thumbnailUrl;
@property (nonatomic, strong) NSString *href;

/// 任务是否已经添加
@property (nonatomic, assign) BOOL hasAdded;

@end

NS_ASSUME_NONNULL_END
