//
//  HJWDrawingBoard.m
//  HJWDrawBoard
//
//  Created by Lemon_Mr.H on 2017/3/13.
//  Copyright © 2017年 Lemon_Mr.H. All rights reserved.
//

#import "HJWDrawingBoard.h"

@interface HJWBeizierPath : UIBezierPath
@property (nonatomic,copy) UIColor *lineColor;
@property (nonatomic,assign) BOOL isErase;

@end

@implementation HJWBeizierPath

@end

@interface HJWDrawingBoard()
@property (nonatomic, strong) NSMutableArray *beziPathArrM;

@property (nonatomic, strong) HJWBeizierPath *beziPath;

@end


@implementation HJWDrawingBoard
- (NSMutableArray *)beziPathArrM{
    if (!_beziPathArrM) {
        _beziPathArrM  = [NSMutableArray array];
    }
    return _beziPathArrM;
}

- (void)setIsErase:(BOOL)isErase{
    _isErase  = isErase;
    NSLog(@"setIsErase--%d",isErase);
}

#pragma mark - touch方法
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!self.isDrawing) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    
    CGPoint currentPoint = [touch locationInView:self];
    self.beziPath = [[HJWBeizierPath alloc] init];
    self.beziPath.lineColor = self.lineColor;
    self.beziPath.isErase = self.isErase;
    [self.beziPath moveToPoint:currentPoint];
    
    [self.beziPathArrM addObject:self.beziPath];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!self.isDrawing) {
        return;
    }

    UITouch *touch = [touches anyObject];
    
    CGPoint currentPoint = [touch locationInView:self];
    CGPoint previousPoint = [touch previousLocationInView:self];
    CGPoint midP = midPoint(previousPoint,currentPoint);
    
    // 如果需要点击出现圆点，可以注释这个if
    if (CGPointEqualToPoint(currentPoint, midP)) {
        return;
    }

    [self.beziPath addQuadCurveToPoint:currentPoint controlPoint:midP];
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!self.isDrawing) {
        return;
    }

    UITouch *touch = [touches anyObject];
    
    CGPoint currentPoint = [touch locationInView:self];
    CGPoint previousPoint = [touch previousLocationInView:self];
    CGPoint midP = midPoint(previousPoint,currentPoint);
    
    // 如果需要点击出现圆点，可以注释这个if
    if (CGPointEqualToPoint(currentPoint, midP)) {
        return;
    }
    
    [self.beziPath addQuadCurveToPoint:currentPoint controlPoint:midP];
    
    [self setNeedsDisplay];
}


// 计算中间点
CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

#pragma mark - 绘画方法
- (void)drawRect:(CGRect)rect
{
    //获取上下文
    if(self.beziPathArrM.count){
        for (HJWBeizierPath *path  in self.beziPathArrM) {
            if (path.isErase) {
                [[UIColor clearColor] setStroke];
            }else{
                [path.lineColor setStroke];
            }
            
            path.lineJoinStyle = kCGLineJoinRound;
            path.lineCapStyle = kCGLineCapRound;
            if (path.isErase) {
                path.lineWidth = 20;
                [path strokeWithBlendMode:kCGBlendModeCopy alpha:1.0];
            } else {
                path.lineWidth = 5;
                [path strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
            }
            [path stroke];
        }
    }
    [super drawRect:rect];
}

- (void)clear
{
    [self.beziPathArrM removeAllObjects];
    [self setNeedsDisplay];
}

@end
