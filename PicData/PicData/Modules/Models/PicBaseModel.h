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
/** 操作系统使用的名称, title中原本可能含有/, 系统会认为这是子文件夹, 我们在调用api的时候, 就要用:号代替/, 这样创建的文件夹名才能带/ */
@property (nonatomic, strong) NSString *systemTitle;
/** 主服务 */
@property (nonatomic, strong) NSString *HOST_URL;

@property (nonatomic, strong) NSString *referer;

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
