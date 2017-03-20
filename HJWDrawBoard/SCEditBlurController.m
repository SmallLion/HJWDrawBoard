//
//  SCEditBlurController.m
//  StudyChat
//
//  Created by Lemon_Mr.H on 2017/3/20.
//  Copyright © 2017年 Lion_Lemon. All rights reserved.
//

#import "SCEditBlurController.h"

#define MAX_LIMIT_NUMS 150


@interface SCEditBlurController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@end

@implementation SCEditBlurController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.backImage.contentMode = UIViewContentModeScaleAspectFit;
    self.backImage.clipsToBounds = YES;
    self.backImage.image = self.bgImage;
    
    self.textView.editable = self.isEditEnabled;
    self.textView.text = self.exitText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)doneBtnAction:(UIButton *)sender {
    // 回调文字
    if (self.isEditEnabled) {
        [self.view endEditing:YES];
        if (self.completeBlock) {
            self.completeBlock(self.textView.text);
            [self leftBarButtonItemPressed:nil];
        }
    }else {
        [self leftBarButtonItemPressed:nil];
    }
}

- (IBAction)cancelBtnAction:(id)sender {
    [self.view endEditing:YES];
    [self leftBarButtonItemPressed:nil];
}

- (void)leftBarButtonItemPressed:(id)sender {
    if (self.navigationController.viewControllers.count > 1 && self.navigationController.viewControllers[self.navigationController.viewControllers.count - 1] == self) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

#pragma mark - UITextViewDelegate
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self doneBtnAction:nil];
        return NO;
    }else return YES;
}
@end
