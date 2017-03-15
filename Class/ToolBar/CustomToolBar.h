//
//  CustomToolBar.h
//  HJWCustomTooler
//
//  Created by Lion_Lemon on 16/3/3.
//  Copyright © 2016年 Lion_Lemon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, didClickType){
    ClickTypeVideo,
    ClickTypeImage,
    ClickTypeSound,
    ClickTypeFile,
    ClickTypeLink,
    ClickTypeAtOne,
    ClickTypeNone
};

@class CustomToolBar;
@protocol CustomToolBarDelegate <NSObject>

- (void)toolBar:(CustomToolBar *)tool didClickBtn:(UIButton *)btn atIndex:(NSInteger)index;

@end

@interface CustomToolBar : UIToolbar
@property (nonatomic, strong) NSArray * ItemImages, * titlesArray;
@property (nonatomic, copy) UIColor * textColor;

@property (nonatomic, weak) id <CustomToolBarDelegate> ToolBarDelegate;

- (void)reSetAllBtnSelectStatus;

- (void)showAnimation;

- (void)closeAnimation;

@end
