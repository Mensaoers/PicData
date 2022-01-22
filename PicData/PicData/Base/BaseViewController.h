//
//  BaseViewController.h
//  PicData
//
//  Created by Garenge on 2020/11/4.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

/// 导航操作按钮, 重写不需要执行父类方法
- (void)loadNavigationItem;
/// 加载主界面, 重写不强制执行父类方法
- (void)loadMainView;

/// 执行自定义方法
- (void)performSelfFuncWithString:(NSString *)funcString withObject:(nullable id)object;

/// 设置浮窗
- (void)setupFloating;

@end

NS_ASSUME_NONNULL_END
