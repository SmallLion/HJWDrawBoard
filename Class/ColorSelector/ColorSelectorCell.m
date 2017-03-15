//
//  ColorSelectorCell.m
//  HJWDrawBoard
//
//  Created by Lemon_Mr.H on 2017/3/13.
//  Copyright © 2017年 Lemon_Mr.H. All rights reserved.
//

#import "ColorSelectorCell.h"

//#define kRandomColor [UIColor colorWithRed:arc4random() % 255 / 255.0 green:arc4random() % 255 / 255.0 blue:arc4random() % 255 / 255.0 alpha:arc4random() % 255 / 255.0]

@implementation ColorSelectorCell
@dynamic selected;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _colorView.layer.cornerRadius = 8;
    _colorView.layer.masksToBounds = YES;
    
    _colorView.userInteractionEnabled = YES;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnClick:)];
    [_colorView addGestureRecognizer:tapGesture];
}

- (IBAction)btnClick:(id)sender {
    if (self.clickBlock) {
        self.clickBlock(self);
    }
}

- (void)setCircleColor:(UIColor *)circleColor {
    _circleColor = circleColor;
    _colorView.backgroundColor = circleColor;
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        // _colorView.layer.borderColor = [UIColor whiteColor].CGColor;
        // _colorView.layer.borderWidth = .75f;
        [self drawWhiteCircle];
    }else {
        // _colorView.layer.borderColor = [UIColor clearColor].CGColor;
        // _colorView.layer.borderWidth = 0.f;
        [self removeWhiteCircle];
    }
}

- (void)drawWhiteCircle {
    CAShapeLayer * circle = [CAShapeLayer layer];
    circle.bounds = 
    CGRectMake(0, 0, _colorSelectBtn.frame.size.width, _colorSelectBtn.frame.size.height);
    circle.position = _colorSelectBtn.center;
    [self.layer addSublayer:circle];
    
    UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:_colorSelectBtn.center
                                                         radius:10
                                                     startAngle:0.0
                                                       endAngle:M_PI * 2
                                                      clockwise:YES];
    circle.path = path.CGPath;
    circle.strokeColor = [UIColor whiteColor].CGColor;
    circle.fillColor = [UIColor clearColor].CGColor;
}

- (void)removeWhiteCircle {
    for (id obj in self.layer.sublayers) {
        if ([obj isKindOfClass:[CAShapeLayer class]]) {
            CAShapeLayer * layer = (CAShapeLayer *)obj;
            [layer removeFromSuperlayer];
        }
    }
}
@end
