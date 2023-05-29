//
//  SocketMessageModel.m
//  PicData
//
//  Created by Garenge on 2023/5/29.
//  Copyright © 2023 garenge. All rights reserved.
//

#import "SocketMessageModel.h"

@implementation SocketMessageModel

- (instancetype)initWithEvent:(NSString *)event {
    if (self = [super init]) {
        self.event = event;
    }
    return self;
}

- (NSString *)description {
    return [self toString];
}

- (NSString *)toString {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (self.event) {
        [dictionary setObject:self.event forKey:@"event"];
    }
    if (self.message) {
        [dictionary setObject:self.message forKey:@"message"];
    }
    if (self.mark) {
        [dictionary setObject:self.mark forKey:@"mark"];
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingSortedKeys error:&error];
    if (error) {
        return error.description;
    }
    NSString * toJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return toJson;
}

@end
