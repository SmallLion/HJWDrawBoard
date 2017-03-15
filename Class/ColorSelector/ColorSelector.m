//
//  ColorSelector.m
//  HJWDrawBoard
//
//  Created by Lemon_Mr.H on 2017/3/13.
//  Copyright © 2017年 Lemon_Mr.H. All rights reserved.
//

#import "ColorSelector.h"
#import "UIView+HJW.h"
#import "ColorSelectorCell.h"
#import "revocationReusableView.h"

const CGFloat colorSelectorH = 60;

const CGFloat superViewH = 49;

@interface ColorSelector ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView * collectionView;

@property (nonatomic, strong) NSMutableArray * dataArray, * colorArr;

@property (nonatomic, assign, getter = isShow) BOOL show;

@end

@implementation ColorSelector

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

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    [self handleObject];
    [self createCollectionView];
    
    [self reSelectored];
}

- (void)reSelectored {
    self.dataArray = @[].mutableCopy;
    for (NSInteger i = 0; i < 5; i++) {
        [self.dataArray addObject:@(NO)];
    }
}

- (void)handleObject {
    self.colorArr = @[
                      [UIColor redColor],
                      [UIColor purpleColor],
                      [UIColor greenColor],
                      [UIColor cyanColor],
                      [UIColor yellowColor],].mutableCopy;
}

#pragma mark - Creater
- (void)createCollectionView {
    UICollectionViewLayout *layout = [self hjw_CollectionViewLayout];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                         collectionViewLayout:layout];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.75f];
    _collectionView.frame = [self collectionViewFrame];
    [self addSubview:_collectionView];
    [self registCell];
}

- (UICollectionViewFlowLayout *)hjw_CollectionViewLayout {
    // 默认CollectionViewLayout
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [collectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [collectionViewFlowLayout setMinimumInteritemSpacing:0];
    [collectionViewFlowLayout setMinimumLineSpacing:0];
    
    collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    collectionViewFlowLayout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width / 6, colorSelectorH);
    collectionViewFlowLayout.footerReferenceSize = collectionViewFlowLayout.itemSize;
    return collectionViewFlowLayout;
}

- (CGRect)collectionViewFrame {
    return CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, colorSelectorH);
}

- (void)registCell {
    [_collectionView registerClass:[UICollectionViewCell class]
        forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([ColorSelectorCell class]) bundle:[NSBundle mainBundle]]
      forCellWithReuseIdentifier:NSStringFromClass([ColorSelectorCell class])];
    
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([revocationReusableView class]) bundle:[NSBundle mainBundle]]
      forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
             withReuseIdentifier:NSStringFromClass([revocationReusableView class])];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.colorArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ColorSelectorCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ColorSelectorCell class]) forIndexPath:indexPath];
    cell.selected = [self.dataArray[indexPath.row] boolValue];
    cell.circleColor = self.colorArr[indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    
    cell.clickBlock = ^(ColorSelectorCell * item) {
        BOOL isSelected = [weakSelf.dataArray[indexPath.row] boolValue];
        [weakSelf reSelectored];
        [weakSelf.dataArray replaceObjectAtIndex:indexPath.row withObject:@(!isSelected)];
        [weakSelf.collectionView reloadData];
        
        if (_delegate && [_delegate respondsToSelector:@selector(ColorSelector:didSelectedColor:)]) {
            [_delegate ColorSelector:weakSelf didSelectedColor:weakSelf.colorArr[indexPath.row]];
        }
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cell:%@", [collectionView cellForItemAtIndexPath:indexPath]);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    revocationReusableView * view =
    [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                       withReuseIdentifier:NSStringFromClass([revocationReusableView class])
                                              forIndexPath:indexPath];
    
    view.clearBtnClick = ^(){
        if (_delegate && [_delegate respondsToSelector:@selector(ColorSelectorDidClickClear:)]) {
            [_delegate ColorSelectorDidClickClear:self];
        }
    };
    return view;
}

#pragma mark - public Method
- (void)defaultSelectFirstColor {
    [self reSelectored];
    [self.dataArray replaceObjectAtIndex:0 withObject:@(YES)];
    [self.collectionView reloadData];
}

- (void)showAnimation {
    if(self.isShow && self.isHidden == NO) {
        return;
    }
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.9f initialSpringVelocity:0.7f
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         self.hidden = NO;
                         self.y = [UIScreen mainScreen].bounds.size.height - colorSelectorH - superViewH;
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
