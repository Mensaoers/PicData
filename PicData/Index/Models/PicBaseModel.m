//
//  PicBaseModel.m
//  PicData
//
//  Created by CleverPeng on 2020/8/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "PicBaseModel.h"

@implementation PicBaseModel

- (NSString *)identifier {
    if (nil == _identifier || _identifier.length == 0) {
        _identifier = [self createUUID];
    }
    return _identifier;
}

- (NSString *)createUUID {
    NSString * result;
    CFUUIDRef uuid;
    CFStringRef uuidStr;
    uuid = CFUUIDCreate(NULL);
    uuidStr = CFUUIDCreateString(NULL, uuid);
    result =[NSString stringWithFormat:@"%@", uuidStr];
    CFRelease(uuidStr);
    CFRelease(uuid);
    return result;
}

@end
