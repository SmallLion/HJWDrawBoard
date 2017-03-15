//
//  HJWTextTagData.h
//  HJWDrawBoard
//
//  Created by Lemon_Mr.H on 2017/3/10.
//  Copyright © 2017年 Lemon_Mr.H. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HJWTagDirection){
    HJWTagDirectionNormal,
    HJWTagDirectionLeft,
    HJWTagDirectionRight,
};

/** 比例 */
struct HJWPositionProportion {
    CGFloat x;
    CGFloat y;
};

typedef struct HJWPositionProportion HJWPositionProportion;

HJWPositionProportion HJWPositionProportionMake(CGFloat x, CGFloat y);

@interface HJWTagData : NSObject
/** 记录位置点 */
@property (nonatomic, assign) CGPoint point;
/** 记录位置点在父视图中的比例 */
@property (nonatomic, assign) HJWPositionProportion proportion;
/** 方向 */
@property (nonatomic, assign) HJWTagDirection direction;
/** 标题 */
@property (nonatomic, copy) NSString *title;
/** 其他需要存储的数据 */
@property (nonatomic, strong) id object;

/** 初始化 */
+ (HJWTagData *)tagInfo;
@end
