//
//  FloatingWindowView.m
//  CLS
//
//  Created by 周子龙 on 2018/10/16.
//  Copyright © 2018 apple. All rights reserved.
//

#import "FloatingWindowView.h"

#define AnimateTime 0.3
#define Margin 10
#define kiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

@interface FloatingWindowView ()

@property (nonatomic, weak) UIViewController *vc;
@property (nonatomic, assign) CGPoint touchesBeganPoint;

@end

@implementation FloatingWindowView

+ (FloatingWindowView *)shareInstance {
    static dispatch_once_t onceToken;
    static FloatingWindowView *floatingWindowView;
    dispatch_once(&onceToken, ^{
        floatingWindowView = [[FloatingWindowView alloc] initWithFrame:CGRectMake(1, 200, 50, 50)];
        floatingWindowView.userInteractionEnabled = YES;
        floatingWindowView.backgroundColor = [UIColor redColor];
        floatingWindowView.image = [UIImage imageNamed:@"calculate"];
        floatingWindowView.layer.cornerRadius = 25;
        floatingWindowView.areaActFrame = [AppTool getAppKeyWindow].bounds;
    });
    return floatingWindowView;
}

- (void)click {
    if (self.ClickAction) {
        self.ClickAction();
    }
}

- (void)viewController:(UIViewController *)vc {
    _vc = vc;
    [self isHidden:NO];
}

- (void)isHidden:(BOOL)is {
    self.hidden = is;
    if (!is) {
        [[AppTool getAppKeyWindow] addSubview:[FloatingWindowView shareInstance]];
    }
}

- (CGFloat)areaWidth {
    return self.areaActFrame.size.width;
}

- (CGFloat)areaHeight {
    return self.areaActFrame.size.height;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [allTouches anyObject];
    CGPoint point = [touch locationInView:[touch window]];
    self.touchesBeganPoint = point;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [allTouches anyObject];
    CGPoint point = [touch locationInView:[touch window]];
    self.center = point;
    CGFloat areaWidth = [self areaWidth];
    CGFloat areaHeight = [self areaHeight];
    if (self.left <= 0 && self.top <= 0) {
        self.left = 0;
        self.top = 0;
    }else if (self.left <= 0 && self.bottom >= areaHeight) {
        self.left = 0;
        self.bottom = areaHeight;
    }else if (self.bottom >= areaHeight && self.right >= areaWidth) {
        self.bottom = areaHeight;
        self.right = areaWidth;
    }else if (self.right >= areaWidth && self.top <= 0) {
        self.right = areaWidth;
        self.top = 0;
    }else if (self.left <= 0) {
        self.left = 0;
    }else if (self.top <= 0) {
        self.top = 0;
    }else if (self.right >= areaWidth) {
        self.right = areaWidth;
    }else if (self.bottom >= areaHeight) {
        self.bottom = areaHeight;
    }
}

- (void)setAreaActFrame:(CGRect)areaActFrame {
    _areaActFrame = areaActFrame;
    self.right = MIN(self.right, areaActFrame.origin.x + areaActFrame.size.width - Margin);
    self.bottom = MIN(self.bottom, areaActFrame.origin.y + areaActFrame.size.height - (Margin + kiPhoneX ? 20 : 0));
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [allTouches anyObject];
    CGPoint point = [touch locationInView:[touch window]];
    CGFloat areaWidth = [self areaWidth];
    CGFloat areaHeight = [self areaHeight];
    if (point.x == _touchesBeganPoint.x && point.y == _touchesBeganPoint.y) {
        [self click];
    }else{
        if (self.left < areaWidth / 2.0) {
            [UIView animateWithDuration:AnimateTime animations:^{
                self.left = Margin;
            }];
        }
        if (self.top <= 0) {
            [UIView animateWithDuration:AnimateTime animations:^{
                if (kiPhoneX) {
                    self.top = 2 * Margin + 20;
                }else{
                    self.top = 2 * Margin;
                }
            }];
        }
        if (self.right >= areaWidth / 2.0) {
            [UIView animateWithDuration:AnimateTime animations:^{
                self.right = areaWidth - Margin;
            }];
        }
        if (self.bottom >= areaHeight) {
            [UIView animateWithDuration:AnimateTime animations:^{
                if (kiPhoneX) {
                    self.bottom = areaHeight - Margin - 20;
                }else{
                    self.bottom = areaHeight - Margin;
                }
            }];
        }
    }
}

@end
