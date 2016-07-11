//
//  ViewController.m
//  FaceDemo
//
//  Created by L on 16/4/11.
//  Copyright © 2016年 L. All rights reserved.
//

#import "ViewController.h"
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
@interface ViewController ()
{
    CGFloat _wScale;
    CGFloat _hScale;
}
@property (nonatomic, strong) UIImageView *imgView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage* image = [UIImage imageNamed:@"IMG_0027.JPG"];
    _imgView = [[UIImageView alloc] initWithImage: image];
    _imgView.frame =  self.view.bounds;
    [self.view addSubview:_imgView];
    NSLog(@"%@",image);
    _hScale = ScreenHeight/image.size.height;//高比例
    _wScale = ScreenWidth/image.size.width;//宽比例
    [self faceTextByImage:image];
}

- (void)faceTextByImage:(UIImage *)image{
    //识别图片:
    CIImage *ciimage = [CIImage imageWithCGImage:image.CGImage];
    //设置识别参数,一个选项字典，它用来指定检测器的精度。你可以指定低精度或者高精度。低精度（CIDetectorAccuracyLow）执行得更快
    NSDictionary* opts = [NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    //声明一个CIDetector，并设定识别类型
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                            context:nil options:opts];
    //取得识别结果
    NSArray* features = [detector featuresInImage:ciimage];
    
    //创建一个和图片等大的VIew,覆盖在图片上面
    UIView *resultView = [[UIView alloc] initWithFrame:_imgView.frame];
//    resultView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:resultView];
    
    //标出脸部,眼睛和嘴:
    for (CIFaceFeature *faceFeature in features){
        // 标出脸部
        CGFloat faceWidth = faceFeature.bounds.size.width*_wScale;
        CGFloat faceHeight = faceFeature.bounds.size.height*_hScale;
        UIView* faceView = [[UIView alloc] initWithFrame:faceFeature.bounds];
        faceView.layer.borderWidth = 1;
        faceView.layer.borderColor = [[UIColor redColor] CGColor];
        [resultView addSubview:faceView];
        
        CGRect aRect = faceFeature.bounds;
        //打印没有缩放的原图脸部位置坐标
        NSLog(@"old :%f, %f, %f, %f", aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height);
        //打印适应屏幕后的脸部位置坐标
        NSLog(@"now :%f, %f, %f, %f", aRect.origin.x*_wScale, aRect.origin.y*_hScale, aRect.size.width*_wScale, aRect.size.height*_hScale);
        faceView.frame =  CGRectMake(aRect.origin.x*_wScale, aRect.origin.y*_hScale, aRect.size.width*_wScale, aRect.size.height*_hScale);
        if(faceFeature.hasLeftEyePosition) NSLog(@"Left eye %g %g\n", faceFeature.leftEyePosition.x, faceFeature.leftEyePosition.y);
        if(faceFeature.hasRightEyePosition) NSLog(@"Right eye %g %g\n", faceFeature.rightEyePosition.x, faceFeature.rightEyePosition.y);
        if(faceFeature.hasMouthPosition) NSLog(@"Mouth %g %g\n", faceFeature.mouthPosition.x, faceFeature.mouthPosition.y);
        // 标出左眼
        if(faceFeature.hasLeftEyePosition) {
            UIView* leftEyeView = [[UIView alloc] initWithFrame:
                                   CGRectMake(faceFeature.leftEyePosition.x*_wScale,
                                              faceFeature.leftEyePosition.y*_hScale, faceWidth*0.3, faceHeight*0.3)];
            [leftEyeView setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.3]];
            CGPoint center = CGPointMake(faceFeature.leftEyePosition.x*_wScale, faceFeature.leftEyePosition.y*_hScale);
            [leftEyeView setCenter:center];
            leftEyeView.layer.cornerRadius = faceWidth*0.15;
            [resultView addSubview:leftEyeView];
            NSLog(@"leftEyeView:%@  leftEyePosition_wscale:%f   _wscale:%f",leftEyeView,faceFeature.leftEyePosition.x*_wScale,_wScale);
        }
         /*
        // 标出右眼
        if(faceFeature.hasRightEyePosition) {
            UIView* rightEyeView = [[UIView alloc] initWithFrame:
                               CGRectMake(faceFeature.rightEyePosition.x-faceWidth*0.15,
                                          faceFeature.rightEyePosition.y-faceWidth*0.15, faceWidth*0.3, faceWidth*0.3)];
            [rightEyeView setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.3]];
            [rightEyeView setCenter:faceFeature.rightEyePosition];
            rightEyeView.layer.cornerRadius = faceWidth*0.15;
            [resultView addSubview:rightEyeView];
        }
        // 标出嘴部
        if(faceFeature.hasMouthPosition) {
            UIView* mouth = [[UIView alloc] initWithFrame:
                             CGRectMake(faceFeature.mouthPosition.x-faceWidth*0.2,
                                        faceFeature.mouthPosition.y-faceWidth*0.2, faceWidth*0.4, faceWidth*0.4)];
            [mouth setBackgroundColor:[[UIColor greenColor] colorWithAlphaComponent:0.3]];
            [mouth setCenter:faceFeature.mouthPosition];
            mouth.layer.cornerRadius = faceWidth*0.2;
            [resultView addSubview:mouth];
        }
         */
    }
    //得到的坐标点中，y值是从下开始的。比如说图片的高度为300，左眼的y值为100，说明左眼距离底部的高度为100，换成我们习惯的，距离顶部的距离就是200，这一点需要注意
    [resultView setTransform:CGAffineTransformMakeScale(1, -1)];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
