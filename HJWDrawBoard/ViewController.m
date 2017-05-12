//
//  ViewController.m
//  HJWDrawBoard
//
//  Created by Lemon_Mr.H on 2017/3/10.
//  Copyright © 2017年 Lemon_Mr.H. All rights reserved.
//

#import "ViewController.h"
#import "HJWTagImageView.h"
#import "HJWActionSheet.h"
#import "HJWCameraAndPhotoTool.h"
#import "UIView+HJW.h"
#import "HJWAlertViewController.h"
#import "SCEditBlurController.h"
#import "SCAudioRecordView.h"

/**
 *  判断字符串是否为空
 */
#define hjw_StrIsEmpty(str) ([str isKindOfClass:[NSNull class]] || [str length] < 1 ? YES : NO || [str isEqualToString:@"(null)"] || [str isEqualToString:@"null"])

@interface ViewController ()<HJWTagImageViewDelegate, SCAudioRecordViewDelegate>

@property (nonatomic, strong) HJWTagImageView *imageView;
@property (nonatomic, strong) NSArray *tagInfoArray;

@property (nonatomic, strong) UIButton *drawSaveBtn, *closeBtn;
@property (nonatomic, strong) UISwitch * sw;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self layoutUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.imageView showAllTagsAnimation];
}

- (void)layoutUI {
    [self.view addSubview:self.imageView];
    
    UIButton * drawSaveBtn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 54, 25, 44, 44)];
    [drawSaveBtn addTarget:self action:@selector(drawSaving:) forControlEvents:UIControlEventTouchUpInside];
    [drawSaveBtn setImage:[UIImage imageNamed:@"baocun"] forState:UIControlStateNormal];
    drawSaveBtn.hidden = YES;
    
    UIButton * closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 25, 44, 44)];
    [closeBtn addTarget:self action:@selector(chooseImage:) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setImage:[UIImage imageNamed:@"closeBtn"] forState:UIControlStateNormal];
    closeBtn.hidden = YES;
    
    [self.view addSubview:drawSaveBtn];
    [self.view addSubview:closeBtn];
    self.drawSaveBtn = drawSaveBtn;
    self.closeBtn = closeBtn;
    
    UISwitch * sw = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    sw.center = CGPointMake(self.view.center.x, 25 + 20);
    [sw addTarget:self action:@selector(changeDrawingBoard:) forControlEvents:UIControlEventValueChanged];
    sw.hidden = YES;
    [self.view addSubview:sw];
    self.sw = sw;
}

- (void)changeDrawingBoard:(UISwitch *)sw {
    if (sw.isOn) {
        [self showMessageWithContent:@"OpenGLES" method:nil];
    }else {
        [self showMessageWithContent:@"贝塞尔曲线" method:nil];
    }
    
    self.imageView.isOpenGL = sw.isOn;
    [self.imageView changeDrawingBoard];
}

- (HJWTagImageView *)imageView {
    if (!_imageView) {
        _imageView = ({
            HJWTagImageView *imageView = [[HJWTagImageView alloc] initWithFrame:self.view.bounds];
            imageView.delegate = self;
            imageView.hidden = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.clipsToBounds = YES;
            imageView;
        });
    }
    return _imageView;
}

- (void)drawSaving:(id)sender {
    // 保存图片
    [self.imageView hiddenAllTools];
    [self showMessageWithContent:@"确定要保存标记" method:@selector(save)];
}

- (void)save {
    UIImageWriteToSavedPhotosAlbum([self screenshot:self.imageView], nil, nil, nil);
}

#pragma mark - Public Method
- (void)showMessageWithContent:(NSString *)content method:(SEL)method {
    HJWAlertViewController *alertVC =
    [HJWAlertViewController alertControllerWithTitle:nil message:content ];
    
    HJWAlertAction *cancel = [HJWAlertAction actionWithTitle:@"取消"
                                                     handler:nil];
    
    HJWAlertAction *sure = [HJWAlertAction actionWithTitle:@"确定"
                                                   handler:^(HJWAlertAction *action)
                            {
                                if (!method) {
                                    return ;
                                }
                                [self performSelector:method];
                            }];
    
    [alertVC addAction:cancel];
    [alertVC addAction:sure];
    [self presentViewController:alertVC animated:NO completion:nil];
}

- (IBAction)chooseImage:(id)sender {
    // 选取图片
    [HJWActionSheet hjw_showActionSheetViewWithTitle:nil
                                   cancelButtonTitle:@"取消"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@[@"拍照", @"从手机相册选择"]
                                    selectSheetBlock:^(HJWActionSheet *actionSheetView, NSInteger index)
     {
         HJWCameraAndPhotoTool * tool = [HJWCameraAndPhotoTool shareInstance];
         switch (index) {
             case 0:
             {
                 [tool showCameraInViewController:self
                                       isNeedEdit:NO
                                    andFinishBack:^(UIImage *image, NSString *videoPath)
                  {
                      self.drawSaveBtn.hidden = NO;
                      self.closeBtn.hidden = NO;
                      self.imageView.hidden = NO;
                      self.sw.hidden = NO;
                      self.imageView.image = image;
                  }];
             }
                 break;
             case 1:
             {
                 [tool showPhotoInViewController:self
                                      isNeedEdit:NO
                                   andFinishBack:^(UIImage *image, NSString *videoPath)
                  {
                      self.drawSaveBtn.hidden = NO;
                      self.closeBtn.hidden = NO;
                      self.imageView.hidden = NO;
                      self.sw.hidden = NO;
                      self.imageView.image = image;
                  }];
             }
                 break;
             default:
                 break;
         }
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TagImageViewDelegate
- (void)tagImageView:(HJWTagImageView *)tagImageView activeTapGesture:(UITapGestureRecognizer *)tapGesture
{
    CGPoint tapPoint = [tapGesture locationInView:tagImageView];
    // 调出一个vc去编辑文字
    UIAlertController *alVC = [UIAlertController alertControllerWithTitle:@"添加标签" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alVC addTextFieldWithConfigurationHandler:nil];
    UIAlertAction *ac =
    [UIAlertAction actionWithTitle:@"确定"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * _Nonnull action)
     {
         NSString *text = ((UITextField *)(alVC.textFields[0])).text;
         if (text.length) {
             // 添加标签
             [tagImageView addTagWithTitle:text point:tapPoint object:nil];
         }
     }];
    [alVC addAction:ac];
    [self presentViewController:alVC animated:YES completion:nil];
}

- (void)tagImageView:(HJWTagImageView *)tagImageView didClickPanGesture:(UITapGestureRecognizer *)tapGesture {
    // 点击画板按钮
}

- (void)tagImageView:(HJWTagImageView *)tagImageView didClickTextGesture:(UITapGestureRecognizer *)tapGesture {
    CGPoint centerPoint = self.view.center;
    // 添加文字
    UIStoryboard * mainStoryboard =
    [UIStoryboard storyboardWithName:NSStringFromClass([SCEditBlurController class]) bundle:nil];
    SCEditBlurController * editBlur =
    [mainStoryboard instantiateViewControllerWithIdentifier:NSStringFromClass([SCEditBlurController class])];
    
    editBlur.bgImage = tagImageView.image;
    editBlur.isEditEnabled = YES;
    editBlur.completeBlock = ^(NSString * CompleteStr) {
        if (CompleteStr.length) {
            // 添加标签
            [tagImageView addTagWithTitle:CompleteStr point:centerPoint object:nil];
        }
    };
    [self presentViewController:editBlur animated:YES completion:nil];
}

- (void)tagImageView:(HJWTagImageView *)tagImageView didClickVoiceGesture:(UITapGestureRecognizer *)tapGesture {
    // 弹出一个窗口添加语音
    [HJWActionSheet hjw_showActionSheetViewWithTitle:nil
                                   cancelButtonTitle:@"取消"
                              destructiveButtonTitle:@"添加语音"
                                   otherButtonTitles:nil
                                    selectSheetBlock:^(HJWActionSheet *actionSheetView, NSInteger index)
     {
         if (index < 0) {
             return ;
         }
         // title为语音长度 object为语音url
         SCAudioRecordView * recordView = [[SCAudioRecordView alloc] initWithTitles:nil];
         recordView.delegate = self;
         [recordView trigger];
     }];
}

#pragma mark - TagViewDelegate
- (void)tagImageView:(HJWTagImageView *)tagImageView tagViewActiveTapGesture:(HJWTagView *)tagView
{
    /** 可自定义点击手势的反馈 */
    if (tagView.isEditEnabled) {
        NSLog(@"编辑模式 -- 轻触");
        [tagView switchDeleteState];
    }else{
        NSLog(@"预览模式 -- 轻触");
        [self showMessageWithContent:@"预览模式 -- 轻触" method:nil];
    }
    
    // 如果object不为空，则播放
    if (!hjw_StrIsEmpty(tagView.tagInfo.object)) {
        // 播放声音
#warning waiting play
    }
}

- (void)tagImageView:(HJWTagImageView *)tagImageView tagViewActiveLongPressGesture:(HJWTagView *)tagView
{
    /** 可自定义长按手势的反馈 */
    // 如果为文本标签🏷
    if (hjw_StrIsEmpty(tagView.tagInfo.object)) {
        UIStoryboard * mainStoryboard =
        [UIStoryboard storyboardWithName:NSStringFromClass([SCEditBlurController class]) bundle:nil];
        
        SCEditBlurController * editBlur =
        [mainStoryboard instantiateViewControllerWithIdentifier:NSStringFromClass([SCEditBlurController class])];
        editBlur.bgImage = tagImageView.image;
        
        if (tagView.isEditEnabled) {
            NSLog(@"编辑模式 -- 长按");
            //        [self showMessageWithContent:@"编辑模式 -- 长按" method:nil];
            
            editBlur.isEditEnabled = YES;
            editBlur.completeBlock = ^(NSString * CompleteStr) {
                if (CompleteStr.length) {
                    [tagView updateTitle:CompleteStr];
                }
            };
        }else{
            NSLog(@"预览模式 -- 长按");
            //        [self showMessageWithContent:@"预览模式 -- 长按" method:nil];
            editBlur.isEditEnabled = NO;
        }
        [self presentViewController:editBlur animated:YES completion:nil];
    }
}

- (void)tagImageView:(HJWTagImageView *)tagImageView tagViewActivePanGesture:(HJWTagView *)tagView
{
    if (tagView.isEditEnabled) {
        NSLog(@"编辑模式 -- 拖动");
        [self showMessageWithContent:@"编辑模式 -- 拖动" method:nil];
    }else{
        NSLog(@"预览模式 -- 拖动");
        [self showMessageWithContent:@"预览模式 -- 拖动" method:nil];
    }
}

#pragma mark - SCAudioRecordViewDelegate
- (void)SCAudioRecordView:(SCAudioRecordView *)recordView
didFinishedRecordWithPath:(NSString *)path
                   length:(CGFloat)length
{
    CGPoint centerPoint = self.view.center;

    if (path.length == 0 || length < 0) {
        return;
    }
    [recordView removeFromSuperview];
    recordView = nil;
    NSLog(@"%@--%lf", path, length);
    
    [self.imageView addTagWithTitle:[NSString stringWithFormat:@"%.1lfs", length]
                              point:centerPoint
                             object:path];

}

// 截屏存储
- (UIImage *)screenshot:(UIView *)shotView {
    
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, YES, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [shotView.layer renderInContext:context];
    
    UIImage *getImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return getImage;
}

- (IBAction)recordDebugAction:(id)sender {
    SCAudioRecordView * recordView = [[SCAudioRecordView alloc] initWithTitles:nil];
    recordView.delegate = self;
    [recordView trigger];
}


@end
