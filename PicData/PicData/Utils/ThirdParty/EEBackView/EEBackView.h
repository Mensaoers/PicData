//
//  EEBackView.h
//  EEBackView
//
//  Created by aosue on 2020/11/10.
//  Copyright © 2020 lzy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EEBackViewType) {
    EEBackViewTypeLeft = 0,
    EEBackViewTypeRight,
};

@class EEBackView;
@protocol EEBackViewDelegate <NSObject>

@optional
/// 左往右滑
-(void)goBack;
/// 右往左滑
- (void)goNext;

- (void)backView:(EEBackView *)backView didMoved:(CGFloat)progress;

@end

@interface EEBackView : UIView

@property (nonatomic,copy) void(^goBackBlock)(void);
@property (nonatomic,copy) void(^goNextBlock)(void);
@property (nonatomic, copy) void(^didMovedBlock)(CGFloat progress);

@property(nonatomic,weak) id <EEBackViewDelegate> delegate;

@property (nonatomic, assign) EEBackViewType type;

@end

NS_ASSUME_NONNULL_END
