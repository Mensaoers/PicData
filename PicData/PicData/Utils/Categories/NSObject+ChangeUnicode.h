//
//  NSObject+ChangeUnicode.h
//  PPToolSKYD
//
//  Created by 鹏鹏 on 2020/11/6.
//  Copyright © 2020 CleverPeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ChangeUnicode)

+(NSString *)stringByReplaceUnicode:(NSString *)string;

@end

@interface NSArray (LengUnicode)

@end

@interface NSDictionary (LengUnicode)

@end

NS_ASSUME_NONNULL_END
