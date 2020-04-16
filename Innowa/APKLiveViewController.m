//
//  APKLiveViewController.m
//  万能AIT
//
//  Created by Mac on 17/3/21.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKLiveViewController.h"
#import "MobileVLCKit/VLCMediaPlayer.h"
#import "MBProgressHUD.h"
#import "APKAlertTool.h"
#import "APKCommonTaskTool.h"
#import "APKDVR.h"
#import "APKLiveView.h"




@interface APKLiveViewController ()<VLCMediaPlayerDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UIButton *quitButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *flower;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UIButton *captureVideoButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;

@property (strong,nonatomic) VLCMediaPlayer *mediaPlayer;
@property (strong,nonatomic) APKCommonTaskTool *taskTool;
@property (assign) NSInteger timeCount;
@property (nonatomic,retain) UIScrollView *scView;
@property (nonatomic,retain) UIView *playView;
@property (nonatomic,retain) APKLiveView *smallLiveV;
@property (weak, nonatomic) IBOutlet UIView *smallLiveView;
@property (nonatomic,assign) BOOL isPrepareToLive;


@end

@implementation APKLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    if (!self.isFullScreenMode) {

        self.quitButton.hidden = YES;
        self.captureButton.hidden = YES;
        self.captureVideoButton.hidden = YES;
        self.switchCameraButton.hidden = YES;
        
        CGRect frame = [UIScreen mainScreen].bounds;
        CGFloat screenWidth = CGRectGetWidth(frame);
        CGFloat screenHeight = CGRectGetHeight(frame);
        self.videoViewWidthConstraint.constant = screenWidth;
        self.videoViewHeightConstraint.constant = screenHeight;
//        [self.view addSubview:self.scView];
        
    }else{
        
        CGRect frame = [UIScreen mainScreen].bounds;
        CGFloat screenWidth = CGRectGetWidth(frame);
        CGFloat screenHeight = CGRectGetHeight(frame);
        self.videoViewWidthConstraint.constant = screenHeight;
        self.videoViewHeightConstraint.constant = screenWidth;
        [self.scView removeFromSuperview];
        self.scView = nil;
        self.mediaPlayer.drawable = [self.childViewControllers firstObject].view;
//        self.mediaPlayer.drawable = self.playView;

    }

    APKDVR *dvr = [APKDVR sharedInstance];
    [dvr addObserver:self forKeyPath:@"isConnected" options:NSKeyValueObservingOptionNew context:nil];
    
    self.captureButton.hidden = YES;
    self.captureVideoButton.hidden = YES;
    self.quitButton.hidden = YES;
    self.switchCameraButton.hidden = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startFullScreen" object:nil];
    
    
    
    NSString *imageName = [APKDVR sharedInstance].info.isFrontCamera == YES ? @"icon-26" : @"icon-25";
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.switchCameraButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    });

}


-(void)tapAction{
    
    self.captureButton.hidden = !self.captureButton.hidden;
    self.captureVideoButton.hidden = !self.captureVideoButton.hidden;
    self.quitButton.hidden = !self.quitButton.hidden;
    self.switchCameraButton.hidden = !self.switchCameraButton.hidden;
}
- (IBAction)clickChangeCameraButton:(UIButton *)sender {
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected) {
        [APKAlertTool showAlertInViewController:self message:NSLocalizedString(@"未连接DVR！", nil)];
        return;
    }
    
    KWEAKSELF;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (weakSelf.isFontCamera) {
        
        [weakSelf.taskTool setRearCamera:^(BOOL success) {
            
            [hud hideAnimated:YES];
            if (success) {
                weakSelf.isFontCamera = NO;
                [weakSelf showHUDWithMessage:NSLocalizedString(@"切换镜头成功！", nil) duration:1.f];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5/*延迟执行时间*/ * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf startLive];
                });
                [self.switchCameraButton setImage:[UIImage imageNamed:@"icon-25"] forState:UIControlStateNormal];
                
            }else{
                [APKAlertTool showAlertInViewController:weakSelf message:NSLocalizedString(@"切换镜头失败！", nil)];
            }
        }];
        
    }else{
        
        [weakSelf.taskTool setFontCamera:^(BOOL success) {
            
            [hud hideAnimated:YES];
            if (success) {
                weakSelf.isFontCamera = YES;
                [weakSelf showHUDWithMessage:NSLocalizedString(@"切换镜头成功！", nil) duration:1.f];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5/*延迟执行时间*/ * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf startLive];
                });
                [self.switchCameraButton setImage:[UIImage imageNamed:@"icon-26"] forState:UIControlStateNormal];
                
                
            }else{
                [APKAlertTool showAlertInViewController:weakSelf message:NSLocalizedString(@"切换镜头失败！", nil)];
            }
        }];
    }
}

- (void)showHUDWithMessage:(NSString *)message duration:(CGFloat)duration{
    
    MBProgressHUD *successHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    successHUD.mode = MBProgressHUDModeText;
    successHUD.userInteractionEnabled = NO;
    successHUD.label.text = message;
    [successHUD hideAnimated:YES afterDelay:duration];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self tapAction];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"isConnected"] && _isPrepareToLive == YES && [APKDVR sharedInstance].isConnected == YES) {
        
        [self startLive];
    }
}


static BOOL haveSplitscreen;
-(void)getSplitScreenNotification:(NSNotification*)notification
{
    NSInteger splitValue = [notification.userInfo[@"splitScreenValue"] integerValue];
    
    switch (splitValue) {
        case 100:
            if (!self.smallLiveV) {
                haveSplitscreen = YES;
                [self creatSmallLiveV];
                [self.playView addSubview:_smallLiveV];
                [_smallLiveV startLive];
                return;
            }
            [_smallLiveV startLive];
            break;
        case 101:
            if (!self.smallLiveV) {
                haveSplitscreen = YES;
                [self creatSmallLiveV];
                [self.playView addSubview:_smallLiveV];
                [_smallLiveV startLive];
                return;
            }
            [self.smallLiveV startLive];
            break;
        case 102:
            if (self.smallLiveV) {
            haveSplitscreen = NO;
            [self.smallLiveV removeFromSuperview];
            self.smallLiveV = nil;
            }
            break;
        default:
            if (self.smallLiveV) {
                haveSplitscreen = NO;
                [self.smallLiveV removeFromSuperview];
                self.smallLiveV = nil;
            }
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopLive) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSplitScreenNotification:) name:@"splitScreenNotication" object:nil];
    self.smallLiveView.hidden = YES;
    self.smallLiveV.hidden = YES;
    [self startLive];
    _isPrepareToLive = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"splitScreenNotication" object:nil];
    [self stopLive];
}

#pragma mark - UI

- (void)loadLiveUI{
    
    self.maskView.hidden = NO;
    self.playButton.hidden = YES;
    [self.flower startAnimating];
}

- (void)showLiveUI{
    
    [self.flower stopAnimating];
    [UIView animateWithDuration:1.f animations:^{
        
        self.maskView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        self.maskView.hidden = YES;
        self.maskView.alpha = 1;
    }];
}

- (void)noLiveUI{

    self.maskView.hidden = NO;
    self.playButton.hidden = NO;
    [self.flower stopAnimating];
}

#pragma mark - private method

- (void)startLive{
    
    [self loadLiveUI];
    self.timeCount = 0;
    
    //写死直播链接
//    NSString *str = @"rtsp://192.72.1.1/liveRTSP/av4";
//    NSURL *url = [NSURL URLWithString:str];
//    VLCMedia *media = [VLCMedia mediaWithURL:url];
//    [self.mediaPlayer setMedia:media];
    //    [self.mediaPlayer play];
    
    //动态获取直播链接
    __weak typeof(self)weakSelf = self;
    [self.taskTool getLiveInfo:^(BOOL success) {
        
        if (success) {
            
            APKDVR *dvr = [APKDVR sharedInstance];
            weakSelf.liveWHRatio = dvr.info.liveWHRatio;
            weakSelf.liveWHRatio = 1.77777;
            VLCMedia *media = [VLCMedia mediaWithURL:dvr.info.liveUrl];
            [weakSelf.mediaPlayer setMedia:media];
            [weakSelf.mediaPlayer play];
            
        }else{
            
            [weakSelf noLiveUI];
            if (weakSelf.isFullScreenMode) {
                [weakSelf quit:weakSelf.quitButton];
            }
        }
    }];
}

- (void)stopLive{
    
    [self.mediaPlayer stop];
}

#pragma mark - VLCMediaPlayerDelegate

- (void)mediaPlayerStateChanged:(NSNotification *)aNotification{
    
    switch (self.mediaPlayer.state) {
        case VLCMediaPlayerStateEnded:
        case VLCMediaPlayerStateStopped:
        case VLCMediaPlayerStateError:
            [self noLiveUI];
            break;
        case VLCMediaPlayerStatePlaying:
            
            break;
        default:
            break;
    }
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification{
    
    self.timeCount += 1;
    
    if (self.timeCount == 2)
    {
        [self showLiveUI];
        self.smallLiveV.hidden = NO;
        
        if (haveSplitscreen)
        {
            
            [self.playView bringSubviewToFront:self.smallLiveV];
        }
        
        if (self.isFullScreenMode && haveSplitscreen) {
            
            [self creatSmallLiveV];
            [self.view addSubview:self.smallLiveV];
            self.smallLiveV.frame = CGRectMake(CGRectGetMinX(self.smallLiveView.frame)-160, CGRectGetMinY(self.smallLiveView.frame) - 43, 200, 150);
            [_smallLiveV startLive];
        }

    }
}

#pragma mark - action

- (IBAction)play:(UIButton *)sender {
    
    [self startLive];
}

- (IBAction)quit:(UIButton *)sender {
 
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)captureVideo:(UIButton *)sender {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self)weakSelf = self;
    [self.taskTool recordEvent:^(BOOL success) {
        
        [hud hideAnimated:YES];
        
        if (!success) {
            [APKAlertTool showAlertInViewController:weakSelf message:NSLocalizedString(@"录制事件失败！", nil)];
        }else{
            MBProgressHUD *successHUD = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
            successHUD.mode = MBProgressHUDModeText;
            successHUD.userInteractionEnabled = NO;
            successHUD.label.text = NSLocalizedString(@"录制事件成功！", nil);
            [successHUD hideAnimated:YES afterDelay:1.f];
        }
    }];
}

- (IBAction)capture:(UIButton *)sender {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self)weakSelf = self;
    [self.taskTool takePhoto:^(BOOL success) {
       
        [hud hideAnimated:YES];
        
        if (!success) {
            [APKAlertTool showAlertInViewController:weakSelf message:NSLocalizedString(@"拍摄照片失败！", nil)];
        }else{
            MBProgressHUD *successHUD = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
            successHUD.mode = MBProgressHUDModeText;
            successHUD.userInteractionEnabled = NO;
            successHUD.label.text = NSLocalizedString(@"拍摄照片成功！", nil);
            [successHUD hideAnimated:YES afterDelay:1.f];
        }

    }];
}

#pragma mark - system

- (BOOL)shouldAutorotate{
    
    return self.isFullScreenMode;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return self.isFullScreenMode ? UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight : UIInterfaceOrientationMaskPortrait;
}

#pragma mark - setter

- (void)setLiveWHRatio:(float)liveWHRatio{
    
    _liveWHRatio = liveWHRatio;
    
//    if (self.isFullScreenMode) {
//        
//        CGRect frame = [UIScreen mainScreen].bounds;
//        CGFloat screenWidth = CGRectGetWidth(frame);
//        CGFloat screenHeight = CGRectGetHeight(frame);
//        
//        CGFloat liveViewWidth = screenHeight;
//        CGFloat liveViewHeight = liveViewWidth / liveWHRatio;
//        if (liveViewHeight < screenWidth) {
//            
//            liveViewHeight = screenWidth;
//            liveViewWidth = liveViewHeight * liveWHRatio;
//        }
//        
//        self.videoViewWidthConstraint.constant = liveViewWidth;
//        self.videoViewHeightConstraint.constant = liveViewHeight;
//    }
}

#pragma mark - getter


- (APKCommonTaskTool *)taskTool{
    
    if (!_taskTool) {
        _taskTool = [[APKCommonTaskTool alloc] init];
    }
    return _taskTool;
}

- (VLCMediaPlayer *)mediaPlayer{
    
    if (!_mediaPlayer) {
        
        NSString *caching = [NSString stringWithFormat:@"--network-caching=%d",900];
        NSString *jitter = [NSString stringWithFormat:@"--clock-jitter=%d",900];
        NSArray *options = @[caching,jitter];
//        UIViewController *content = [self.childViewControllers firstObject];
//        [content.view addSubview:self.scView];
        
        if (!_isFullScreenMode) {
            [self.view addSubview:self.scView];
        }
     
        _mediaPlayer = [[VLCMediaPlayer alloc] initWithOptions:options];
        _mediaPlayer.delegate = self;
        _mediaPlayer.drawable = self.playView;
        _mediaPlayer.videoAspectRatio = "16:9";
        
    }
    
    return _mediaPlayer;
}

-(UIScrollView*)scView
{
    if (!_scView) {
        
        _scView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _scView.delegate = self;
        [_scView setMinimumZoomScale:1.0];//设置最小的缩放大小
        _scView.maximumZoomScale = 2.0;//设置最大的缩放
        [_scView addSubview:self.playView];
        _scView.scrollEnabled = NO;
    }
    
    return  _scView;
}

-(UIView*)playView
{
    if (!_playView) {
        _playView = [[UIView alloc] initWithFrame:self.scView.bounds];
        
    }
    return _playView;
}

//-(APKLiveView *)smallLiveV
//{
//
//    if (!_smallLiveV) {
//        _smallLiveV = [[NSBundle mainBundle] loadNibNamed:@"APKLiveView" owner:nil options:nil].firstObject;
//        _smallLiveV.frame = self.smallLiveView.frame;
//        _smallLiveV.url = [APKDVR sharedInstance].info.liveUrl;
//    }
//
//
//    return _smallLiveV;
//}

-(void)creatSmallLiveV
{
    _smallLiveV = [[NSBundle mainBundle] loadNibNamed:@"APKLiveView" owner:nil options:nil].firstObject;
    _smallLiveV.frame = self.smallLiveView.frame;
    _smallLiveV.url = [APKDVR sharedInstance].info.liveUrl;
    _smallLiveV.hidden = NO;
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.playView;
}

//当正在缩放的时候调用
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    NSLog(@"正在缩放.....");
    
    
}

@end
