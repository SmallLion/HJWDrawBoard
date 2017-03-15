//
//  HJWTextTagData.m
//  HJWDrawBoard
//
//  Created by Lemon_Mr.H on 2017/3/10.
//  Copyright © 2017年 Lemon_Mr.H. All rights reserved.
//

#import "HJWTagData.h"

@implementation HJWTagData

HJWPositionProportion HJWPositionProportionMake(CGFloat x, CGFloat y)
{
    HJWPositionProportion p; p.x = x; p.y = y; return p;
}

+ (instancetype)tagInfo
{
    return [[self alloc] init];
}

@end
