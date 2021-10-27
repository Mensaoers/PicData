//
//  PicBaseModel.h
//  PicData
//
//  Created by CleverPeng on 2020/8/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// 基类模型, 提供title, 和id
@interface PicBaseModel : NSObject

/** 数据库名称 */
@property (nonatomic, strong) NSString *title;
/** 操作系统使用的名称 */
@property (nonatomic, strong) NSString *systemTitle;
/** 主服务 */
@property (nonatomic, strong) NSString *HOST_URL;

+ (NSString *)tableName;

- (BOOL)insertTable;
+ (NSArray *)queryAll;

+ (NSArray *)queryTableWithTitle:(NSString *)title;

- (BOOL)deleteFromTable;
+ (BOOL)deleteFromTableWithTitle:(NSString *)title;
+ (BOOL)deleteFromTable_All;

- (BOOL)updateTable;
@end

NS_ASSUME_NONNULL_END
