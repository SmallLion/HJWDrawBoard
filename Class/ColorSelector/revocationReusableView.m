//
//  revocationReusableView.m
//  HJWDrawBoard
//
//  Created by Lemon_Mr.H on 2017/3/13.
//  Copyright © 2017年 Lemon_Mr.H. All rights reserved.
//

#import "revocationReusableView.h"

@implementation revocationReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)clearBtnAction:(id)sender {
    if (self.clearBtnClick) {
        self.clearBtnClick();
    }
}
@end
