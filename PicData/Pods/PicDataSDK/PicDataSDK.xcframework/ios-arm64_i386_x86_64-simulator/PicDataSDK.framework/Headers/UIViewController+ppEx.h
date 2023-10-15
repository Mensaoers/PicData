//
//  UIViewController+ppEx.h
//  PicDataSDK
//
//  Created by 鹏鹏 on 2022/5/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (ppEx)

- (UIAlertController *)showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message actions:(nonnull NSArray<UIAlertAction *>*)actions;

- (UIAlertController *)showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message confirmTitle:(nonnull NSString *)confirmTitle confirmHandler:(void (^ __nullable)(UIAlertAction *action))confirmHandler;

- (UIAlertController *)showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message confirmTitle:(nonnull NSString *)confirmTitle confirmHandler:(void (^ __nullable)(UIAlertAction *action))confirmHandler cancelTitle:(nonnull NSString *)cancelTitle cancelHandler:(void (^ __nullable)(UIAlertAction *action))cancelHandler;

@end

NS_ASSUME_NONNULL_END
