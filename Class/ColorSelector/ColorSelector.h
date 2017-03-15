//
//  ColorSelector.h
//  HJWDrawBoard
//
//  Created by Lemon_Mr.H on 2017/3/13.
//  Copyright © 2017年 Lemon_Mr.H. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ColorSelector;
@protocol ColorSelectorDelegate <NSObject>

- (void)ColorSelector:(ColorSelector *)ColorSelector didSelectedColor:(UIColor *)color;

- (void)ColorSelectorDidClickClear:(ColorSelector *)ColorSelector;
@end

@interface ColorSelector : UIView

@property (nonatomic, weak)id<ColorSelectorDelegate> delegate;

- (void)defaultSelectFirstColor;

- (void)showAnimation;

- (void)closeAnimation;

@end
