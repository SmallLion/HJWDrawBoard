//
//  OpenGLDrawView.h
//  HJWDrawBoard
//
//  Created by Lemon_Mr.H on 2017/3/15.
//  Copyright © 2017年 Lemon_Mr.H. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenGLDrawView : UIView
/**
 *  画线的颜色
 */
@property (nonatomic, strong) UIColor *lineColor;
/**
 *  是否是橡皮擦状态
 */
@property (nonatomic, assign) BOOL isErase;
/**
 * 画板状态
 */
@property (nonatomic, assign, getter=isDrawing) BOOL drawing;
/**
 *  清楚画笔
 */
- (void)clear;

@end
