//
//  HJWRecordView.m
//  NIM
//
//  Created by Lion_Lemon on 16/3/15.
//  Copyright © 2016年 Lemon_Lion. All rights reserved.
//

#import "HJWRecordView.h"
#import "SCSiriWaveformView.h"

#warning next step pause / play game 

#define hjw_StrIsEmpty(str) ([str isKindOfClass:[NSNull class]] || [str length] < 1 ? YES : NO || [str isEqualToString:@"(null)"] || [str isEqualToString:@"null"])

@implementation NSString (timeStringForTimeInterval)

+ (NSString*)timeStringForTimeInterval:(NSTimeInterval)timeInterval
{
    NSInteger ti = (NSInteger)timeInterval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    
    if (hours > 0)
    {
        return [NSString stringWithFormat:@"%02li:%02li:%02li", (long)hours, (long)minutes, (long)seconds];
    }
    else
    {
        return  [NSString stringWithFormat:@"%02li:%02li", (long)minutes, (long)seconds];
    }
}

@end


@interface HJWRecordView ()

@property (readwrite, nonatomic, strong) NSDictionary *recordSettings;

@property(readwrite, nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) NSArray * imageNames;

@property (nonatomic, strong) SCSiriWaveformView *waveformView;

@property (nonatomic, copy) NSString * kRecordAudioFile;

@end

@implementation HJWRecordView
- (void)dealloc{
    self.recorder.delegate = nil;
}

- (SCSiriWaveformView *)waveformView {
    if (!_waveformView) {
        _waveformView = ({
            SCSiriWaveformView * musicFlowView = [[SCSiriWaveformView alloc] initWithFrame:CGRectMake(0, 0, HUD_SIZE, 120)];
            musicFlowView.translatesAutoresizingMaskIntoConstraints = NO;
            musicFlowView.backgroundColor = [UIColor clearColor];
            musicFlowView.waveColor = self.waveColor;
            musicFlowView;
        });
    }
    return _waveformView;
}

- (NSArray *)imageNames {
    if (!_imageNames) {
        _imageNames = @[@"audio-btn-play", @"audio-btn-pause", @"audio-btn-record", @"audio-btn-continue", @"audio-btn-stop"];
    }
    return _imageNames;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        [self setupSettings];
        [self customUI];
    }
    return self;
}

- (void)setupSettings {
    self.recordSettings = @{AVFormatIDKey : @(kAudioFormatAppleLossless),
                            AVEncoderAudioQualityKey : @(AVAudioQualityMedium),
                            AVSampleRateKey : @(44100.0),
                            AVNumberOfChannelsKey : @(2)};
    self.recordPath = [self fullPathAtCache:self.kRecordAudioFile];
    self.MaxRecordTime = 60;
    self.waveColor = [UIColor cyanColor];
}

- (void)customUI {
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -40, HUD_SIZE, 40)];
    self.timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:30];
    [self.timeLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.timeLabel];
    
    CGFloat buttonW = 60;
    self.recordButton =
    [[UIButton alloc] initWithFrame:CGRectMake((HUD_SIZE - buttonW) / 2, 60 - buttonW / 2, buttonW, buttonW)];
    [self.recordButton setImage:[UIImage imageNamed:@"audio-btn-record"] forState:UIControlStateNormal];
    [self.recordButton addTarget:self action:@selector(buttonOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.recordButton];
    
    self.waveformView.center = self.recordButton.center;
    [self addSubview:self.waveformView];
    [self sendSubviewToBack:self.waveformView];
    
    CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:self
                                                             selector:@selector(updateMeters)];
    [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark - Btns Action
- (void)buttonOnclick:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordArcView:onclickButton:)]) {
        [self.delegate recordArcView:self onclickButton:button];
    }
}

- (void)startForFilePath:(NSString *)filePath {
    NSLog(@"file path:%@",filePath);
    self.recordPath = filePath;
    [self startRecording];
}

- (void)startRecording {
    if (self.recorder.isRecording) {
        return;
    }
    
    self.recordCurrentTime = 0.0; // 初始化
    [self configRecorder];
    
    [self.recorder prepareToRecord];
    [self.recorder setMeteringEnabled:YES];
    [self.recorder record];
}

- (void)configRecorder {
    NSError *error;
    NSURL * url = [NSURL fileURLWithPath:self.recordPath];
    NSData * existedData = (NSData *)[NSData dataWithContentsOfFile:[url path]
                                                            options:NSDataReadingMapped
                                                              error:&error];
    if (existedData) {
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:[url path] error:&error];
    }
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:self.recordSettings error:&error];
    [self.recorder recordForDuration:self.MaxRecordTime];
    [self.recorder setDelegate:self];
    
    if(error) {
        NSLog(@"Ups, could not create recorder %@", [error description]);
        return;
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    if (error) {
        NSLog(@"Error setting category: %@", [error description]);
        return;
    }
}

- (void)stopRecording {
    [self.recorder stop];
}

- (void)commitRecording{
    [self.recorder stop];
}

- (void)pauseRecording {
    if (self.recorder.isRecording) {
        [self.recorder pause];
    }
}

- (void)continueRecording {
    if (!self.recorder.isRecording) {
        [self.recorder record];
    }
}

- (void)updateMeters
{
    CGFloat normalizedValue;
    [self.recorder updateMeters];
    normalizedValue = [self _normalizedPowerLevelFromDecibels:[self.recorder averagePowerForChannel:0]];
    [self.waveformView updateWithLevel:normalizedValue];
    
    if (self.recorder.isRecording) {
        self.recordCurrentTime = self.recorder.currentTime;
        self.timeLabel.text = [NSString stringWithFormat:@"%.0fs", self.recordCurrentTime];
    }
}


- (CGFloat)_normalizedPowerLevelFromDecibels:(CGFloat)decibels
{
    if (decibels < -60.0f || decibels == 0.0f) {
        return 0.0f;
    }
    
    return powf((powf(10.0f, 0.05f * decibels) - powf(10.0f, 0.05f * -60.0f)) * (1.0f / (1.0f - powf(10.0f, 0.05f * -60.0f))), 1.0f / 2.0f);
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    NSLog(@"error : %@",error);
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    if (flag)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.recordPath]) {
            [self calculatTimeCount];
            self.timeLabel.text = [NSString stringWithFormat:@"%.0lfs", self.recordCurrentTime];

            if (_delegate && [_delegate respondsToSelector:@selector(recordArcView:voiceRecorded:length:)]) {
                [_delegate recordArcView:self voiceRecorded:self.recordPath length:self.recordCurrentTime];
            }
        }
    }else {
        [[NSFileManager defaultManager] removeItemAtPath:self.recordPath error:nil];
    }
}

- (void)calculatTimeCount {
    NSURL *audioFileURL = [NSURL fileURLWithPath:self.recordPath];
    
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:audioFileURL options:nil];
    CMTime audioDuration = audioAsset.duration;
    
    NSString * timeCount = [NSString timeStringForTimeInterval:CMTimeGetSeconds(audioDuration)];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:ss"];
    NSDate *curDate = [formatter dateFromString:timeCount];
    
    self.recordCurrentTime = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:curDate].second;
}

#pragma mark - Path
- (NSString *)kRecordAudioFile {
    return [NSString stringWithFormat:@"%@.m4a", [self getCurrentTime]];
}

- (NSString *)getCurrentTime {
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    return [formatter stringFromDate:[NSDate date]];
}

- (NSString *)fullPathAtCache:(NSString *)fileName {
    NSError *error;
    NSString *path = NSTemporaryDirectory();
    NSFileManager *fm = [NSFileManager defaultManager];
    if (YES != [fm fileExistsAtPath:path]) {
        if (YES != [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"create dir path=%@, error=%@", path, error);
        }
    }
    return [path stringByAppendingPathComponent:fileName];
}
@end
