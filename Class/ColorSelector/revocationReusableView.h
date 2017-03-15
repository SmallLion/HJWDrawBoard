//
//  revocationReusableView.h
//  HJWDrawBoard
//
//  Created by Lemon_Mr.H on 2017/3/13.
//  Copyright © 2017年 Lemon_Mr.H. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^clearBtnClickBlock) ();

@interface revocationReusableView : UICollectionReusableView

@property (nonatomic, copy) clearBtnClickBlock clearBtnClick;

@end
