//
//  EEBackView.m
//  EEBackView
//
//  Created by aosue on 2020/11/10.
//  Copyright © 2020 lzy. All rights reserved.
//

#import "EEBackView.h"

/** 注释代码不要删
 *  原demo是有返回图标的, 类似于安卓
 *  现改成高德的返回样式
 */
const static CGFloat EEBacklength = 50; // 触发返回事件的区间

// 这些距离都可以调整
const static CGFloat sep = 100;
const static CGFloat control = 40;
const static CGFloat end = 60;
const static CGFloat margin = sep + end + sep;

@interface EEBackView (){
    CGFloat pointYY;
    CGFloat pointXX;
}
@property (nonatomic,strong) CAShapeLayer *popLayer;
//@property (nonatomic,strong) UIImageView *backImageView;
@property (nonatomic,strong) CADisplayLink *displayLink;
@end

@implementation EEBackView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}
-(void)setUp {
    self.backgroundColor = [UIColor clearColor];
    
    _popLayer = [CAShapeLayer new];
    _popLayer.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    _popLayer.strokeColor = [UIColor clearColor].CGColor;//[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor;
    
    [self.layer addSublayer:_popLayer];
//    [self addSubview:self.backImageView];
    
}

-(void)updatePath {
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 0.0;
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;


    if (self.type == EEBackViewTypeLeft) {
        [path moveToPoint:CGPointMake(-1, pointYY)];
        [path addQuadCurveToPoint:CGPointMake(-1, pointYY+margin) controlPoint:CGPointMake(120*pointXX, pointYY+0.5 * margin)];
    } else {
        [path moveToPoint:CGPointMake(self.frame.size.width + 1, pointYY)];
        [path addQuadCurveToPoint:CGPointMake(self.frame.size.width + 1, pointYY+margin) controlPoint:CGPointMake(self.frame.size.width + 1 - 120*pointXX, pointYY+0.5 * margin)];
    }

    [path stroke];
    _popLayer.path = path.CGPath;
}


-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [(UITouch *)[touches anyObject] locationInView:self];
    if (self.type == EEBackViewTypeLeft) {
        if (point.x < EEBacklength) {
            pointXX = point.x/EEBacklength/2.0;
            [self updatePath];
        }
    } else {
        if (point.x > self.frame.size.width - EEBacklength) {
            pointXX = (self.frame.size.width - point.x)/EEBacklength/2.0;
            [self updatePath];
        }
    }

    if (self.didMovedBlock) {
        self.didMovedBlock(pointXX);
    } else if ([self respondsToSelector:@selector(backView:didMoved:)]) {
        [self.delegate backView:self didMoved:pointXX];
    }
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [(UITouch *)[touches anyObject] locationInView:self];

    if (self.type == EEBackViewTypeLeft) {
        if (point.x > EEBacklength) {
            // printf("\n返回上一页\n");
            UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleHeavy];
            [generator prepare];
            [generator impactOccurred];
            if (self.goBackBlock) {
                self.goBackBlock();
            } else if ([self.delegate respondsToSelector:@selector(goBack)]) {
                [self.delegate goBack];
            }
        }
    } else {
        if (point.x < self.frame.size.width - EEBacklength) {
            // printf("\n返回下一页\n");
            UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleHeavy];
            [generator prepare];
            [generator impactOccurred];
            if (self.goNextBlock) {
                self.goNextBlock();
            } else if ([self.delegate respondsToSelector:@selector(goNext)]) {
                [self.delegate goNext];
            }
        }
    }

    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(backAnimation)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint point = [(UITouch *)[touches anyObject] locationInView:self];
    pointYY = point.y - margin / 2;
}


-(void)backAnimation{
    if (pointXX >= 0) {
        pointXX = pointXX- 0.02;
        [self updatePath];
//        self.backImageView.alpha = (pointXX-0.18)*16;
    }else{
        [self stopAnimation];
//        self.backImageView.alpha = 0;
    }
}

- (void)stopAnimation{
    self.displayLink.paused = YES;
    [self.displayLink invalidate];
    self.displayLink = nil;
}
-(void)dealloc {
    [self stopAnimation];
}
@end
