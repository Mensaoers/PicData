//
//  DatabaseManager.m
//  PicData
//
//  Created by 鹏鹏 on 2021/10/27.
//  Copyright © 2021 garenge. All rights reserved.
//

#import "DatabaseManager+WCTTableCoding.h"

@implementation DatabaseManager

+ (void)prepareDatabase {
    NSLog(@"database filePath: %@", [PDDownloadManager sharedPDDownloadManager].databaseFilePath);
    [DatabaseManager getDatabase];
    [DatabaseManager createTables];
}

+ (WCTDatabase *)getDatabase {
    return [[WCTDatabase alloc] initWithPath:[PDDownloadManager sharedPDDownloadManager].databaseFilePath];
}

+ (void)closeDatabase {
    [[DatabaseManager getDatabase] close];
}

+ (void)createTables {
    WCTDatabase *wcdb = [DatabaseManager getDatabase];

    [wcdb createTableAndIndexesOfName:[PicSourceModel tableName] withClass:[PicSourceModel class]];
    [wcdb createTableAndIndexesOfName:[PicContentModel tableName] withClass:[PicContentModel class]];
    [wcdb createTableAndIndexesOfName:[PicContentTaskModel tableName] withClass:[PicContentTaskModel class]];
}

@end
