//
//  PicClassModel.h
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PicSourceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PicClassModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *sourceType;
@property (nonatomic, strong) NSArray *subTitles;

+ (instancetype)modelWithTitle:(NSString *)title sourceType:(NSString *)sourceType subTitles:(NSArray *)subTitles;

@end

NS_ASSUME_NONNULL_END
