//
//  SCAudioRecordView.m
//  StudyChat
//
//  Created by Lion_Lemon on 16/7/21.
//  Copyright © 2016年 Lion_Lemon. All rights reserved.
//

#import "SCAudioRecordView.h"
#import "HJWRecordView.h"

#define kwid keyWindow.frame.size.width
#define khei keyWindow.frame.size.height
#define swid self.frame.size.width
#define shei self.frame.size.height
#define kScreenBounds ([[UIScreen mainScreen] bounds])
#define kScreenWidth (kScreenBounds.size.width)
#define kScreenHeight (kScreenBounds.size.height)

const CGFloat menuBlankWidth         = 80;

@interface SCAudioRecordView ()<HJWRecordViewDelegate, AVAudioPlayerDelegate>
{
    UIVisualEffectView *blurView;
    UIView *helperSideView;
    UIView *helperCenterView;
    UIWindow *keyWindow;
    BOOL triggered;
    CGFloat diff;
    UIColor *_menuColor;
    CGFloat menuButtonHeight;
}

@property (nonatomic,strong) CADisplayLink *displayLink;
@property  NSInteger animationCount; // 动画的数量

@property (nonatomic, strong) UIButton * closeBtn, *submitBtn, *delButton;
@property (nonatomic, strong) UIView * dimBackgroundView, * EditProgressView;

@property (nonatomic, strong) HJWRecordView * recordView;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@property (nonatomic, assign) BOOL isFinished;
@property (nonatomic, assign) NSInteger playerCount;
@property (nonatomic, assign) CGFloat audioLength;

@end

@implementation SCAudioRecordView
#pragma mark - Overite
//[UIColor colorWithRed:0 green:175 / 255.f blue: 240 / 255.f alpha:1]
- (id)initWithTitles:(NSArray *)titles{
    return [self initWithTitles:titles
               withButtonHeight:40.0f
                  withMenuColor:[[UIColor whiteColor] colorWithAlphaComponent:.7f]
              withBackBlurStyle:UIBlurEffectStyleDark];
}

- (id)initWithTitles: (NSArray *)titles withButtonHeight: (CGFloat)height withMenuColor: (UIColor *)menuColor withBackBlurStyle: (UIBlurEffectStyle) style {
    
    self = [super init];
    if (self) {
        keyWindow = [[UIApplication sharedApplication] keyWindow];
        
        // 背景设置为模糊效果
        // UIVisualEffectView
        blurView = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:style]];
        blurView.frame = keyWindow.frame;
        blurView.alpha = 0.0f;
        
        // 左上角辅助视图
        helperSideView = [[UIView alloc] initWithFrame: CGRectMake(0, kScreenHeight + 40, 40, 40)];
        helperSideView.backgroundColor = [UIColor redColor];
        helperSideView.hidden = YES;
        [keyWindow addSubview: helperSideView];
        
        // 中央辅助视图
        helperCenterView = [[UIView alloc] initWithFrame: CGRectMake(kScreenWidth / 2 - 20, kScreenHeight + 40, 40, 40)];
        helperCenterView.backgroundColor = [UIColor yellowColor];
        helperCenterView.hidden = YES;
        [keyWindow addSubview: helperCenterView];
        
        // 创建下边界界外的视图
        self.frame = CGRectMake(0, kScreenHeight / 2 - menuBlankWidth, kScreenWidth, kScreenHeight / 2 + menuBlankWidth);
        self.backgroundColor = [UIColor clearColor];
        [keyWindow insertSubview: self belowSubview: helperSideView];
        
        _menuColor = menuColor;
        menuButtonHeight = height;
        // 视图辅助观察颜色
        [self customInterface];
    }
    return self;
}

- (void)customInterface {
    _closeBtn         = [UIButton new];
    _submitBtn        = [UIButton new];
    _delButton        = [UIButton new];
    _recordView       = [[HJWRecordView alloc] initWithFrame:CGRectZero];
    [self setup];
}

- (void)setup {
    _closeBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [_closeBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_closeBtn setTitleColor:[UIColor lightTextColor]
                    forState:UIControlStateNormal];
    [_closeBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [_closeBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    _closeBtn.layer.cornerRadius = 5;
    _closeBtn.layer.masksToBounds = YES;
    
    _submitBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [_submitBtn setTitle:@"完成" forState:UIControlStateNormal];
    [_submitBtn setTitleColor:[UIColor blueColor]
                     forState:UIControlStateNormal];
    [_submitBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [_submitBtn setTitleColor:[UIColor lightTextColor] forState:UIControlStateDisabled];
    [_submitBtn addTarget:self action:@selector(finishAction) forControlEvents:UIControlEventTouchUpInside];
    _submitBtn.enabled = NO;
    _submitBtn.layer.cornerRadius = 5;
    _submitBtn.layer.masksToBounds = YES;
    
    _delButton.enabled = NO;
    _delButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    _delButton.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.75];
    [_delButton setTitle:@"点击删除  重新录制" forState:UIControlStateNormal];
    [_delButton setTitleColor:[UIColor whiteColor]
                         forState:UIControlStateNormal];
    [_delButton setTitleColor:[UIColor lightTextColor]
                     forState:UIControlStateHighlighted];

    [_delButton addTarget:self
                       action:@selector(rest:)
             forControlEvents:UIControlEventTouchUpInside];
    _delButton.layer.cornerRadius = 5;
    _delButton.layer.masksToBounds = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _recordView.frame = CGRectMake(0.0, 0.0, kScreenWidth, 120);
    _recordView.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    _recordView.delegate = self;
    [self addSubview:_recordView];

    _closeBtn.frame  = CGRectMake(0, 90, 60, 36);
    [self addSubview:_closeBtn];
    
    _submitBtn.frame = CGRectMake(kScreenWidth - 60, 90, 60, 36);
    [self addSubview:_submitBtn];

    _delButton.frame = CGRectMake(kScreenWidth / 2 - 100, CGRectGetMaxY(_recordView.frame), 200, 38);
    [self addSubview:self.delButton];
}

#pragma mark - HJWRecordViewDelegate
- (void)recordArcView:(HJWRecordView *)arcView voiceRecorded:(NSString *)recordPath length:(float)recordLength {
    self.audioLength = recordLength;
    self.submitBtn.enabled = YES;
}

- (void)recordArcView:(HJWRecordView *)arcView onclickButton:(UIButton *)button {
    if (self.playerCount == 0) {
        [self.recordView startRecording];
        //图片设置为停止录制
        [button setImage:[UIImage imageNamed:@"audio-btn-stop"] forState:UIControlStateNormal];
    }
    
    if (arcView.recorder.isRecording && self.playerCount > 0) {
        self.delButton.enabled = YES;
        [self.recordView commitRecording];
        //图片设置为播放
        [button setImage:[UIImage imageNamed:@"audio-btn-play"] forState:UIControlStateNormal];
    }
    if (self.playerCount >= 2) {
        self.delButton.enabled = YES;
        
        if (self.audioPlayer.isPlaying && self.playerCount % 2 != 0) {
            //正在播放
            [self.audioPlayer pause];
            //图片设置为播放
            [button setImage:[UIImage imageNamed:@"audio-btn-play"] forState:UIControlStateNormal];
        }else {
            [self.audioPlayer play];
            //图片设置为暂停
            [button setImage:[UIImage imageNamed:@"audio-btn-pause"] forState:UIControlStateNormal];
        }
    }
    self.playerCount++;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"%@", @"播放结束");
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                           error:nil];
    [self.recordView.recordButton setImage:[UIImage imageNamed:@"audio-btn-play"]
                                  forState:UIControlStateNormal];
}

#pragma mark - Btns Action
- (void)finishAction {
    //提交并隐藏
    if (self.audioPlayer.isPlaying) {
        [self.audioPlayer stop];
    }
    
    if (self.recordView.recorder.isRecording && self.playerCount > 0) {
        [self.recordView commitRecording];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(SCAudioRecordView:didFinishedRecordWithPath:length:)]) {
        [_delegate SCAudioRecordView:self didFinishedRecordWithPath:self.recordView.recordPath length:self.audioLength];
        [self tapToUntrigger];
    }
}

- (void)cancelAction {
    [self.recordView stopRecording];
    [self.audioPlayer stop];
    self.playerCount = 0;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    if (YES != [fm removeItemAtPath:self.recordView.recordPath error:&error]) {
        NSLog(@"remove path=%@, error=%@", self.recordView.recordPath, [error description]);
    }
    [self tapToUntrigger];
}

- (void)rest:(UIButton *)button {
    if (self.audioPlayer.isPlaying) {
        [self.audioPlayer pause];
    }
    
    self.submitBtn.enabled = NO;
    self.playerCount = 0;
    [self.recordView startRecording];
    
    [self.recordView.recordButton setImage:[UIImage imageNamed:@"audio-btn-stop"]
                                  forState:UIControlStateNormal];
    self.playerCount++;
}

//重画
- (void)drawRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint: CGPointMake(0, shei)];
    [path addLineToPoint: CGPointMake(0, shei - khei / 2 )];
    [path addQuadCurveToPoint: CGPointMake(kScreenWidth, shei - khei / 2)
                 controlPoint: CGPointMake(swid / 2,  diff + menuBlankWidth)];
    [path addLineToPoint: CGPointMake(kScreenWidth, shei)];
    [path closePath];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddPath(context, path.CGPath);
    [_menuColor set];
    CGContextFillPath(context);
}

- (void) trigger{
    if (!triggered) {
        [keyWindow insertSubview:blurView belowSubview:self];
        [UIView animateWithDuration: 0.618 animations:^{
            self.frame = CGRectMake(0, kScreenHeight / 2 - menuBlankWidth, kScreenWidth, kScreenHeight / 2 + menuBlankWidth);
        }];
        
        [self beforeAnimation];
        [UIView animateWithDuration: 1
                              delay: 0.0f
             usingSpringWithDamping: 0.5f
              initialSpringVelocity: 0.9f
                            options: UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations: ^{
                             helperSideView.center = CGPointMake(20, kScreenHeight / 2);
                         }
                         completion: ^(BOOL finished) {
                             [self finishAnimation];
                         }];
        
        [UIView animateWithDuration: 0.3 animations: ^{
            blurView.alpha = 1.0f;
        }];
        
        [self beforeAnimation];
        [UIView animateWithDuration: 1
                              delay: 0.0f
             usingSpringWithDamping: 0.8f
              initialSpringVelocity: 2.0f
                            options: UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations: ^{
                             helperCenterView.center = keyWindow.center;
                         }
                         completion: ^(BOOL finished) {
                             if (finished) {
                                 UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(tapToUntrigger)];
                                 [blurView addGestureRecognizer: tapGes];
                                 [self finishAnimation];
                             }
                         }];
        [self animateButtons];
        triggered = YES;
    } else {
        [self tapToUntrigger];
    }
}

- (void) animateButtons{
    for (NSInteger i = 0; i < self.subviews.count; i++) {
        UIView *menuButton = self.subviews[i];
        menuButton.transform = CGAffineTransformMakeTranslation(0, -90);
        [UIView animateWithDuration: 0.7
                              delay: i * (0.3 / self.subviews.count)
             usingSpringWithDamping: 0.6f
              initialSpringVelocity: 0.0f
                            options: UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations: ^{
                             menuButton.transform =  CGAffineTransformIdentity;
                         }
                         completion: NULL];
    }
}

- (void) tapToUntrigger{
    
    [UIView animateWithDuration: 0.618 animations:^{
        self.frame = CGRectMake(0, khei + khei / 2 + menuBlankWidth, kwid, khei / 2 + menuBlankWidth);
    }];
    
    [self beforeAnimation];
    [UIView animateWithDuration: 1
                          delay: 0.0f
         usingSpringWithDamping: 0.6f
          initialSpringVelocity: 0.9f
                        options: UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations: ^{
                         helperSideView.center = CGPointMake(20, kScreenHeight + 20);
                     }
                     completion: ^(BOOL finished) {
                         [self finishAnimation];
                     }];
    
    [UIView animateWithDuration:0.3 animations: ^{
        blurView.alpha = 0.0f;
        [blurView removeFromSuperview];
    }];
    
    [self beforeAnimation];
    [UIView animateWithDuration: 1
                          delay: 0.0f
         usingSpringWithDamping: 0.7f
          initialSpringVelocity: 2.0f
                        options: UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations: ^{
                         helperCenterView.center = CGPointMake(kScreenWidth / 2, kScreenHeight + 20);
                     }
                     completion: ^(BOOL finished) {
                         [self finishAnimation];
                     }];
    triggered = NO;
}

//动画之前调用
- (void)beforeAnimation{
    if (self.displayLink == nil) {
        self.displayLink = [CADisplayLink displayLinkWithTarget: self selector: @selector(displayLinkAction:)];
        [self.displayLink addToRunLoop: [NSRunLoop mainRunLoop] forMode: NSDefaultRunLoopMode];
    }
    self.animationCount ++;
}

//动画完成之后调用
- (void) finishAnimation{
    self.animationCount --;
    if (self.animationCount == 0) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void) displayLinkAction: (CADisplayLink *)dis {
    CALayer *sideHelperPresentationLayer   =  (CALayer *)[helperSideView.layer presentationLayer];
    CALayer *centerHelperPresentationLayer =  (CALayer *)[helperCenterView.layer presentationLayer];
    
    CGRect centerRect = [[centerHelperPresentationLayer valueForKeyPath:@"frame"] CGRectValue];
    CGRect sideRect = [[sideHelperPresentationLayer valueForKeyPath:@"frame"] CGRectValue];
    
    diff = sideRect.origin.y - centerRect.origin.y;
    
    // 重新布局方法
    // 在receiver标上一个需要被重新绘图的标记，在下一个draw周期自动重绘
    // 默认runloop周期 60Hz
    [self setNeedsDisplay];
}

/**
 *  创建播放器
 *
 *  @return 播放器
 */
- (AVAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
        if ([[[AVAudioSession sharedInstance] category] isEqualToString:AVAudioSessionCategoryPlayback]) {
            //切换为听筒播放
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                                   error:nil];
        }else {
            //切换为扬声器播放
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                                   error:nil];
        }
        NSURL *url                 = [NSURL fileURLWithPath:self.recordView.recordPath];
        NSError *error             = nil;
        _audioPlayer               = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        _audioPlayer.numberOfLoops = 0;
        _audioPlayer.volume        = 1.0;
        _audioPlayer.delegate      = self;
        [_audioPlayer prepareToPlay];
        if (error) {
            NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}
@end
