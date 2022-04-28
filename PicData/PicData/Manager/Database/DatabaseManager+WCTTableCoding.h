//
//  DatabaseManager+WCTTableCoding.h
//  PicData
//
//  Created by 鹏鹏 on 2021/10/27.
//  Copyright © 2021 garenge. All rights reserved.
//


#import "DatabaseManager.h"
#import <WCDB/WCDB.h>

@interface DatabaseManager (WCTTableCoding) <WCTTableCoding>

+ (WCTDatabase *)getDatabase;

@end
