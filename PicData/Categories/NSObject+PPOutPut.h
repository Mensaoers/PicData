//
//  NSObject+PPOutPut.h
//  yanfayun
//
//  Created by istLZP on 2017/11/1.
//  Copyright © 2017年 ff刚. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 添加注释:2017-11-01 14:52:53 刘张鹏
 *  在 NSObject+MJKeyValue.m 112行
 *  if (!value || value == [NSNull null]) return;
 *  他在给模型属性赋值的时候, 如果数据源的value为null, 就会直接跳过
 *  但是有时候我们获取一个属性的时候, 尤其是字符串, 需要一个操作就是
 *  如果字符串属性为nil, 就取空字符串, 不方便在他的代码里面改, 新增一个分类
 *  专门给需要设置默认值的属性设置
 */
@interface NSObject (PPOutPut)

void checkEntity(NSObject *object);

@end
