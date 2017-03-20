//
//  HJWRecordView.h
//  NIM
//
//  Created by Lion_Lemon on 16/3/15.
//  Copyright © 2016年 Lemon_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define MAX_RECORD_DURATION 60.0
#define WAVE_UPDATE_FREQUENCY   0.1
#define SILENCE_VOLUME   45.0
#define SOUND_METER_COUNT  6
#define HUD_SIZE [UIScreen mainScreen].bounds.size.width
#define BASEHEIGHT CGRectGetHeight(self.frame) / 2

typedef NS_ENUM(NSInteger, BUTTONATINDEX){
    BUTTONATPLAY,
    BUTTONATPAUSE,
    BUTTONATRECORD,
    BUTTONATCONTINUE,
    BUTTONATSTOP
};

@class HJWRecordView;
@protocol HJWRecordViewDelegate  <NSObject>

- (void)recordArcView:(HJWRecordView *)arcView voiceRecorded:(NSString *)recordPath length:(float)recordLength;
- (void)recordArcView:(HJWRecordView *)arcView onclickButton:(UIButton *)button;
- (void)recordArcView:(HJWRecordView *)arcView restRecordButton:(UIButton *)button;
@end

@interface HJWRecordView : UIView<AVAudioRecorderDelegate>
@property(readwrite, nonatomic, strong) AVAudioRecorder *recorder;
@property(readwrite, nonatomic, strong) UIButton * recordButton;
@property(readwrite, nonatomic, strong) UIButton * delButton;
@property(readwrite, nonatomic, strong) UILabel *timeLabel;

@property(weak, nonatomic) id<HJWRecordViewDelegate> delegate;
- (void)startForFilePath:(NSString *)filePath;
- (void)commitRecording;
- (void)pauseRecording;
- (void)continueRecording;
- (void)stopRecording;
@end
