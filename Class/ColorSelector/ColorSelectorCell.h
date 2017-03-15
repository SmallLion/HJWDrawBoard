//
//  ColorSelectorCell.h
//  HJWDrawBoard
//
//  Created by Lemon_Mr.H on 2017/3/13.
//  Copyright © 2017年 Lemon_Mr.H. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ColorSelectorCell;

typedef void(^colorSelectorClickBlock)(ColorSelectorCell * cell);

@interface ColorSelectorCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *colorSelectBtn;

@property (weak, nonatomic) IBOutlet UIView *colorView;

@property (nonatomic, copy) colorSelectorClickBlock clickBlock;

@property (nonatomic, assign, getter=isSelected) BOOL selected;

@property (nonatomic, strong) UIColor * circleColor;


@end
