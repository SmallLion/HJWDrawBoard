//
//  SCAudioRecordView.h
//  StudyChat
//
//  Created by Lion_Lemon on 16/7/21.
//  Copyright © 2016年 Lion_Lemon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCAudioRecordView;
@protocol SCAudioRecordViewDelegate <NSObject>

- (void)SCAudioRecordView:(SCAudioRecordView *)recordView didFinishedRecordWithPath:(NSString *)path length:(CGFloat)length;

@end

@interface SCAudioRecordView : UIView
@property (nonatomic, weak) id <SCAudioRecordViewDelegate> delegate;

- (id)initWithTitles:(NSArray *)titles;
- (id)initWithTitles:(NSArray *)titles withButtonHeight:(CGFloat)height withMenuColor:(UIColor *)menuColor withBackBlurStyle:(UIBlurEffectStyle)style;
- (void)trigger;
@end
