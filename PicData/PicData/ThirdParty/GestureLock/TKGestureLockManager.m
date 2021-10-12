//
//  TKGestureLockManager.m
//  ThinkDrive_For_iPhone
//
//  Created by istLZP on 2018/3/19.
//  Copyright © 2018年 Richinfo. All rights reserved.
//

#import "TKGestureLockManager.h"
#import "TKGestureLockWindow.h"

/// 手势登录只能存一个用户的, 切换用户无变化, 退出用户的时候, 会被清除, 所以不需要根据userId区分
#define GesturesPassword @"gesturespassword"
#define GettureLockNeeded @"GettureLockNeeded"

@interface TKGestureLockManager () <TKGestureLockBackDelegate>

@property(nonatomic, strong) TKGestureLockWindow *lockWindow;
@property(nonatomic, strong) TKGestureLockBackView *backView;

@end

@implementation TKGestureLockManager

+ (TKGestureLockManager *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TKGestureLockManager alloc] init];
    });
    return sharedInstance;
}

- (void)initialData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:GettureLockNeeded];
    [defaults synchronize];
}

- (BOOL)checkGettureLockNeeded {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isNeed = [defaults boolForKey:GettureLockNeeded];
    return isNeed;
}

- (void)updateGestureLock:(BOOL)on {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:on forKey:GettureLockNeeded];
    if (!on) {
        // 如果传进来NO, 表示关闭了手势保护, 还需要清空已经保存的手势
        [self deleteGesturesPassword];
    }
    [defaults synchronize];
}

// 显示View(window)
- (void)showGestureLockWindow {
    if ([self checkGettureLockNeeded]) {
        // 需要手势验证
        if (nil == self.lockWindow) {
            TKGestureLockWindow *lockWindow = [[TKGestureLockWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            self.lockWindow = lockWindow;
            TKGestureLockBackView *backView = [[TKGestureLockBackView alloc] initWithFrame:[UIScreen mainScreen].bounds WithUnLockType:TKGestureLockViewUnlockTypeValidate];
            backView.delegate = self;
            [self.lockWindow addSubview:backView];
            self.backView = backView;
        }
//        [self.lockWindow dismissSelf];
        self.unLockType = TKGestureLockViewUnlockTypeValidate;
        [self.lockWindow showOnfront];

    } else {
        // 不需要手势验证
        self.lockWindow = nil;
        return;
    }
}

// backView 的代理方法, 整个手势的操作判断结束 调用
- (void)gestureLockBackView:(TKGestureLockBackView *)backView drawResult:(BOOL)result {
    if (self.unLockType == TKGestureLockViewUnlockTypeValidate) {
        [self.lockWindow dismissSelf];
        self.lockWindow = nil;
        [self gestureLockResults:result];
    }
}

#pragma mark 手势解锁失败
- (void)gestureLockResults:(BOOL)result {
    if (result) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TKGestureLockNotice_unlockSuccess object:nil userInfo:@{}];
    } else {
        // 失败
        // 退出登录 回到登录界面
        [[NSNotificationCenter defaultCenter] postNotificationName:TKGestureLockNotice_unlockFailed object:nil userInfo:@{}];
    }
}

#pragma mark func
// 保存密码
- (void)saveGesturesPassword:(NSString *)gesturesPassword {
    [[NSUserDefaults standardUserDefaults] setObject:gesturesPassword forKey:GesturesPassword];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)deleteGesturesPassword {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:GesturesPassword];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)gesturesPassword {
    return [[NSUserDefaults standardUserDefaults] objectForKey:GesturesPassword];
}


@end
