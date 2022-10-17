//
//  PicNetModel.h
//  PicData
//
//  Created by 鹏鹏 on 2022/2/18.
//  Copyright © 2022 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PicNetUrlModel : NSObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *title;

@end

@interface PicNetModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) int sourceType;
@property (nonatomic, strong) NSString *HOST_URL;
/// 套图指向引用, 默认等于HOST_URL
@property (nonatomic, strong) NSString *referer;
@property (nonatomic, strong) NSArray <PicNetUrlModel *>* urls;
@property (nonatomic, strong) NSString *tagsUrl;
@property (nonatomic, strong) NSString *searchFormat;
@property (nonatomic, strong) NSArray <NSString *>*searchKeys;
@property (nonatomic, assign) BOOL searchEncode;
@property (nonatomic, strong) NSString *mark;
@property (nonatomic, strong) NSString *tips;
@property (nonatomic, assign) BOOL prepared;

@end

NS_ASSUME_NONNULL_END
