//
//  DataDemoModel+WCTTableCoding.h
//  PicData
//
//  Created by Garenge on 2024/8/16.
//  Copyright © 2024 garenge. All rights reserved.
//

#import "DataDemoModel.h"
#import "DatabaseManager+WCTTableCoding.h"

@interface DataDemoModel (WCTTableCoding) <WCTTableCoding>

WCDB_PROPERTY(name)

@end
