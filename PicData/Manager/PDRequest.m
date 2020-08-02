//
//  PDRequest.m
//  PicData
//
//  Created by CleverPeng on 2020/8/2.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "PDRequest.h"

@implementation PDRequest

+ (void)getWithURL:(NSURL *)URL completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler {
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithURL:URL completionHandler:completionHandler];
    [dataTask resume];
}

@end
