//
//  HJWActionSheet.h
//  zhuoyan
//
//  Created by Lion_Lemon on 16/9/14.
//  Copyright © 2016年 Lion_Lemon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HJWActionSheet;

@protocol HJWActionSheetDelegate <NSObject>

@required
/**
 *  delegate's method
 *
 *  @param actionSheet     index: top is 0 and 0++ to down but cancelBtn's index is -1
 */
- (void)actionSheet:(HJWActionSheet *)actionSheet didSelectSheet:(NSInteger)index;

@end

/**
 *  block's call
 *
 *  @param index           the same to the delegate
 */
typedef void (^ActionSheetDidSelectSheetBlock)(HJWActionSheet *actionSheetView, NSInteger index);

@interface HJWActionSheet : UIView

@property (nonatomic, weak) id<HJWActionSheetDelegate> delegate;

@property (nonatomic, copy) ActionSheetDidSelectSheetBlock selectSheetBlock;

#pragma mark - Block's way

+ (void)hjw_showActionSheetViewWithTitle:(NSString *)title
                      cancelButtonTitle:(NSString *)cancelButtonTitle
                 destructiveButtonTitle:(NSString *)destructiveButtonTitle
                      otherButtonTitles:(NSArray  *)otherButtonTitles
                       selectSheetBlock:(ActionSheetDidSelectSheetBlock)selectSheetBlock;

- (instancetype)initWithTitle:(NSString *)title
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
            otherButtonTitles:(NSArray  *)otherButtonTitles
             selectSheetBlock:(ActionSheetDidSelectSheetBlock)selectSheetBlock;

#pragma mark - Delegate's way

+ (void)hjw_showActionSheetViewWithTitle:(NSString *)title
                      cancelButtonTitle:(NSString *)cancelButtonTitle
                 destructiveButtonTitle:(NSString *)destructiveButtonTitle
                      otherButtonTitles:(NSArray  *)otherButtonTitles
                               delegate:(id<HJWActionSheetDelegate>)delegate;

- (instancetype)initWithTitle:(NSString *)title
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
            otherButtonTitles:(NSArray  *)otherButtonTitles
                     delegate:(id<HJWActionSheetDelegate>)delegate;

@end
