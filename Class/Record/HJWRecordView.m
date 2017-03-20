//
//  HJWRecordView.m
//  NIM
//
//  Created by Lion_Lemon on 16/3/15.
//  Copyright © 2016年 Lemon_Lion. All rights reserved.
//

#import "HJWRecordView.h"

@interface HJWRecordView ()
{
    int soundMeters[SOUND_METER_COUNT];
}

@property(readwrite, nonatomic, strong) NSDictionary *recordSettings;
@property(readwrite, nonatomic, strong) NSTimer *timer;
//@property(readwrite, nonatomic, strong) UILabel *timeLabel;
@property(readwrite, nonatomic, copy) NSString *recordPath;
@property(readwrite, nonatomic, assign) CGFloat recordTime;
@property(readwrite, nonatomic, assign) CGRect hudRect;
@property (nonatomic, strong) NSArray * imageNames;

@end

@implementation HJWRecordView
- (void)dealloc{
    [self.timer invalidate];
    self.timer = nil;
    self.recorder.delegate = nil;
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
        self.recordSettings = @{AVFormatIDKey : @(kAudioFormatLinearPCM),
                                AVEncoderBitRateKey:@(16),
                                AVEncoderAudioQualityKey : @(AVAudioQualityMax),
                                AVSampleRateKey : @(8000.0),
                                AVNumberOfChannelsKey : @(2)};
        for(int i = 0; i < SOUND_METER_COUNT; i++) {
            soundMeters[i] = SILENCE_VOLUME;
        }
        
        self.backgroundColor = [UIColor clearColor];
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -40, HUD_SIZE, 40)];
        self.timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:30];
        self.timeLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:.75f];
        [self.timeLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.timeLabel];
        
        CGFloat buttonW = 60;
        self.recordButton =
        [[UIButton alloc] initWithFrame:CGRectMake((HUD_SIZE - buttonW) / 2, 60 - buttonW / 2, buttonW, buttonW)];
        [self.recordButton setImage:[UIImage imageNamed:@"audio-btn-record"] forState:UIControlStateNormal];
        [self.recordButton addTarget:self action:@selector(buttonOnclick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.recordButton];

        self.delButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.recordButton.frame) + 10, [UIScreen mainScreen].bounds.size.width, 20)];
        self.delButton.enabled = NO;
        self.delButton.titleLabel.font = [UIFont systemFontOfSize:12.f];
        [self.delButton setTitle:@"点击删除  重新录制" forState:UIControlStateNormal];
        [self.delButton setTitleColor:[UIColor redColor]
                             forState:UIControlStateNormal];
        [self.delButton addTarget:self
                           action:@selector(rest:)
                 forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.delButton];
        
        self.hudRect = CGRectMake(self.center.x - (HUD_SIZE / 2), self.center.y - (HUD_SIZE / 2), HUD_SIZE, HUD_SIZE);
    }
    return self;
}

- (void)rest:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordArcView:restRecordButton:)]) {
        [self.delegate recordArcView:self restRecordButton:button];
    }
}

- (void)buttonOnclick:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordArcView:onclickButton:)]) {
        [self.delegate recordArcView:self onclickButton:button];
    }
}

- (void)startForFilePath:(NSString *)filePath{
    NSLog(@"file path:%@",filePath);
    if (self.recorder.isRecording) {
        return;
    }
    self.delButton.enabled = NO;
    self.recordTime = 0.0;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    self.recordPath = filePath;
    NSURL * url = [NSURL fileURLWithPath:filePath];
    NSData * existedData = (NSData *)[NSData dataWithContentsOfFile:[url path] options:NSDataReadingMapped error:&err];
    if (existedData) {
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:[url path] error:&err];
    }
    
    self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:self.recordSettings error:&err];
    [self.recorder setDelegate:self];
    [self.recorder prepareToRecord];
    [self.recorder setMeteringEnabled:YES];
    
    [self.recorder recordForDuration:MAX_RECORD_DURATION];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:WAVE_UPDATE_FREQUENCY target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
}

- (void)stopRecording {
    [self.recorder stop];
}

- (void)commitRecording{
    [self.recorder stop];
    self.delButton.enabled = YES;
}

- (void)pauseRecording {
    if (self.recorder.isRecording) {
        [self.recorder pause];
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}

- (void)continueRecording {
    if (!self.recorder.isRecording) {
        [self.recorder record];
        [self.timer setFireDate:[NSDate distantPast]];
    }
}

- (void)updateMeters{
    [self.recorder updateMeters];
    if (self.recordTime > 60.0) {
        return;
    }
    self.recordTime += WAVE_UPDATE_FREQUENCY;
    [self.timeLabel setText:[NSString stringWithFormat:@"%.0fs",self.recordTime]];
    if ([self.recorder averagePowerForChannel:0] < -SILENCE_VOLUME) {
        [self addSoundMeterItem:SILENCE_VOLUME];
        return;
    }
    [self addSoundMeterItem:[self.recorder averagePowerForChannel:0]];
    NSLog(@"volume:%f",[self.recorder averagePowerForChannel:0]);
}

- (void)addSoundMeterItem:(int)lastValue{
    for(int i=0; i < SOUND_METER_COUNT - 1; i++) {
        soundMeters[i] = soundMeters[i+1];
    }
    soundMeters[SOUND_METER_COUNT - 1] = lastValue;
    
    [self setNeedsDisplay];
}

#pragma mark - Drawing operations
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    int baseLine = BASEHEIGHT;
    static int multiplier = 1;
    int maxLengthOfWave = 45;
    int maxValueOfMeter = 400;
    int yHeights[6];
    float segement[6] = {0.05, 0.2, 0.35, 0.25, 0.1, 0.05};
    
    [[UIColor colorWithRed:55/255.0 green:180/255.0 blue:252/255.0 alpha:1] set];
    CGContextSetLineWidth(context, 2.0);
    
    
    for(int x = SOUND_METER_COUNT - 1; x >= 0; x--)
    {
        int multiplier_i = ((int)x % 2) == 0 ? 1 : -1;
        CGFloat y = ((maxValueOfMeter * (maxLengthOfWave - abs(soundMeters[(int)x]))) / maxLengthOfWave);
        yHeights[SOUND_METER_COUNT - 1 - x] = multiplier_i * y * segement[SOUND_METER_COUNT - 1 - x]  * multiplier+ baseLine;
    }
    [self drawLinesWithContext:context BaseLine:baseLine HeightArray:yHeights lineWidth:2.0 alpha:0.8 percent:1.0 segementArray:segement];
    [self drawLinesWithContext:context BaseLine:baseLine HeightArray:yHeights lineWidth:1.0 alpha:0.4 percent:0.66 segementArray:segement];
    [self drawLinesWithContext:context BaseLine:baseLine HeightArray:yHeights lineWidth:1.0 alpha:0.2 percent:0.33 segementArray:segement];
    multiplier = -multiplier;
}

- (void) drawLinesWithContext:(CGContextRef)context BaseLine:(float)baseLine HeightArray:(int*)yHeights lineWidth:(CGFloat)width alpha:(CGFloat)alpha percent:(CGFloat)percent segementArray:(float *)segement{
    
    CGFloat start = 0;
    [[UIColor colorWithRed:55/255.0
                     green:180/255.0
                      blue:245/255.0 alpha:1] set];
//    [[UIColor colorWithHexString:MainColor alpha:1.f] set];
    
    CGContextSetLineWidth(context, width);
    
    for (int i = 0; i < 6; i++) {
        if (i % 2 == 0) {
            CGContextMoveToPoint(context, start, baseLine);
            
            CGContextAddCurveToPoint(context, HUD_SIZE *segement[i] / 2 + start, (yHeights[i] - baseLine)*percent + baseLine, HUD_SIZE *segement[i] + HUD_SIZE *segement[i + 1] / 2 + start, (yHeights[i + 1] - baseLine)*percent + baseLine,HUD_SIZE *segement[i] + HUD_SIZE *segement[i + 1] + start , baseLine);
            start += HUD_SIZE *segement[i] + HUD_SIZE *segement[i + 1];
        }
    }
    CGContextStrokePath(context);
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    NSLog(@"error : %@",error);
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    [self.timer invalidate];
    if (_delegate && [_delegate respondsToSelector:@selector(recordArcView:voiceRecorded:length:)]) {
        [_delegate recordArcView:self voiceRecorded:self.recordPath length:self.recordTime];
    }
    [self setNeedsDisplay];
}
@end
