//
//  HJWTextTagView.h
//  HJWDrawBoard
//
//  Created by Lemon_Mr.H on 2017/3/10.
//  Copyright © 2017年 Lemon_Mr.H. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJWTagData.h"

@class HJWTagView;

@protocol HJWTagViewDelegate <NSObject>

@optional
/** 触发轻触手势 */
- (void)tagViewActiveTapGesture:(HJWTagView *)tagView;
/** 触发长按手势 */
- (void)tagViewActiveLongPressGesture:(HJWTagView *)tagView;
/** 触发长按手势 */
- (void)tagViewActivePanGesture:(HJWTagView *)tagView;
@end

@interface HJWTagView : UIView

/** 代理 */
@property (nonatomic, weak) id<HJWTagViewDelegate> delegate;
/** 标记信息 */
@property (nonatomic, strong, readonly) HJWTagData *tagInfo;
/** 是否可编辑 default is YES */
@property (nonatomic, assign) BOOL isEditEnabled;

/** 初始化 */
- (instancetype)initWithTagInfo:(HJWTagData *)tagInfo;
/** 更新标题 */
- (void)updateTitle:(NSString *)title;
/** 显示动画 */
- (void)showAnimationWithRepeatCount:(float)repeatCount;
/** 移除动画 */
- (void)removeAnimation;
/** 显示删除按钮 */
- (void)showDeleteBtn;
/** 隐藏删除按钮 */
- (void)hiddenDeleteBtn;
/** 切换删除按钮状态 */
- (void)switchDeleteState;

@end
