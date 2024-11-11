//
//  BaseViewController.h
//  PicData
//
//  Created by Garenge on 2020/11/4.
//  Copyright © 2020 garenge. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (pp)

- (void)adjustSizeClass;
@property (nonatomic, assign) UIUserInterfaceSizeClass rootViewControllerHorizontalSizeClass;

@end

@interface BaseViewController : UIViewController

/// 导航操作按钮, 重写不需要执行父类方法
- (void)loadNavigationItem;
/// 加载主界面, 重写不强制执行父类方法
- (void)loadMainView;

/// 执行自定义方法
- (void)performSelfFuncWithString:(NSString *)funcString withObject:(nullable id)object;

/// 设置浮窗
- (void)setupFloating;

/// 重写系统dealloc方法时先调用该方法, 方便打日志和子类调用
- (void)willDealloc;

@end

@interface BaseViewController (ppEx)

/// 查看文件, 文档, doc, pdf
- (void)doViewDocFileWithFilePath:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
