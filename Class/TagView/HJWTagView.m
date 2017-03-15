//
//  HJWTextTagView.m
//  HJWDrawBoard
//
//  Created by Lemon_Mr.H on 2017/3/10.
//  Copyright © 2017年 Lemon_Mr.H. All rights reserved.
//

#import "HJWTagView.h"
#import "UIView+HJW.h"

#define kXSpace 8.0                              /** 距离父视图边界横向最小距离 */
#define kYSpace 0.0                              /** 距离俯视图边界纵向最小距离 */
#define kTagHorizontalSpace 20.0                 /** 标签左右空余距离 */
#define kTagVerticalSpace 10.0                   /** 标签上下空余距离 */
#define kPointWidth 8.0                          /** 白点直径 */
#define kPointSpace 2.0                          /** 白点和阴影尖角距离 */
#define kAngleLength (self.height / 2.0 - 2)     /** 黑色阴影尖交宽度 */
#define kDeleteBtnWidth self.height              /** 删除按钮宽度 */
#define kBackCornerRadius 2.0                    /** 黑色背景圆角半径 */

@implementation NSString (HJW)

- (CGFloat)__H__:(NSInteger)font W:(CGFloat)W
{
    return [self boundingRectWithSize:CGSizeMake(W, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:font] } context:nil].size.height;
}

//适合的宽度 默认 systemFontOfSize:font]
- (CGFloat)__W__:(NSInteger)font H:(CGFloat)H {
    return [self boundingRectWithSize:CGSizeMake(MAXFLOAT, H) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:font] } context:nil].size.width;
}

- (CGSize)sizeWithFont:(UIFont *)font maxW:(CGFloat)maxW {
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = font;
    CGSize maxSize = CGSizeMake(maxW, MAXFLOAT);
    
    NSLog(@"IOS7以上的系统");
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}
@end


typedef NS_ENUM(NSUInteger, HJWTagViewState) {
    HJWTagViewStateArrowLeft,
    HJWTagViewStateArrowRight,
    HJWTagViewStateArrowLeftWithDelete,
    HJWTagViewStateArrowRightWithDelete,
};

@interface HJWTagView ()

/** 状态 */
@property (nonatomic, assign) HJWTagViewState state;
/** tag信息 */
@property (nonatomic, strong) HJWTagData *tagInfo;
/** 拖动手势记录初始点 */
@property (nonatomic, assign) CGPoint panTmpPoint;
/** 白点中心 */
@property (nonatomic, assign) CGPoint arrowPoint;

/** 黑色背景 */
@property (nonatomic, weak) CAShapeLayer *backLayer;
/** 白点 */
@property (nonatomic, weak) CAShapeLayer *pointLayer;
/** 白点动画阴影 */
@property (nonatomic, weak) CAShapeLayer *pointShadowLayer;
/** 标题 */
@property (nonatomic, weak) UILabel *titleLabel;
/** 删除按钮 */
@property (nonatomic, weak) UIButton *deleteBtn;
/** 分割线 */
@property (nonatomic, weak) UIView *cuttingLine;

@end


@implementation HJWTagView
- (instancetype)initWithTagInfo:(HJWTagData *)tagInfo
{
    self = [super init];
    if (self) {
        
        self.tagInfo = tagInfo;
        self.isEditEnabled = YES;
        // 子控件
        [self createSubviews];
        // 手势处理
        [self setupGesture];
    }
    return self;
}


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    // 调整UI
    [self layoutWithTitle:self.tagInfo.title superview:newSuperview];
}


#pragma mark - getter and setter
- (CGPoint)arrowPoint
{
    CGPoint arrowPoint;
    if (self.state == HJWTagViewStateArrowLeft) {
        arrowPoint = CGPointMake(self.x + kPointWidth / 2.0, self.centerY);
    }else if (self.state == HJWTagViewStateArrowRight) {
        arrowPoint = CGPointMake(self.right - kPointWidth / 2.0, self.centerY);
    }else if (self.state == HJWTagViewStateArrowLeftWithDelete) {
        arrowPoint = CGPointMake(self.x + kPointWidth / 2.0, self.centerY);
    }else if(self.state == HJWTagViewStateArrowRightWithDelete) {
        arrowPoint = CGPointMake(self.right - kPointWidth / 2.0, self.centerY);
    }
    return arrowPoint;
}

- (void)setArrowPoint:(CGPoint)arrowPoint
{
    self.centerY = arrowPoint.y;
    if (self.state == HJWTagViewStateArrowLeft) {
        self.x = arrowPoint.x - kPointWidth / 2.0;
    }else if (self.state == HJWTagViewStateArrowRight) {
        self.right = arrowPoint.x + kPointWidth / 2.0;
    }else if (self.state == HJWTagViewStateArrowLeftWithDelete) {
        self.x = arrowPoint.x - kPointWidth / 2.0;
    }else if(self.state == HJWTagViewStateArrowRightWithDelete) {
        self.right = arrowPoint.x + kPointWidth / 2.0;
    }
}

#pragma mark - private methods
- (void)createSubviews
{
    CAShapeLayer *backLayer = [[CAShapeLayer alloc] init];
    backLayer.fillColor = [[UIColor blackColor] colorWithAlphaComponent:.7].CGColor;
    backLayer.shadowOffset = CGSizeMake(0, 2);
    backLayer.shadowColor = [UIColor blackColor].CGColor;
    backLayer.shadowRadius = 3;
    backLayer.shadowOpacity = 0.5;
    [self.layer addSublayer:backLayer];
    self.backLayer = backLayer;
    
    CAShapeLayer *pointShadowLayer = [[CAShapeLayer alloc] init];
    pointShadowLayer.hidden = YES;
    pointShadowLayer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3].CGColor;;
    [self.layer addSublayer:pointShadowLayer];
    self.pointShadowLayer = pointShadowLayer;
    
    CAShapeLayer *pointLayer = [[CAShapeLayer alloc] init];
    pointLayer.backgroundColor =[UIColor whiteColor].CGColor;
    pointLayer.shadowOffset = CGSizeMake(0, 1);
    pointLayer.shadowColor = [UIColor blackColor].CGColor;
    pointLayer.shadowRadius = 1.5;
    pointLayer.shadowOpacity = 0.2;
    [self.layer addSublayer:pointLayer];
    self.pointLayer = pointLayer;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBtn addTarget:self action:@selector(clickDeleteBtn) forControlEvents:UIControlEventTouchUpInside];
    [deleteBtn setImage:[UIImage imageNamed:@"X"] forState:UIControlStateNormal];
    [self addSubview:deleteBtn];
    self.deleteBtn = deleteBtn;
    
    UIView *cuttingLine = [[UIView alloc] init];
    cuttingLine.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
    [self addSubview:cuttingLine];
    self.cuttingLine = cuttingLine;
}

- (void)setupGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tap];
    
    UILongPressGestureRecognizer *lop = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self addGestureRecognizer:lop];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:pan];
}

- (void)layoutWithTitle:(NSString *)title superview:(UIView *)superview
{
    // 调整label的大小
    if (title.length == 0) {
        // 语音
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.text = title;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;

        // 添加表情
        NSTextAttachment *attch = [[NSTextAttachment alloc] init];
        // 表情图片
        attch.image = [UIImage imageNamed:@"icon_play"];
        // 设置图片大小
        attch.bounds = CGRectMake(0, 0, 20, 20);
        // 创建带有图片的富文本
        NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attch];
        
        // 创建一个富文本
        NSMutableAttributedString *attri =     [[NSMutableAttributedString alloc] initWithString:@"10s"];
        
        // 修改富文本中的不同文字的样式
        [attri addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]
                      range:NSMakeRange(0, 3)];
        [attri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12]
                      range:NSMakeRange(0, 3)];
        [attri addAttribute:NSBaselineOffsetAttributeName value:@(5)
                      range:NSMakeRange(0, 3)];
        [attri insertAttributedString:string atIndex:0];
        
        // 用label的attributedText属性来使用富文本
        self.titleLabel.attributedText = attri;

        self.titleLabel.width = 40 + kTagHorizontalSpace;
        self.titleLabel.height = 24.5 + kTagVerticalSpace;
    }else {
        
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.text = title;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        CGFloat titleWidth = [title __W__:12.f H:24.5];
        if (titleWidth > [UIScreen mainScreen].bounds.size.width / 3) {
            titleWidth = [UIScreen mainScreen].bounds.size.width / 3;
        }
        
        self.titleLabel.width = titleWidth + kTagHorizontalSpace;
        self.titleLabel.height = 24.5 + kTagVerticalSpace;
    }
    //    self.titleLabel.width += kTagHorizontalSpace;
    //    self.titleLabel.height += kTagVerticalSpace;
    
    // 调整子控件UI
    HJWTagViewState state = self.state;
    CGPoint point = self.tagInfo.point;
    
    if (CGPointEqualToPoint(self.tagInfo.point, CGPointZero)) {
        // 没有point,利用位置比例proportion
        CGFloat x = superview.width * self.tagInfo.proportion.x;
        CGFloat y = superview.height * self.tagInfo.proportion.y;
        point = CGPointMake(x, y);
    }
    
    if (self.tagInfo.direction == HJWTagDirectionNormal) {
        if (point.x < superview.width / 2.0) {
            state = HJWTagViewStateArrowLeft;
        }else{
            state = HJWTagViewStateArrowRight;
        }
    }else{
        if (self.tagInfo.direction == HJWTagDirectionLeft) {
            state = HJWTagViewStateArrowLeft;
        }else{
            state = HJWTagViewStateArrowRight;
        }
    }
    [self layoutSubviewsWithState:state arrowPoint:point];
    
    // 处理特殊初始点情况
    if (state == HJWTagViewStateArrowLeft) {
        if (self.x < kXSpace) {
            self.x = kXSpace;
        }
    }else{
        if (self.x > superview.width - kXSpace - self.width) {
            self.x = superview.width - kXSpace - self.width;
        }
    }
    if (self.y < kYSpace) {
        self.y = kYSpace;
    }else if (self.y > (superview.height - kYSpace - self.height)){
        self.y = superview.height - kYSpace - self.height;
    }
    
    // 更新tag信息
    [self updateLocationInfoWithSuperview:superview];
}

- (void)layoutSubviewsWithState:(HJWTagViewState)state arrowPoint:(CGPoint)arrowPoint
{
    self.state = state;
    
    // 利用事务关闭隐式动画
    [CATransaction setDisableActions:YES];
    
    UIBezierPath *backPath = [UIBezierPath bezierPath];
    self.pointLayer.bounds = CGRectMake(0, 0, kPointWidth, kPointWidth);
    self.pointLayer.cornerRadius = kPointWidth / 2.0;
    self.height = self.titleLabel.height;
    self.centerY = arrowPoint.y;
    self.titleLabel.y = 0;
    
    if (state == HJWTagViewStateArrowLeft || state == HJWTagViewStateArrowRight) {
        // 无关闭按钮
        self.width = self.titleLabel.width + kAngleLength + kPointWidth + kPointSpace;
        // 隐藏关闭及分割线
        self.deleteBtn.hidden = YES;
        self.cuttingLine.hidden = YES;
    }else{
        // 有关闭按钮
        self.width = self.titleLabel.width + kAngleLength + kPointWidth + kPointSpace +kDeleteBtnWidth;
        // 关闭按钮
        self.deleteBtn.hidden = NO;
        self.cuttingLine.hidden = NO;
    }
    
    if (state == HJWTagViewStateArrowLeft || state == HJWTagViewStateArrowLeftWithDelete) {
        // 根据字调整控件大小
        self.x = arrowPoint.x - kPointWidth / 2.0;
        // 背景
        [backPath moveToPoint:CGPointMake(kPointWidth + kPointSpace, self.height / 2.0)];
        [backPath addLineToPoint:CGPointMake(kPointWidth + kPointSpace + kAngleLength, 0)];
        [backPath addLineToPoint:CGPointMake(self.width - kBackCornerRadius, 0)];
        [backPath addArcWithCenter:CGPointMake(self.width - kBackCornerRadius, kBackCornerRadius) radius:kBackCornerRadius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
        [backPath addLineToPoint:CGPointMake(self.width, self.height - kBackCornerRadius)];
        [backPath addArcWithCenter:CGPointMake(self.width - kBackCornerRadius, self.height - kBackCornerRadius) radius:kBackCornerRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
        [backPath addLineToPoint:CGPointMake(kPointWidth + kPointSpace + kAngleLength, self.height)];
        [backPath closePath];
        // 点
        self.pointLayer.position = CGPointMake(kPointWidth / 2.0, self.height / 2.0);
        // 标签
        self.titleLabel.x = kPointWidth + kAngleLength;
        
        if (state == HJWTagViewStateArrowLeftWithDelete) {
            // 关闭
            self.deleteBtn.frame = CGRectMake(self.width - kDeleteBtnWidth, 0, kDeleteBtnWidth, kDeleteBtnWidth);
            self.cuttingLine.frame = CGRectMake(self.deleteBtn.x - 0.5, 0, 0.5, self.height);
        }
        
    }else if(state == HJWTagViewStateArrowRight || state == HJWTagViewStateArrowRightWithDelete) {
        // 根据字调整控件大小
        self.right = arrowPoint.x + kPointWidth / 2.0;
        // 背景
        [backPath moveToPoint:CGPointMake(self.width - kPointWidth - kPointSpace, self.height / 2.0)];
        [backPath addLineToPoint:CGPointMake(self.width - kAngleLength - kPointWidth - kPointSpace, self.height)];
        [backPath addLineToPoint:CGPointMake(kBackCornerRadius, self.height)];
        [backPath addArcWithCenter:CGPointMake(kBackCornerRadius, self.height - kBackCornerRadius) radius:kBackCornerRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
        [backPath addLineToPoint:CGPointMake(0, kBackCornerRadius)];
        [backPath addArcWithCenter:CGPointMake(kBackCornerRadius, kBackCornerRadius) radius:kBackCornerRadius startAngle:M_PI endAngle:M_PI + M_PI_2 clockwise:YES];
        [backPath addLineToPoint:CGPointMake(self.width - kAngleLength - kPointWidth - kPointSpace, 0)];
        [backPath closePath];
        // 点
        self.pointLayer.position = CGPointMake(self.width - kPointWidth / 2.0, self.height / 2.0);
        
        if (state == HJWTagViewStateArrowRight) {
            // 标签
            self.titleLabel.x = 0;
        }else{
            // 标签
            self.titleLabel.x = kDeleteBtnWidth;
            // 关闭
            self.deleteBtn.frame = CGRectMake(0, 0, kDeleteBtnWidth, kDeleteBtnWidth);
            self.cuttingLine.frame = CGRectMake(self.deleteBtn.right + 0.5, 0, 0.5, self.height);
        }
    }
    
    self.backLayer.path = backPath.CGPath;
    self.pointShadowLayer.bounds = self.pointLayer.bounds;
    self.pointShadowLayer.position = self.pointLayer.position;
    self.pointShadowLayer.cornerRadius = self.pointLayer.cornerRadius;
    
    [CATransaction setDisableActions:NO];
}

- (void)changeLocationWithGestureState:(UIGestureRecognizerState)gestureState locationPoint:(CGPoint)point
{
    if (self.isEditEnabled == NO) {
        return;
    }
    
    CGPoint referencePoint = CGPointMake(0, point.y + self.height / 2.0);
    switch (self.state) {
        case HJWTagViewStateArrowLeft:
        case HJWTagViewStateArrowLeftWithDelete:
            referencePoint.x = point.x + kPointWidth / 2.0;
            break;
        case HJWTagViewStateArrowRight:
        case HJWTagViewStateArrowRightWithDelete:
            referencePoint.x = point.x + self.width - kPointWidth / 2.0;
            break;
        default:
            break;
    }
    
    if (referencePoint.x < kXSpace + kPointWidth / 2.0) {
        referencePoint.x = kXSpace + kPointWidth / 2.0;
    }else if (referencePoint.x > self.superview.width - kXSpace - kPointWidth /2.0){
        referencePoint.x = self.superview.width - kXSpace - kPointWidth /2.0;
    }
    
    if (referencePoint.y < kYSpace + self.height / 2.0 ) {
        referencePoint.y = kYSpace + self.height / 2.0;
    }else if (referencePoint.y > self.superview.height - kYSpace - self.height / 2.0){
        referencePoint.y = self.superview.height - kYSpace - self.height / 2.0;
    }
    // 更新位置
    self.arrowPoint = referencePoint;
    
    if (gestureState == UIGestureRecognizerStateEnded) {
        // 翻转
        switch (self.state) {
            case HJWTagViewStateArrowLeft:
            case HJWTagViewStateArrowLeftWithDelete:
            {
                if (self.right > self.superview.width - kXSpace - kDeleteBtnWidth
                    && self.arrowPoint.x > self.superview.width / 2.0) {
                    [self layoutSubviewsWithState:HJWTagViewStateArrowRight arrowPoint:self.arrowPoint];
                }
            }
                break;
            case HJWTagViewStateArrowRight:
            case HJWTagViewStateArrowRightWithDelete:
                if (self.x < kXSpace + kDeleteBtnWidth
                    && self.arrowPoint.x < self.superview.width / 2.0) {
                    [self layoutSubviewsWithState:HJWTagViewStateArrowLeft arrowPoint:self.arrowPoint];
                }
                break;
            default:
                break;
        }
        // 更新tag信息
        [self updateLocationInfoWithSuperview:self.superview];
    }
}

- (void)updateLocationInfoWithSuperview:(UIView *)superview
{
    if (superview == nil) {
        // 被移除的时候也会调用 willMoveToSuperview
        return;
    }
    // 更新point 以及 direction
    if (self.state == HJWTagViewStateArrowLeft || self.state == HJWTagViewStateArrowLeftWithDelete) {
        self.tagInfo.point = CGPointMake(self.x + kPointWidth / 2, self.y + self.height / 2.0);
        self.tagInfo.direction = HJWTagDirectionLeft;
    }else{
        self.tagInfo.point = CGPointMake(self.right - kPointWidth / 2, self.y + self.height / 2.0);
        self.tagInfo.direction = HJWTagDirectionRight;
    }
    // 更新proportion
    if (superview.width > 0 && superview.height > 0) {
        self.tagInfo.proportion = HJWPositionProportionMake(self.tagInfo.point.x / superview.width, self.tagInfo.point.y / superview.height);
    }
}

#pragma mark - event response
- (void)handleTapGesture:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded) {
        [self.superview bringSubviewToFront:self];
        if ([self.delegate respondsToSelector:@selector(tagViewActiveTapGesture:)]) {
            [self.delegate tagViewActiveTapGesture:self];
        }else{
            // 默认 切换删除按钮状态
            [self switchDeleteState];
        }
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)lop
{
    if (lop.state == UIGestureRecognizerStateBegan) {
        [self.superview bringSubviewToFront:self];
        if ([self.delegate respondsToSelector:@selector(tagViewActiveLongPressGesture:)]) {
            [self.delegate tagViewActiveLongPressGesture:self];
        }
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan
{
    CGPoint panPoint = [pan locationInView:self.superview];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self hiddenDeleteBtn];
            [self.superview bringSubviewToFront:self];
            self.panTmpPoint = [pan locationInView:self];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [self changeLocationWithGestureState:UIGestureRecognizerStateChanged
                                   locationPoint:CGPointMake(panPoint.x - self.panTmpPoint.x, panPoint.y - self.panTmpPoint.y)];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self changeLocationWithGestureState:UIGestureRecognizerStateEnded
                                   locationPoint:CGPointMake(panPoint.x - self.panTmpPoint.x, panPoint.y - self.panTmpPoint.y)];
            self.panTmpPoint = CGPointZero;
            if ([self.delegate respondsToSelector:@selector(tagViewActivePanGesture:)]) {
                [self.delegate tagViewActivePanGesture:self];
            }
        }
            break;
        default:
            break;
    }
}

- (void)clickDeleteBtn
{
    [self removeFromSuperview];
}

- (void)clickInfoBtn {
    NSLog(@"%@", @"查看详情");
}

#pragma mark - public methods
- (void)updateTitle:(NSString *)title
{
    self.tagInfo.title = title;
    [self layoutWithTitle:title superview:self.superview];
}

- (void)showAnimationWithRepeatCount:(float)repeatCount
{
    CAKeyframeAnimation *cka = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    cka.values =   @[@0.7, @1.32, @1,   @1];
    cka.keyTimes = @[@0.0, @0.3,  @0.3, @1];
    cka.repeatCount = repeatCount;
    cka.duration = 1.8;
    [self.pointLayer addAnimation:cka forKey:@"cka"];
    
    CAKeyframeAnimation *cka2 = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    cka2.values =   @[@0.7, @0.9, @0.9, @3.5,  @0.9,  @3.5];
    cka2.keyTimes = @[@0.0, @0.3, @0.3, @0.65, @0.65, @1];
    cka2.repeatCount = repeatCount;
    cka2.duration = 1.8;
    self.pointShadowLayer.hidden = NO;
    [self.pointShadowLayer addAnimation:cka2 forKey:@"cka2"];
}

- (void)removeAnimation
{
    [self.pointLayer removeAnimationForKey:@"cka"];
    [self.pointShadowLayer removeAnimationForKey:@"cka2"];
    self.pointShadowLayer.hidden = YES;
}

- (void)showDeleteBtn
{
    if (self.isEditEnabled == NO) {
        return;
    }
    if (self.state == HJWTagViewStateArrowLeft) {
        [self layoutSubviewsWithState:HJWTagViewStateArrowLeftWithDelete arrowPoint:self.arrowPoint];
    }else if (self.state == HJWTagViewStateArrowRight) {
        [self layoutSubviewsWithState:HJWTagViewStateArrowRightWithDelete arrowPoint:self.arrowPoint];
    }
}

- (void)hiddenDeleteBtn
{
    if (self.state == HJWTagViewStateArrowLeftWithDelete) {
        [self layoutSubviewsWithState:HJWTagViewStateArrowLeft arrowPoint:self.arrowPoint];
    }else if(self.state == HJWTagViewStateArrowRightWithDelete) {
        [self layoutSubviewsWithState:HJWTagViewStateArrowRight arrowPoint:self.arrowPoint];
    }
}

- (void)switchDeleteState
{
    if (self.state == HJWTagViewStateArrowLeft || self.state == HJWTagViewStateArrowRight) {
        [self showDeleteBtn];
    }else {
        [self hiddenDeleteBtn];
    }
}

@end
