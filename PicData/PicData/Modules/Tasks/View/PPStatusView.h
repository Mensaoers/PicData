//
//  PPStatusView.h
//  ThinkDrive_For_iPhone
//
//  Created by Garenge on 2019/2/28.
//  Copyright © 2019 Richinfo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PPStatusView;
@protocol PPStatusViewDelegate <NSObject>

- (void)statusViewTouched:(PPStatusView *)satusView;

@end

/** 传输cell的进度显示 */
@interface PPStatusView : UIView

/** 是否显示进度 默认YES */
@property (nonatomic, assign) BOOL showProgress;
/** 进度, 如果不显示进度, 这个属性获取的数据作为垃圾值 */
@property (nonatomic, assign) CGFloat progress;
/** 内部颜色 */
@property (nonatomic, strong) UIColor *innerColor;
/** 外部背景色 */
@property (nonatomic, strong) UIColor *lineBGColor;
/** 外部宽度 */
@property (nonatomic, assign) CGFloat lineBGWidth;

/** 外部进度条颜色, 如果不显示进度, 这个属性获取的数据作为垃圾值 */
@property (nonatomic, strong) UIColor *lineColor;
/** 外部进度宽度 */
@property (nonatomic, assign) CGFloat lineWidth;

/** 设置完各项属性之后, 刷新界面 */
- (void)show;

/**
 初始化

 @param frame
 @param status
 @param showProgress 是否显示进度
 */
- (instancetype)initWithFrame:(CGRect)frame showProgress:(BOOL)showProgress;

/**
 初始化

 @param frame
 @param status
 @param showProgress
 @param progress 初始进度
 */
- (instancetype)initWithFrame:(CGRect)frame showProgress:(BOOL)showProgress progress:(CGFloat)progress;

/** 基础动画间隔时间 默认0.4 */
@property (nonatomic, assign) CFTimeInterval duration;
/**
 更新进度

 @param progress 进度
 */
- (void)updateWithProgress:(CGFloat)progress;
/**
 @param progress 进度
 @param animated 是否动画
 */
- (void)updateWithProgress:(CGFloat)progress animated:(BOOL)animated;

@property (nonatomic, weak) id <PPStatusViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
