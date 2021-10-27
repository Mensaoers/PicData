//
//  DatabaseManager.h
//  PicData
//
//  Created by 鹏鹏 on 2021/10/27.
//  Copyright © 2021 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DatabaseManager : NSObject

+ (void)prepareDatabase;

+ (void)closeDatabase;

@end

NS_ASSUME_NONNULL_END
