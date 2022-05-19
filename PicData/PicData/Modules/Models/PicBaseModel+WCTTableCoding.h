//
//  PicBaseModel+WCTTableCoding.h
//  PicData
//
//  Created by 鹏鹏 on 2021/10/27.
//  Copyright © 2021 garenge. All rights reserved.
//

#import "PicBaseModel.h"
#import "DatabaseManager+WCTTableCoding.h"

@interface PicBaseModel (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(title)
WCDB_PROPERTY(showTitle)
WCDB_PROPERTY(HOST_URL)

@end
