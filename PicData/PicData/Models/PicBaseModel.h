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

/** 名称 */
@property (nonatomic, strong) NSString *title;
/** 显示名称 */
@property (nonatomic, strong) NSString *showTitle;
/** 编号 */
@property (nonatomic, strong) NSString *identifier;
/** 主服务 */
@property (nonatomic, strong) NSString *HOST_URL;
//- (BOOL)insertTable:(nullable Class)clsPre;
//+ (NSArray *)queryTable:(nullable Class)clsPre Where:(NSString *)where;
//+ (NSArray *)queryTable:(nullable Class)clsPre WithTitle:(NSString *)title;
//+ (int)queryCount:(nullable Class)clsPre Where:(NSString *)where;
//
//- (BOOL)deleteFromTable:(nullable Class)clsPre;
//+ (BOOL)deleteFromTable:(nullable Class)clsPre Where:(NSString *)where;
//+ (BOOL)deleteFromTable_All:(nullable Class)clsPre;
//
//+ (BOOL)updateTable:(nullable Class)clsPre WithDicOrModel:(id)parameters Where:(NSString *)where;
//- (BOOL)updateTable:(nullable Class)clsPre Where:(NSString *)where;
//- (BOOL)updateTable:(nullable Class)clsPre;
- (BOOL)insertTable;
+ (NSArray *)queryAll;
+ (NSArray *)queryTableWhere:(NSString *)where;
+ (NSArray *)queryTableWithTitle:(NSString *)title;
+ (int)queryCountWhere:(NSString *)where;

- (BOOL)deleteFromTable;
+ (BOOL)deleteFromTable_Where:(NSString *)where;
+ (BOOL)deleteFromTable_All;

+ (BOOL)updateTableWithDicOrModel:(id)parameters Where:(NSString *)where;
- (BOOL)updateTableWhere:(NSString *)where;
- (BOOL)updateTable;
@end

NS_ASSUME_NONNULL_END
