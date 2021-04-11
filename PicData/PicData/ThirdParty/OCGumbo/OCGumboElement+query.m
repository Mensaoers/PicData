//
//  OCGumboElement+query.m
//  PicData
//
//  Created by Garenge on 2021/4/11.
//  Copyright © 2021 garenge. All rights reserved.
//

#import "OCGumboElement+query.h"
#import "OCGumbo+Query.h"

@implementation OCGumboElement (query)

/// html快速解析 class
- (OCQueryObject *)queryWithClass:(NSString *)name {
//    return self.QueryClass(name);
    return self.Query([NSString stringWithFormat:@".%@", name]);
}
/// html快速解析 class
- (OCQueryObject *)queryWithID:(NSString *)name {
//    return self.QueryID(name);
    return self.Query([NSString stringWithFormat:@"#%@", name]);
}
/// html快速解析 class
- (OCQueryObject *)queryWithElement:(NSString *)name {
//    return self.QueryElement(name);
    return self.Query([NSString stringWithFormat:@"%@", name]);
}

@end
