//
//  HostManager.h
//  PicData
//
//  Created by 鹏鹏 on 2022/3/23.
//  Copyright © 2022 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PicNetModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HostManager : NSObject

singleton_interface(HostManager)

@property (nonatomic, strong, nonnull) PicNetModel *currentHostModel;

@property (nonatomic, strong, readonly) NSArray <PicNetModel *> *hostModels;

@end

NS_ASSUME_NONNULL_END
