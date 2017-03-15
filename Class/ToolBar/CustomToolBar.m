//
//  CustomToolBar.m
//  HJWCustomTooler
//
//  Created by Lion_Lemon on 16/3/3.
//  Copyright © 2016年 Lion_Lemon. All rights reserved.
//

#import "CustomToolBar.h"
#import "UIView+HJW.h"

@interface CustomToolBar ()
@property (nonatomic, strong) UIBarButtonItem * flexBarItem;
@property (nonatomic, strong) NSMutableArray * btns;

@property (nonatomic, assign, getter = isShow) BOOL show;

@end

@implementation CustomToolBar
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.flexBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        self.items = @[self.flexBarItem];
    }
    return self;
}

- (void)setItemImages:(NSArray *)ItemImages {
    _ItemImages = ItemImages;
    
    self.btns = @[].mutableCopy;
    
    NSMutableArray * items = @[].mutableCopy;
    
    for (NSInteger i = 0; i < ItemImages.count; i++) {
        
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 80, 44);
        button.tag = 100 + i;
        [button setImage:[UIImage imageNamed:ItemImages[i]] forState:UIControlStateNormal];
        
        if (self.titlesArray.count != 0) {
            [button setTitle:self.titlesArray[i] forState:UIControlStateNormal];
            [button setImageEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -50, 0, 0)];
        }
        
        [button addTarget:self action:@selector(didOnclickButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.btns addObject:button];
        
        UIBarButtonItem * collectItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        [items addObject:self.flexBarItem];
        [items addObject:collectItem];
        
    }
    [items addObject:self.flexBarItem];
    self.items = items;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    for (UIButton * button in self.btns) {
        [button setTitleColor:textColor forState:UIControlStateNormal];
    }
}

- (void)didOnclickButton:(UIButton *)button {
    if (_ToolBarDelegate && [_ToolBarDelegate respondsToSelector:@selector(toolBar:didClickBtn:atIndex:)]) {
        [_ToolBarDelegate toolBar:self didClickBtn:button atIndex:button.tag - 100];
    }
}

- (void)reSetAllBtnSelectStatus {
    for (UIButton * button in self.btns) {
        button.selected = NO;
    }
}

- (void)showAnimation {
    if(self.isShow && self.isHidden == NO) {
        return;
    }
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.9f initialSpringVelocity:0.7f
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         self.hidden = NO;
                         self.y = [UIScreen mainScreen].bounds.size.height - self.bounds.size.height;
                     } completion:^(BOOL finished) {
                         self.show = YES;
                     }];
}

- (void)closeAnimation {
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.9f initialSpringVelocity:0.7f
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         self.y = [UIScreen mainScreen].bounds.size.height;
                     } completion:^(BOOL finished) {
                         self.hidden = YES;
                         self.show = NO;
                     }];
}
@end
