//
//  HJWTagImageView.m
//  HJWDrawBoard
//
//  Created by Lemon_Mr.H on 2017/3/10.
//  Copyright © 2017年 Lemon_Mr.H. All rights reserved.
//

#import "HJWTagImageView.h"
#import "ColorSelector.h"
#import "CustomToolBar.h"
#import "HJWDrawingBoard.h"
#import "OpenGLDrawView.h"

@interface HJWTagImageView ()<HJWTagViewDelegate, CustomToolBarDelegate, ColorSelectorDelegate>
@property (nonatomic, strong) CustomToolBar * toolBar;

@property (nonatomic, strong) ColorSelector * colorSelector;

@property (nonatomic, strong) HJWDrawingBoard * drawingBoard;

@property (nonatomic, strong) OpenGLDrawView *openGlDrawView;

@property (nonatomic, assign) BOOL isFirstActionDrawing;


@end

@implementation HJWTagImageView

#pragma mark - Lazy initing
- (CustomToolBar *)toolBar {
    if (!_toolBar) {
        _toolBar = [[CustomToolBar alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 49)];
        _toolBar.ToolBarDelegate = self;
        _toolBar.ItemImages = @[@"icon_pan",
                                @"icon_voice",
                                @"icon_text"];
        _toolBar.backgroundColor = [UIColor clearColor];
        _toolBar.barStyle = UIBarStyleBlack;
        _toolBar.translucent = false;
        _toolBar.hidden = YES;
    }
    return _toolBar;
}

- (ColorSelector *)colorSelector {
    if (!_colorSelector) {
        CGFloat ScreenW = [UIScreen mainScreen].bounds.size.width;
        _colorSelector = [[ColorSelector alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 49 - 60, ScreenW, 60)];
        _colorSelector.hidden = YES;
        _colorSelector.delegate = self;
    }
    return _colorSelector;
}

- (HJWDrawingBoard *)drawingBoard {
    if (!_drawingBoard) {
        _drawingBoard = [[HJWDrawingBoard alloc] initWithFrame:self.frame];
        _drawingBoard.lineColor = [UIColor redColor];
        _drawingBoard.backgroundColor = [UIColor clearColor];
        _drawingBoard.drawing = NO;
    }
    return _drawingBoard;
}

- (OpenGLDrawView *)openGlDrawView {
    if (!_openGlDrawView) {
        _openGlDrawView = [[OpenGLDrawView alloc] initWithFrame:self.frame];
        _openGlDrawView.lineColor = [UIColor redColor];
        _openGlDrawView.backgroundColor = [UIColor clearColor];
        _openGlDrawView.drawing = NO;
    }
    return _openGlDrawView;
}

#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    [self addSubview:self.openGlDrawView];
    [self addSubview:self.drawingBoard];
    [self addSubview:self.colorSelector];
    [self addSubview:self.toolBar];
    
    self.isFirstActionDrawing = YES;
    self.isEditEnable = YES;
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tap];
}

- (void)setIsEditEnable:(BOOL)isEditEnable {
    _isEditEnable = isEditEnable;
    if (isEditEnable) {
        [self.toolBar showAnimation];
    }else {
        [self.toolBar closeAnimation];
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tap
{
    // 如果是预览模式、退出
    if (self.isEditEnable == NO) {
        return;
    }
    
    if ([tap.view isKindOfClass:[self class]]) {
        if (self.toolBar.isHidden) {
            [self.toolBar showAnimation];
        }else {
            [self.toolBar closeAnimation];
        }
        // 是否显示取色器
        if (self.drawingBoard.drawing) {
            if (self.colorSelector.isHidden) {
                [self.colorSelector showAnimation];
            }else {
                [self.colorSelector closeAnimation];
            }
        }else {
            [self.colorSelector closeAnimation];
        }
    }
}

#pragma mark - public methods
- (void)addTagsWithTagInfoArray:(NSArray *)tagInfoArray
{
    for (HJWTagData *tagInfo in tagInfoArray) {
        HJWTagView *tagView = [[HJWTagView alloc] initWithTagInfo:tagInfo];
        tagView.delegate = self;
        tagView.isEditEnabled = self.isEditEnable;
        [self addSubview:tagView];
        [tagView showAnimationWithRepeatCount:CGFLOAT_MAX];
    }
}

- (void)addTagWithTitle:(NSString *)title point:(CGPoint)point object:(id)object
{
    HJWTagData *tagInfo = [HJWTagData tagInfo];
    tagInfo.point = point;
    tagInfo.title = title;
    tagInfo.object = object;
    
    HJWTagView *tagView = [[HJWTagView alloc] initWithTagInfo:tagInfo];
    tagView.delegate = self;
    tagView.isEditEnabled = self.isEditEnable;
    [self addSubview:tagView];
    [tagView showAnimationWithRepeatCount:CGFLOAT_MAX];
}

- (void)setAllTagsEditEnable:(BOOL)isEditEnabled
{
    self.isEditEnable = isEditEnabled;
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[HJWTagView class]]) {
            ((HJWTagView *)view).isEditEnabled = isEditEnabled;
            if (isEditEnabled == NO) {
                [(HJWTagView *)view hiddenDeleteBtn];
            }
        }
    }
}

- (void)hiddenAllTagsDeleteBtn
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[HJWTagView class]]) {
            [(HJWTagView *)view hiddenDeleteBtn];
        }
    }
}

- (void)removeAllTags
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[HJWTagView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (NSArray *)getAllTagInfos
{
    NSMutableArray *array = [NSMutableArray array];
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[HJWTagView class]]) {
            [array addObject:((HJWTagView *)view).tagInfo];
        }
    }
    return array;
}

- (void)changeDrawingBoard {
    if (self.isOpenGL) {
        self.openGlDrawView.hidden = NO;
        self.drawingBoard.hidden = YES;
    }else {
        self.openGlDrawView.hidden = YES;
        self.drawingBoard.hidden = NO;
    }
}

#pragma mark - HJWTagViewDelegate
- (void)tagViewActiveTapGesture:(HJWTagView *)tagView
{
    if ([self.delegate respondsToSelector:@selector(tagImageView:tagViewActiveTapGesture:)]) {
        [self.delegate tagImageView:self tagViewActiveTapGesture:tagView];
    }else{
        // 默认
        [tagView switchDeleteState];
    }
}

- (void)tagViewActiveLongPressGesture:(HJWTagView *)tagView
{
    if ([self.delegate respondsToSelector:@selector(tagImageView:tagViewActiveLongPressGesture:)]) {
        [self.delegate tagImageView:self tagViewActiveLongPressGesture:tagView];
    }
}

- (void)tagViewActivePanGesture:(HJWTagView *)tagView {
    if ([self.delegate respondsToSelector:@selector(tagImageView:tagViewActivePanGesture:)]) {
        [self.delegate tagImageView:self tagViewActivePanGesture:tagView];
    }
}

#pragma mark - CustomToolBar
- (void)toolBar:(CustomToolBar *)tool didClickBtn:(UIButton *)btn atIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            // 如果是预览模式、退出
            if (self.isEditEnable == NO) {
                return;
            }
            // 第一次选中
            if (self.isFirstActionDrawing) {
                [btn setImage:[UIImage imageNamed:@"icon_pan_selected"]
                     forState:UIControlStateSelected];

                [self.colorSelector defaultSelectFirstColor];
                self.isFirstActionDrawing = NO;
            }
            // 设置按钮选中状态
            btn.selected = !btn.isSelected;
            // 是否激活画板
            if (btn.selected) {
                [self actionDrawingStatus];
                [self.colorSelector showAnimation];
            }else {
                [self exitDrawingStatus];
                [self.colorSelector closeAnimation];
            }
        }
            break;
        case 1:
        {
            // 退出画板
            [self exitDrawingStatus];
            [self.colorSelector closeAnimation];
            // 隐藏工具栏、重置按钮状态
            [tool closeAnimation];
            [tool reSetAllBtnSelectStatus];
            
            if (self.isEditEnable == NO) {
                return;
            }
            if ([self.delegate respondsToSelector:@selector(tagImageView:didClickVoiceGesture:)]) {
                [self.delegate tagImageView:self didClickVoiceGesture:nil];
            }
        }
            break;
        case 2:
        {
            // 退出画板
            [self exitDrawingStatus];
            [self.colorSelector closeAnimation];
            // 隐藏工具栏、重置按钮状态
            [tool closeAnimation];
            [tool reSetAllBtnSelectStatus];

            if (self.isEditEnable == NO) {
                return;
            }
            if ([self.delegate respondsToSelector:@selector(tagImageView:didClickTextGesture:)]) {
                [self.delegate tagImageView:self didClickTextGesture:nil];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - ColorSelectorDelegate
- (void)ColorSelector:(ColorSelector *)ColorSelector didSelectedColor:(UIColor *)color {
    self.drawingBoard.lineColor = color;
    self.openGlDrawView.lineColor = color;
}

- (void)ColorSelectorDidClickClear:(ColorSelector *)ColorSelector {
    [self.drawingBoard clear];
    [self.openGlDrawView clear];
}

- (void)hiddenAllTools {
    [self.colorSelector closeAnimation];
    [self.toolBar closeAnimation];
    
    [self exitDrawingStatus];
}

- (void)actionDrawingStatus {
    self.drawingBoard.drawing = YES;
    self.openGlDrawView.drawing = YES;
}

- (void)exitDrawingStatus {
    self.drawingBoard.drawing = NO;
    self.openGlDrawView.drawing = NO;
}
@end
