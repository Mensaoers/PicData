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

@interface PicClassModel: PicBaseModel

@property (nonatomic, strong) NSString *sourceType;
@property (nonatomic, strong) NSArray <PicSourceModel *>*subTitles;
@property (nonatomic, strong) NSArray <NSString *> *subTitleStrings;

+ (instancetype)modelWithHOST_URL:(NSString *)HOST_URL Title:(NSString *)title sourceType:(NSString *)sourceType subTitles:(nullable NSArray <PicSourceModel *>*)subTitles;

@end

NS_ASSUME_NONNULL_END
