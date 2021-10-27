//
//  PicSourceModel+WCTTableCoding.h
//  PicData
//
//  Created by 鹏鹏 on 2021/10/27.
//  Copyright © 2021 garenge. All rights reserved.
//

#import "PicSourceModel.h"
#import "PicBaseModel+WCTTableCoding.h"

@interface PicSourceModel (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(title)
WCDB_PROPERTY(systemTitle)
WCDB_PROPERTY(HOST_URL)
WCDB_PROPERTY(url)
WCDB_PROPERTY(sourceType)

@end
