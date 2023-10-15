//
//  AppInfoModel.m
//  PicData
//
//  Created by 鹏鹏 on 2022/9/18.
//  Copyright © 2022 garenge. All rights reserved.
//

#import "AppInfoModel.h"

@implementation AppInfoModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"urlService": @"url_service",
             @"titleInstall": @"title_install"
    };
}

@end
