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
/** 编号 */
@property (nonatomic, strong) NSString *identifier;
/** 主服务 */
@property (nonatomic, strong) NSString *HOST_URL;
- (BOOL)insertTable;
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
