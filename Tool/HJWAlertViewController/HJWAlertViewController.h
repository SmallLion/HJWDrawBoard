//
//  HJWAlertViewController.h
//  StudyChat
//
//  Created by Lion_Lemon on 2016/9/26.
//  Copyright © 2016年 Lion_Lemon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HJWAlertAction : NSObject

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(HJWAlertAction *action))handler;

@property (nonatomic, readonly) NSString *title;

@end

@interface HJWAlertViewController : UIViewController

@property (nonatomic, readonly) NSArray<HJWAlertAction *> *actions;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) NSTextAlignment messageAlignment;


/**
 *  eg: for Using
 *
 *  
    HJWAlertViewController *alertVC = [HJWAlertViewController alertControllerWithTitle:@"Access Microphone?" message:@"Are you sure that you want to allow this app to access your microphone?" ];
 
                     HJWAlertAction *cancel = [HJWAlertAction actionWithTitle:@"取消" handler:^(HJWAlertAction *action) {
                         HJWLog(@"点击了 %@ 按钮",action.title);
                     }];
 
                     HJWAlertAction *sure = [HJWAlertAction actionWithTitle:@"确定" handler:^(HJWAlertAction *action) {
                         HJWLog(@"点击了 %@ 按钮",action.title);
                     }];
 
                     [alertVC addAction:cancel];
                     [alertVC addAction:sure];
 
                     [self presentViewController:alertVC animated:NO completion:nil];
 
 */

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message;
- (void)addAction:(HJWAlertAction *)action;

@end

