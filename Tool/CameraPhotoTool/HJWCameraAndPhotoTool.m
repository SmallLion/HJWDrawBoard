//
//  HJWCameraAndPhotoTool.m
//  drawboard
//
//  Created by Lion_Lemon on 16/8/26.
//  Copyright © 2016年 Lion_Lemon. All rights reserved.
//

#import "HJWCameraAndPhotoTool.h"
#import "UIImage+Extension.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef enum {
    photoType,
    cameraType,
    videoType
}pickerType;


#if TARGET_IPHONE_SIMULATOR

#define SIMULATOR 1

#elif TARGET_OS_IPHONE

#define SIMULATOR 0

#endif


static HJWCameraAndPhotoTool *tool ;

@interface HJWCameraAndPhotoTool ()<UIActionSheetDelegate>
@property (nonatomic, copy)cameraReturn finishBack;

@property (nonatomic, strong) UIActionSheet *actionSheet;

@property(nonatomic, weak)UIViewController *fromVc;

@property (nonatomic, strong) UIImagePickerController *picker;

@end

@implementation HJWCameraAndPhotoTool
+ (instancetype)shareInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[HJWCameraAndPhotoTool alloc] init];
    });
    
    return tool;
}


- (void)showVideoInViewController:(UIViewController *)vc andFinishBack:(cameraReturn)finishBack {
    if (SIMULATOR) {
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请在真机上使用"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alter show];
        return;
    }
    
    if (finishBack) {
        
        self.finishBack = finishBack;
    }
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    [self setUpImagePicker:videoType];
    
    [vc presentViewController:self.picker animated:YES completion:nil];//进入照相界面
    [vc.view layoutIfNeeded];
}


- (void)showCameraInViewController:(UIViewController *)vc andFinishBack:(cameraReturn)finishBack {
    [self showCameraInViewController:vc isNeedEdit:YES andFinishBack:finishBack];
}

- (void)showCameraInViewController:(UIViewController *)vc isNeedEdit:(BOOL)isNeedEdit andFinishBack:(cameraReturn)finishBack
{
    if (SIMULATOR) {
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请在真机上使用"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alter show];
        return;
    }
    
    if (finishBack) {
        self.finishBack = finishBack;
    }
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    [self setUpImagePicker:cameraType];
    self.picker.allowsEditing = isNeedEdit;

    [vc presentViewController:self.picker animated:YES completion:nil];//进入照相界面
    [vc.view layoutIfNeeded];
}

- (void)showPhotoInViewController:(UIViewController *)vc andFinishBack:(cameraReturn)finishBack{
    [self showPhotoInViewController:vc isNeedEdit:YES andFinishBack:finishBack];
}

- (void)showPhotoInViewController:(UIViewController *)vc isNeedEdit:(BOOL)isNeedEdit  andFinishBack:(cameraReturn)finishBack
{
    if (finishBack) {
        self.finishBack = finishBack;
    }
    
    [self setUpImagePicker:photoType];
    self.picker.allowsEditing = isNeedEdit;
    
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [vc presentViewController:self.picker animated:YES completion:nil];//进入相册界面
    [vc.view layoutIfNeeded];
}

//- (BOOL)

#pragma mark - imagePicker delegate
/**
 *  完成回调
 *
 *  @param picker imagePickerController
 *  @param info   信息字典
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        
        
        NSString *key = nil;
        
        if (picker.allowsEditing) {
            key = UIImagePickerControllerEditedImage;
        }else {
            key = UIImagePickerControllerOriginalImage;
        }
        //获取图片
        UIImage *image = [info objectForKey:key];
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {

            // 固定方向
            // image = [image fixOrientation];//这个方法是UIImage+Extras.h中方法
            // 压缩图片质量
            image = [self reduceImage:image percent:0.1];
            CGSize imageSize = image.size;
            imageSize.height = 320;
            imageSize.width = 320;
            // 压缩图片尺寸
            image = [self imageWithImageSimple:image scaledToSize:imageSize];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, NULL);
            });
        }
        
        //根据屏幕方向裁减图片(640, 480)||(480, 640),如不需要裁减请注释
//        image = [UIImage resizeImageWithOriginalImage:image];
        
        if (self.finishBack) {
            
            self.finishBack(image,nil);
        }
        
        [picker dismissViewControllerAnimated:YES completion:nil];
        
    }else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        
        NSURL *url= [info objectForKey:UIImagePickerControllerMediaURL];//视频路径
        NSString *urlStr = [url path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
            
            //保存视频到相簿，注意也可以使用ALAssetsLibrary来保存
            UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);//保存视频到相簿
        }
    }
    
    
}

//视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {//可以在此解析错误
        
    }else{//保存成功
        
        //录制完之后自动播放
        if (self.finishBack) {
            self.finishBack(nil,videoPath);
        }
        [self.picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)showImagePickerController:(UIViewController *)vc andFinishBack:(cameraReturn)finishBack{
    if (finishBack) {
        self.finishBack = finishBack;
    }
    
    if (vc) {
        self.fromVc = vc;
        [self.actionSheet showInView:vc.view];
    }
}

- (void)setUpImagePicker:(pickerType )type {
    
    self.picker = nil;
    
    self.picker = [[UIImagePickerController alloc] init];//初始化
    self.picker.delegate = self;
    self.picker.allowsEditing = YES;//设置可编辑
    
    if (type == photoType) {
        
        //判断用户是否允许访问相册权限
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied){
            //无权限
            return;
        }
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        self.picker.sourceType = sourceType;
    }else if (type == cameraType){
        //判断用户是否允许访问相机权限
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
        {
            //无权限
            return;
        }
        //判断用户是否允许访问相册权限
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied){
            //无权限
            return;
        }
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        self.picker.sourceType = sourceType;
    }else if (type == videoType) {
        //判断用户是否允许访问相机权限
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
        {
            //无权限
            return;
        }
        
        //判断用户是否允许访问麦克风权限
        authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
        {
            //无权限
            return;
        }
        
        //判断用户是否允许访问相册权限
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied){
            //无权限
            return;
        }
        
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        self.picker.sourceType = sourceType;
        
        self.picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        self.picker.videoQuality=UIImagePickerControllerQualityTypeIFrame1280x720;
        self.picker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModeVideo;
        
    }
    
}

#pragma mark - actionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        
        [self showCameraInViewController:self.fromVc andFinishBack:nil];
        
    }else if (buttonIndex == 1) {
        
        [self showPhotoInViewController:self.fromVc andFinishBack:nil];
        
    }else if (buttonIndex == 2) {
        
        [self showVideoInViewController:self.fromVc andFinishBack:nil];
    }
    
}

#pragma mark - getter and setter
- (UIActionSheet *)actionSheet {
    if (_actionSheet == nil) {
        _actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"相册",@"录像", nil];
    }
    return _actionSheet;
}

//压缩图片质量
- (UIImage *)reduceImage:(UIImage *)image percent:(float)percent
{
    NSData *imageData = UIImageJPEGRepresentation(image, percent);
    UIImage *newImage = [UIImage imageWithData:imageData];
    return newImage;
}
//压缩图片尺寸
- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
