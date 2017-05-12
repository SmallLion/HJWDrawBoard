//
//  HJWRecordView.h
//  NIM
//
//  Created by Lion_Lemon on 16/3/15.
//  Copyright © 2016年 Lemon_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define HUD_SIZE [UIScreen mainScreen].bounds.size.width

@class HJWRecordView;
@protocol HJWRecordViewDelegate  <NSObject>

- (void)recordArcView:(HJWRecordView *)arcView voiceRecorded:(NSString *)recordPath length:(float)recordLength;
- (void)recordArcView:(HJWRecordView *)arcView onclickButton:(UIButton *)button;
@end

@interface HJWRecordView : UIView <AVAudioRecorderDelegate>
@property (nonatomic, strong) AVAudioRecorder *recorder;

@property (nonatomic, strong) UIColor * waveColor;

@property (nonatomic, strong) UIButton *recordButton;

@property (nonatomic, assign) CGFloat recordCurrentTime;

@property (nonatomic, assign) CGFloat MaxRecordTime;

@property (nonatomic, copy) NSString *recordPath;

@property(weak, nonatomic) id<HJWRecordViewDelegate> delegate;

- (void)startForFilePath:(NSString *)filePath;
- (void)startRecording;
- (void)commitRecording;
- (void)pauseRecording;
- (void)continueRecording;
- (void)stopRecording;
@end
