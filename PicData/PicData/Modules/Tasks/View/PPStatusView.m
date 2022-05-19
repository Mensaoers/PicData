//
//  PPStatusView.m
//  ThinkDrive_For_iPhone
//
//  Created by Garenge on 2019/2/28.
//  Copyright © 2019 Richinfo. All rights reserved.
//

#import "PPStatusView.h"

@interface PPStatusView()

@end

@implementation PPStatusView {
    CGFloat _currentProgress;
    CAShapeLayer *_backgroundLineLayer;
    CAShapeLayer *_progressLineLayer;
}

- (void)loadDefaultValue {
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touched)];
    [self addGestureRecognizer:tapGes];
    
    _currentProgress = 0.0f;
    
    self.showProgress = YES;
    self.progress = 0.0;
    UIColor *color = [UIColor colorWithRed:186 / 255.0 green:186 / 255.0 blue:186 / 255.0 alpha:1.0];
    self.innerColor = color;
    self.lineBGColor = color;
    self.lineBGWidth = 3.0f;
    self.lineColor = [UIColor redColor];
    self.lineWidth = 3.0f;
    self.duration = 0.4;
    
    _backgroundLineLayer = [CAShapeLayer layer];
    [self.layer addSublayer:_backgroundLineLayer];
    _progressLineLayer = [CAShapeLayer layer];
    [self.layer addSublayer:_progressLineLayer];
}

- (void)show {
    [self updateWithProgress:self.progress];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self loadDefaultValue];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame showProgress:(BOOL)showProgress {
    if (self = [super initWithFrame:frame]) {
        [self loadDefaultValue];
        self.showProgress = showProgress;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame showProgress:(BOOL)showProgress progress:(CGFloat)progress {
    if (self = [super initWithFrame:frame]) {
        [self loadDefaultValue];
        self.showProgress = showProgress;
        self.progress = progress;
    }
    return self;
}

- (void)updateWithProgress:(CGFloat)progress {
    [self updateWithProgress:progress animated:NO];
}

- (void)updateWithProgress:(CGFloat)progress animated:(BOOL)animated {
    // Boundry correctness
    progress = MIN(progress, 1.0);
    progress = MAX(progress, 0.0);
    
    _progress = progress;
    
    CGFloat borderWidth = MAX(_lineWidth, _lineBGWidth);
    CGFloat radius = (MIN(self.bounds.size.width, self.bounds.size.height) / 2.0) - borderWidth;
    CGFloat diameter = (radius * 2.0);
    CGRect cirlceRect = CGRectMake(self.bounds.size.width * 0.5 - radius, self.bounds.size.height * 0.5 - radius, diameter, diameter);
    CGPathRef path = [self _createCirclePathRefForRect:cirlceRect];
    
    _backgroundLineLayer.path = path;
    _backgroundLineLayer.fillColor = [UIColor clearColor].CGColor;
    _backgroundLineLayer.strokeColor = _lineBGColor.CGColor;
    _backgroundLineLayer.lineWidth = _lineBGWidth;
    
    if (self.showProgress) {
        _progressLineLayer.hidden = NO;
        _progressLineLayer.path = _backgroundLineLayer.path;
        _progressLineLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLineLayer.strokeColor = _lineColor.CGColor;
        _progressLineLayer.lineWidth = _lineWidth;
//    if (!self.showProgress) {
//        _currentProgress = 0;
//        _progress = 0;
//    }
    } else {
        _progressLineLayer.hidden = YES;
        _currentProgress = 0.0;
        _progress = 0.0;
    }
    CFTimeInterval animationDuration = (animated ? _duration : 0.0);
        [_progressLineLayer addAnimation:[self _fillAnimationWithDuration:animationDuration] forKey:@"strokeEnd"];
        _currentProgress = _progress;
    
    CGPathRelease(path);
}

#pragma mark - Private Methods

- (CABasicAnimation *)_fillAnimationWithDuration:(CFTimeInterval)duration {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = duration;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeBoth;
    animation.fromValue = @(_currentProgress);
    animation.toValue = @(_progress);
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animation;
}

- (CGPathRef)_createCirclePathRefForRect:(CGRect)rect {
    /**
     CGPathAddEllipseInRect creates the path in an anticlockwise direction and
     the "strokeEnd" values/animation is reverted. By creating the path ourselfs we ensure
     that the direction is clockwise and the animation direction is correct.
     */
    CGFloat radius = (rect.size.width / 2);
    CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, midx + 0.5, miny + 0.5);
    CGPathAddArcToPoint(path, NULL, maxx + 0.5, miny + 0.5, maxx + 0.5, midy + 0.5, radius);
    CGPathAddArcToPoint(path, NULL, maxx + 0.5, maxy + 0.5, midx + 0.5, maxy + 0.5, radius);
    CGPathAddArcToPoint(path, NULL, minx + 0.5, maxy + 0.5, minx + 0.5, midy + 0.5, radius);
    CGPathAddArcToPoint(path, NULL, minx + 0.5, miny + 0.5, midx + 0.5, miny + 0.5, radius);
    CGPathCloseSubpath(path);
    return path;
}

- (void)touched {
    if (self.delegate && [self.delegate respondsToSelector:@selector(statusViewTouched:)]) {
        [self.delegate statusViewTouched:self];
    }
}

@end
