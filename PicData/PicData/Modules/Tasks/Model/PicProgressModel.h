//
//  PicProgressModel.h
//  PicData
//
//  Created by 鹏鹏 on 2022/5/5.
//  Copyright © 2022 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PicProgressModel : NSObject

@property (nonatomic, strong) NSString *title;

@property (nonatomic, assign) BOOL expand;

@property (nonatomic, strong) NSMutableArray <PicContentTaskModel *>*taskModels;

- (instancetype)initWithTitle:(NSString *)title;

+ (instancetype)ModelWithTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
