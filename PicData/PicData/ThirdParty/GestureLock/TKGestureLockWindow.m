//
//  TKSoftWarePassWindow.m
//  ThinkDrive_For_iPhone
//
//  Created by istLZP on 2018/3/19.
//  Copyright © 2018年 Richinfo. All rights reserved.
//

#import "TKGestureLockWindow.h"

@interface TKGestureLockWindow ()

@end

@implementation TKGestureLockWindow

- (void)showOnfront {
    self.windowLevel = UIWindowLevelAlert;//最顶层显示
    self.backgroundColor = [UIColor whiteColor];
    [self makeKeyWindow];
    self.hidden = NO;
}

- (void)dismissSelf {
    [self resignKeyWindow];
    self.hidden = YES;
}

@end
