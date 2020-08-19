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

@end

NS_ASSUME_NONNULL_END
