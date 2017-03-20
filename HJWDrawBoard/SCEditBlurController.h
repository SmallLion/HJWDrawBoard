//
//  SCEditBlurController.h
//  StudyChat
//
//  Created by Lemon_Mr.H on 2017/3/20.
//  Copyright © 2017年 Lion_Lemon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FinishEditedBlock)(NSString * CompleteStr);

@interface SCEditBlurController : UIViewController

@property (nonatomic, strong) UIImage * bgImage;

@property (nonatomic, assign) BOOL isEditEnabled;

@property (nonatomic, copy) NSString * exitText;

@property (nonatomic, copy) FinishEditedBlock completeBlock;


@end
