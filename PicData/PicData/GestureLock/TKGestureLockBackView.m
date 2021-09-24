//
//  TKGestureLockBackView.m
//  ThinkDrive_For_iPhone
//
//  Created by istLZP on 2018/3/19.
//  Copyright © 2018年 Richinfo. All rights reserved.
//

#import "TKGestureLockBackView.h"

#define AccountKey @"account"

@interface TKGestureLockBackView () <TKGestureLockDelegate>

// 创建的手势密码
@property(nonatomic, copy) NSString *lastGesturePsw;
@property(nonatomic, copy) NSString *lastTitle;
@property(nonatomic, assign) NSInteger errorCount; // 允许错误次数
@end

@implementation TKGestureLockBackView

- (void)setTitleLabelText:(NSString *)title {
    self.lastTitle = self.titleLabel.text;
    self.titleLabel.text = title;
}

- (instancetype)initWithFrame:(CGRect)frame WithUnLockType:(TKGestureLockViewUnlockType)unLockType {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.unLockType = unLockType;
        self.errorCount = 3;
        [self setupMainUI];

        if (unLockType == TKGestureLockViewUnlockTypeValidate) {
            [self setTitleLabelText:@"请验证手势密码"];
        } else if (unLockType == TKGestureLockViewUnlockTypeCreate) {
            [self setTitleLabelText:@"请绘制手势密码"];
        } else if (unLockType == TKGestureLockViewUnlockTypeModify) {
            [self setTitleLabelText:@"请验证手势密码"];
        } else if (unLockType == TKGestureLockViewUnlockTypeDelete) {
            [self setTitleLabelText:@"请验证手势密码"];
        }
    }
    return self;
}

- (void)setupMainUI {
    CGFloat maginX = 15;
    CGFloat magin = 5;
    CGFloat btnW = (self.frame.size.width - maginX * 2 - magin * 2) / 3;
    CGFloat btnH = 30;

    // 重新绘制按钮
    UIButton *resetPswBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    resetPswBtn.frame = CGRectMake((self.frame.size.width - btnW) * 0.5, self.frame.size.height - 20 - btnH, btnW, btnH);
    [resetPswBtn setTitle:@"重新绘制" forState:UIControlStateNormal];
    resetPswBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [resetPswBtn setTitleColor:[UIColor colorWithRed:102 / 255.0 green:102 / 255.0 blue:102 / 255.0 alpha:1] forState:UIControlStateNormal];
    [resetPswBtn addTarget:self action:@selector(resetGesturePassword:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:resetPswBtn];
    self.resetPswBtn = resetPswBtn;
    self.resetPswBtn.hidden = YES;

    // 九宫格 手势密码页面
    TKGestureLockView *gestureLockView = [[TKGestureLockView alloc] initWithFrame:CGRectMake(20, resetPswBtn.frame.origin.y - (self.frame.size.width - 40), self.frame.size.width - 40, self.frame.size.width - 40)];
    gestureLockView.delegate = self;
    [self addSubview:gestureLockView];
    self.gestureLockView = gestureLockView;

    // 手势状态栏提示label
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, gestureLockView.frame.origin.y - 20, 200, 20)];
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.text = @"";
    statusLabel.font = [UIFont systemFontOfSize:13];
    statusLabel.textColor = UIColorFromRGB(0xFF413C);
    [self addSubview:statusLabel];
    self.statusLabel = statusLabel;

    // 手势状态栏提示label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, gestureLockView.frame.origin.y - 60, 200, 20)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"";
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = UIColorFromRGB(0x1F2D3D);
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;


}

- (void)gestureLockView:(TKGestureLockView *)lockView drawRectFinished:(NSMutableString *)gesturePassword {
    switch (self.unLockType) {
        case TKGestureLockViewUnlockTypeCreate: // 创建手势密码
        {
            [self createGesturesPassword:gesturePassword];
        }
            break;
        case TKGestureLockViewUnlockTypeValidate: // 校验手势密码
        {
            [self validateGesturesPassword:gesturePassword];
        }
            break;
        case TKGestureLockViewUnlockTypeModify: // 修改手势密码
        {
            [self modifyGesturesPassword:gesturePassword];
        }
            break;
        case TKGestureLockViewUnlockTypeUpdate: // 后面的更新
        {
            [self updateGesturesPassword:gesturePassword];
        }
            break;
        case TKGestureLockViewUnlockTypeDelete: // 关闭手势的时候需要先验证一下
        {
            [self deleteGesturesPassword:gesturePassword];
        }
        default:
            break;
    }
}

#pragma mark 创建手势密码
- (void)createGesturesPassword:(NSMutableString *)gesturesPassword {

    if (self.lastGesturePsw.length == 0) {

        if (gesturesPassword.length < 4) {
            self.statusLabel.text = @"至少连接四个点，请重新输入";
            [self shakeAnimationForView:self.statusLabel];
            return;
        }

        if (self.resetPswBtn.hidden == YES) {
            self.resetPswBtn.hidden = NO;
        }

        self.lastGesturePsw = gesturesPassword;
        [self setTitleLabelText:@"请再次绘制手势密码"];
        self.statusLabel.text = @"";
        return;
    }

    if ([self.lastGesturePsw isEqualToString:gesturesPassword]) { // 绘制成功
        // 保存账号密码
        self.statusLabel.text = @"";
        [self addGesturesPassword:gesturesPassword];
        if (self.delegate && [self.delegate respondsToSelector:@selector(gestureLockBackView:drawResult:)]) {
            [self.delegate gestureLockBackView:self drawResult:YES];
        }

    } else {
        self.statusLabel.text = @"与上一次绘制不一致，请重新绘制";
        [self shakeAnimationForView:self.statusLabel];
    }


}

#pragma mark 验证手势密码
- (void)validateGesturesPassword:(NSMutableString *)gesturesPassword {

    if ([gesturesPassword isEqualToString:[self gesturesPassword]]) {
        self.statusLabel.text = @"";
        if (self.delegate && [self.delegate respondsToSelector:@selector(gestureLockBackView:drawResult:)]) {
            [self.delegate gestureLockBackView:self drawResult:YES];
        }
    } else {

        if (self.errorCount - 1 == 0) { // 你已经输错n次了！ 退出重新登录！
            self.statusLabel.text = @"";
            [self deleteGesturesPassword];
            if (self.delegate && [self.delegate respondsToSelector:@selector(gestureLockBackView:drawResult:)]) {
                [self.delegate gestureLockBackView:self drawResult:NO];
            }
            return;
        }

        self.statusLabel.text = [NSString stringWithFormat:@"密码错误，还可以再输入%ld次", --self.errorCount];
        [self shakeAnimationForView:self.statusLabel];
    }
}

#pragma mark 修改手势密码
- (void)modifyGesturesPassword:(NSMutableString *)gesturesPassword {
    if ([gesturesPassword isEqualToString:[self gesturesPassword]]) {
        // 验证正确
        [self setTitleLabelText:@"请绘制新的手势密码"];
        self.statusLabel.text = @"";
        self.unLockType = TKGestureLockViewUnlockTypeUpdate;
        self.lastGesturePsw = nil;
        if (self.delegate && [self.delegate respondsToSelector:@selector(gestureLockBackView:drawResult:)]) {
            [self.delegate gestureLockBackView:self drawResult:YES];
        }
    } else {
        self.statusLabel.text = @"验证手势密码失败,请重新输入";
        [self shakeAnimationForView:self.statusLabel];
    }
}

#pragma mark 更新手势密码
- (void)updateGesturesPassword:(NSMutableString *)gesturesPassword {
    if (self.lastGesturePsw.length == 0) {

        if (gesturesPassword.length < 4) {
            self.statusLabel.text = @"至少连接四个点，请重新输入";
            [self shakeAnimationForView:self.statusLabel];
            return;
        }

        if (self.resetPswBtn.hidden == YES) {
            self.resetPswBtn.hidden = NO;
        }

        self.lastGesturePsw = gesturesPassword;
        [self setTitleLabelText:@"请再次绘制手势密码"];
        self.statusLabel.text = @"";
        return;
    }

    if ([self.lastGesturePsw isEqualToString:gesturesPassword]) { // 绘制成功
        // 保存账号密码
        self.statusLabel.text = @"";
        [self addGesturesPassword:gesturesPassword];
        if (self.delegate && [self.delegate respondsToSelector:@selector(gestureLockBackView:drawResult:)]) {
            [self.delegate gestureLockBackView:self drawResult:YES];
        }

    } else {
        self.statusLabel.text = @"与上一次绘制不一致，请重新绘制";
        [self shakeAnimationForView:self.statusLabel];
    }
}

#pragma mark 关闭手势验证的时候需要先验证一下
- (void)deleteGesturesPassword:(NSMutableString *)gesturesPassword {
    if ([gesturesPassword isEqualToString:[self gesturesPassword]]) {
        // 验证正确
        self.statusLabel.text = @"";
        [self updateGestureLock:NO];
        if (self.delegate && [self.delegate respondsToSelector:@selector(gestureLockBackView:drawResult:)]) {
            [self.delegate gestureLockBackView:self drawResult:YES];
        }
    } else {
        self.statusLabel.text = @"验证手势密码失败,请重新输入";
        [self shakeAnimationForView:self.statusLabel];
    }
}

// 抖动动画
- (void)shakeAnimationForView:(UIView *)view {

    CALayer *viewLayer = view.layer;
    CGPoint position = viewLayer.position;
    CGPoint left = CGPointMake(position.x - 10, position.y);
    CGPoint right = CGPointMake(position.x + 10, position.y);

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFromValue:[NSValue valueWithCGPoint:left]];
    [animation setToValue:[NSValue valueWithCGPoint:right]];
    [animation setAutoreverses:YES]; // 平滑结束
    [animation setDuration:0.08];
    [animation setRepeatCount:3];

    [viewLayer addAnimation:animation forKey:nil];
}

#pragma mark 点击重新绘制按钮
- (void)resetGesturePassword:(id)sender {
    NSLog(@"%s", __FUNCTION__);

    self.lastGesturePsw = nil;
    self.statusLabel.text = @"";
    self.resetPswBtn.hidden = YES;
    [self setTitleLabelText:self.lastTitle];
}

#pragma mark func

- (void)addGesturesPassword:(NSString *)gesturesPassword {
    [[TKGestureLockManager sharedInstance] saveGesturesPassword:gesturesPassword];
}

- (void)deleteGesturesPassword {
    [[TKGestureLockManager sharedInstance] deleteGesturesPassword];
}

- (NSString *)gesturesPassword {
    return [[TKGestureLockManager sharedInstance] gesturesPassword];
}

- (void)updateGestureLock:(BOOL)on {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:on forKey:@"GettureLockNeeded"];
    if (!on) {
        // 如果传进来NO, 表示关闭了手势保护, 还需要清空已经保存的手势
        [self deleteGesturesPassword];
    }
    [defaults synchronize];
}

@end
