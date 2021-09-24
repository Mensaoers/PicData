//
//  TKGestureLockBackView.h
//  ThinkDrive_For_iPhone
//
//  Created by istLZP on 2018/3/19.
//  Copyright © 2018年 Richinfo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKGestureLockView.h"

typedef NS_ENUM(NSInteger, TKGestureLockViewUnlockType) {
    TKGestureLockViewUnlockTypeCreate, // 创建手势密码
    TKGestureLockViewUnlockTypeValidate, // 校验手势密码
    TKGestureLockViewUnlockTypeModify, // 修改手势的第一次判断
    TKGestureLockViewUnlockTypeUpdate, // 修改手势之后的更新
    TKGestureLockViewUnlockTypeDelete, // 删除手势
};

@class TKGestureLockBackView;

@protocol TKGestureLockBackDelegate <NSObject>

- (void)gestureLockBackView:(TKGestureLockBackView *)backView drawResult:(BOOL)result;

@end

@interface TKGestureLockBackView : UIView

@property(nonatomic, strong) TKGestureLockView *gestureLockView;

// 手势状态栏提示label
@property(weak, nonatomic) UILabel *statusLabel;
// 操作提示
@property(weak, nonatomic) UILabel *titleLabel;
// 重新绘制按钮
@property(weak, nonatomic) UIButton *resetPswBtn;

@property(nonatomic, assign) TKGestureLockViewUnlockType unLockType;

- (instancetype)initWithFrame:(CGRect)frame WithUnLockType:(TKGestureLockViewUnlockType)unLockType;

@property(nonatomic, weak) id <TKGestureLockBackDelegate> delegate;

@end
