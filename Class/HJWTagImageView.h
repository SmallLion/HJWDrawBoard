//
//  HJWTagImageView.h
//  HJWDrawBoard
//
//  Created by Lemon_Mr.H on 2017/3/10.
//  Copyright © 2017年 Lemon_Mr.H. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HJWTagView.h"

@class HJWTagImageView;

@protocol HJWTagImageViewDelegate <NSObject>

/** 轻触imageView空白区域 */
- (void)tagImageView:(HJWTagImageView *)tagImageView activeTapGesture:(UITapGestureRecognizer *)tapGesture;

- (void)tagImageView:(HJWTagImageView *)tagImageView didClickVoiceGesture:(UITapGestureRecognizer *)tapGesture;
- (void)tagImageView:(HJWTagImageView *)tagImageView didClickTextGesture:(UITapGestureRecognizer *)tapGesture;
- (void)tagImageView:(HJWTagImageView *)tagImageView didClickPanGesture:(UITapGestureRecognizer *)tapGesture;

@optional
/** 轻触标签 */
- (void)tagImageView:(HJWTagImageView *)tagImageView tagViewActiveTapGesture:(HJWTagView *)tagView;
/** 长按标签 */
- (void)tagImageView:(HJWTagImageView *)tagImageView tagViewActiveLongPressGesture:(HJWTagView *)tagView;
/** 拖动标签 */
- (void)tagImageView:(HJWTagImageView *)tagImageView tagViewActivePanGesture:(HJWTagView *)tagView;

@end

@interface HJWTagImageView : UIImageView

@property (nonatomic, weak) id<HJWTagImageViewDelegate> delegate;
@property (nonatomic, assign) BOOL isEditEnable;
@property (nonatomic, assign) BOOL isOpenGL;

/** 添加标签 */
- (void)addTagsWithTagInfoArray:(NSArray *)tagInfoArray;
/** 添加单个标签 */
- (void)addTagWithTitle:(NSString *)title point:(CGPoint)point object:(id)object;
/** 设置标签是否可编辑 */
- (void)setAllTagsEditEnable:(BOOL)isEditEnabled;
/** 隐藏所有标签的删除按钮 */
- (void)hiddenAllTagsDeleteBtn;
/** 移除所有标签 */
- (void)removeAllTags;
/** 获取当前所有标签信息 */
- (NSArray *)getAllTagInfos;
/** 隐藏工具栏 */
- (void)hiddenAllTools;
/** 切换基础画板 */
- (void)changeDrawingBoard;
@end
