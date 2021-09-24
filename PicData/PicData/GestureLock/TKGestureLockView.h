//
//  TKGestureLockView.h
//  ThinkDrive_For_iPhone
//
//  Created by istLZP on 2018/3/19.
//  Copyright © 2018年 Richinfo. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

/**
    参照 https://github.com/ZLFighting/GestureLockDemo.git大神demo
 */

#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height

@class TKGestureLockView;

@protocol TKGestureLockDelegate <NSObject>

- (void)gestureLockView:(TKGestureLockView *)lockView drawRectFinished:(NSMutableString *)gesturePassword;

@end


@interface TKGestureLockView : UIView

@property(assign, nonatomic) id <TKGestureLockDelegate> delegate;


@end
