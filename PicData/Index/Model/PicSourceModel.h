//
//  PicSourceModel.h
//  PicData
//
//  Created by Garenge on 2020/4/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PicSourceModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *url;
//@property (nonatomic, strong) NSString *sourceType;
@property (nonatomic, assign) int sourceType;
@end

NS_ASSUME_NONNULL_END
