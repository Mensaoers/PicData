//
//  TKGestureLockManager.h
//  ThinkDrive_For_iPhone
//
//  Created by istLZP on 2018/3/19.
//  Copyright © 2018年 Richinfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TKGestureLockBackView.h"

#define TKGestureLockNotice_unlockSuccess @"TKGestureLockNotice_unlockSuccess"
#define TKGestureLockNotice_unlockFailed @"TKGestureLockNotice_unlockFailed"
@interface TKGestureLockManager : NSObject

+ (TKGestureLockManager *)sharedInstance;

/** 检查APP是否更新过
    -- 诸如设置等功能, 都是写在plist文件中的,
    但是项目中有一个settingModel, 它是读取plist数据之后, 归档到本地
    在APP启动, 会调用
     调用登录Login->TDLoginManager.m中的parseLoginInfoWithContext
     该方法会初始化一次SettingModel->[TDContextHelper saveOnlyOnceUserSetting:initSettingModel(YES, YES, NO, YES)];//保存到UserSetting.plist
     该方法中, 如果文件在本地存在, 是不覆盖的
     但是本地版本更新, 必须要覆盖之前的setting文件
     读取该文件中的数据, 增加我们需要的数据(目前就增加了一个BOOL键值对)
 */

/// 检查是否打开手势密码
- (BOOL)checkGettureLockNeeded;

// 是否打开手势登录
- (void)updateGestureLock:(BOOL)on;
// 保存密码
- (void)saveGesturesPassword:(NSString *)gesturesPassword;
- (void)deleteGesturesPassword;//删除手势密码
- (NSString *)gesturesPassword;//获取手势密码

// 显示View(window)
- (void)showGestureLockWindow;

#pragma mark 手势解锁失败
- (void)gestureLockResults:(BOOL)result;

//- (void)showViewWithUnlockType:(TKGestureLockViewUnlockType)unlockType;

@property(nonatomic, assign) TKGestureLockViewUnlockType unLockType;

@end
