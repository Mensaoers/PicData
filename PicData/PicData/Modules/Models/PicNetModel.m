//
//  PicNetModel.m
//  PicData
//
//  Created by 鹏鹏 on 2022/2/18.
//  Copyright © 2022 garenge. All rights reserved.
//

#import "PicNetModel.h"

@implementation PicNetUrlModel

@end

@implementation PicNetModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
        @"urls": @"PicNetUrlModel"
    };
}

- (void)setSearchKeys:(NSArray<NSString *> *)searchKeys {
    _searchKeys = [searchKeys sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
}

@end
