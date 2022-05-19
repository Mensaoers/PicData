//
//  OCGumboElement+query.h
//  PicData
//
//  Created by Garenge on 2021/4/11.
//  Copyright © 2021 garenge. All rights reserved.
//

#import "OCGumbo.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCGumboElement (query)

/// html快速解析 class
- (OCQueryObject *)queryWithClass:(NSString *)name;
/// html快速解析 class
- (OCQueryObject *)queryWithID:(NSString *)name;
/// html快速解析 class
- (OCQueryObject *)queryWithElement:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
