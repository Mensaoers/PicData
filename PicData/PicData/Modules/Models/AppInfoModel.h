//
//  AppInfoModel.h
//  PicData
//
//  Created by 鹏鹏 on 2022/9/18.
//  Copyright © 2022 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppInfoModel : NSObject

@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *build;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *urlService;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *titleInstall;

@end

NS_ASSUME_NONNULL_END
