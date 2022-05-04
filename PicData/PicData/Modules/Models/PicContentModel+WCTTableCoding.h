//
//  PicContentModel+WCTTableCoding.h
//  PicData
//
//  Created by 鹏鹏 on 2021/10/27.
//  Copyright © 2021 garenge. All rights reserved.
//

#import "PicContentModel.h"
#import "PicBaseModel+WCTTableCoding.h"

@interface PicContentModel (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(title)
WCDB_PROPERTY(systemTitle)
WCDB_PROPERTY(HOST_URL)
WCDB_PROPERTY(sourceHref)
WCDB_PROPERTY(thumbnailUrl)
WCDB_PROPERTY(href)
WCDB_PROPERTY(totalCount)
WCDB_PROPERTY(downloadedCount)

@end

@interface PicContentTaskModel (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(title)
WCDB_PROPERTY(systemTitle)
WCDB_PROPERTY(HOST_URL)
WCDB_PROPERTY(sourceHref)
WCDB_PROPERTY(thumbnailUrl)
WCDB_PROPERTY(href)
WCDB_PROPERTY(totalCount)
WCDB_PROPERTY(downloadedCount)
WCDB_PROPERTY(status)

@end
