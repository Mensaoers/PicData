//
//  PDRequest.h
//  PicData
//
//  Created by CleverPeng on 2020/8/2.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDRequest : NSObject

singleton_interface(PDRequest)

+ (void)getWithURL:(NSURL *)URL completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;
+ (void)getWithURL:(NSURL *)URL isPhone:(BOOL)isPhone completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;
+ (void)getWithURL:(NSURL *)URL userAgent:(NSString *)userAgent completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

+ (void)requestToCheckVersion:(BOOL)autoCheck onView:(UIView *)onView completehandler:(void(^ __nullable )(void))completehandler;
@end

NS_ASSUME_NONNULL_END
