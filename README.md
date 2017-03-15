# HJWDrawBoard

- 🕸 A Single HJWDrawBoard for iOS.
- 一款简单的画板视图

# Preview
<!--此处添加多张预览图-->
# Usage
## **ViewController :**
 
 添加 **HJWTagImageView.h** 并设置代理

  `#import "HJWTagImageView.h"` 
 
### init

```Objetive-C

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

```

### delegate

```Objetive-C

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
             [tagImageView addTagWithTitle:text point:centerPoint object:nil];
         }
     }];
    [alVC addAction:ac];
    [self presentViewController:alVC animated:YES completion:nil];
}

- (void)tagImageView:(HJWTagImageView *)tagImageView didClickVoiceGesture:(UITapGestureRecognizer *)tapGesture {
    // 弹出一个窗口添加语音
    CGPoint centerPoint = self.view.center;
    [HJWActionSheet hjw_showActionSheetViewWithTitle:nil
                                   cancelButtonTitle:@"取消"
                              destructiveButtonTitle:@"添加语音"
                                   otherButtonTitles:nil
                                    selectSheetBlock:^(HJWActionSheet *actionSheetView, NSInteger index)
    {
        if (index < 0) {
            return ;
        }
        // title为空 object为语音url
        [tagImageView addTagWithTitle:nil point:centerPoint object:@"https://www.baidu.com"];
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
}

- (void)tagImageView:(HJWTagImageView *)tagImageView tagViewActiveLongPressGesture:(HJWTagView *)tagView
{
    /** 可自定义长按手势的反馈 */
    if (tagView.isEditEnabled) {
        NSLog(@"编辑模式 -- 长按");
        [self showMessageWithContent:@"编辑模式 -- 长按" method:nil];

    }else{
        NSLog(@"预览模式 -- 长按");
        [self showMessageWithContent:@"预览模式 -- 长按" method:nil];
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

```

# issue
#### Demo中的开关代表了2种不同的绘制模式。
- 开关关闭 -> 贝塞尔曲线方式绘制 （默认状态）
- 开关开启 -> OpenGLES绘制 

当然除了以上的2种绘制方式外，还有可以使用**NSUndoManager+ Quartz2D **来实现Demo中的绘制功能。

对以上2种绘制方式进行对比，个人总结了各自的优缺点，以及建议选择的使用场景
##### 贝塞尔曲线
- **优点**

1. 这种实现方式最简单 而且也是直接调用oc的API实现，方法实现较为简单。
2. 用已知存储的点 添加路径 再绘制，速度很快。    
    
- **缺点**

1. 如果需要保持每条你画的线都在，你需要保存每一条绘画路径。
2. 每次在绘画新添加的绘画线条的时候，都要把这条线段之前所有的线段在重绘一次，浪费系统性能。
3. 如果你不在乎这点性能的浪费,那么还有问题,当你越画线段越多的时候 屏幕识别点的距离会越来越大，并且明显能感觉到绘画速度变慢 逐渐能看到之前线段绘画的轨迹。

- **应用场景**

1. 一次性画一些简单的线段,并且不做修改的情况下可以使用。
2. UI上需要做一些效果的简单线段可以使用。
3. 需要频繁修改和绘画的情况下，不建议使用。

##### OpenGLES
- **优点**

1. 很底层,绘画速度更快,直接通过硬件的渲染,解决了上一个在iPad3硬件下绘画会有断点的bug。
2. 性能更好。   
    
- **缺点**


1. 暂时我还没找到 画弧线的方法。

2. 更底层,API可读性太差 没有注释  根本看不懂 有注释的也没看懂几个。

3. 通过已知点,重绘的速度也慢,好在于相对于上一种方法的慢他是可以看到绘画轨迹的，可能适用于一些特殊的需求。

- **应用场景**

1. 一次性画一些简单的线段,并且不做修改的情况下可以使用。
2. UI上需要做一些效果的简单线段可以使用。
3. 需要频繁修改和绘画的情况下，不建议使用。

- **踩坑**
    
由于本人对于OpenGLES也不是很熟悉，我也是参看了苹果官方的Demo，然后加以集成的。
在集成过程也遇到了几个小坑。
    
1. 橡皮擦和画笔状态切换的时候回造成状态失效,原因不详...解决方案:每次touchBegain的时候都再次设置一次。
2. 橡皮擦状态下,擦除画笔的时候会有一个小圆点一直跟随笔迹,原因不详...解决方案同上。

