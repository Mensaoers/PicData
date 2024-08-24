//
//  DataDemoModel.h
//  PicData
//
//  Created by Garenge on 2024/8/16.
//  Copyright © 2024 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataDemoModel : NSObject

@property (nonatomic, strong) NSString *name;

+ (NSString *)tableName;

+ (NSArray *)queryAllModelsWithDBUrl:(NSString *)dbUrl;

+ (DataDemoModel *)queryModelsWithDBUrl:(NSString *)dbUrl andTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
