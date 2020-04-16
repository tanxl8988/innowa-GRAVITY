//
//  APKCameraViewController.m
//  Innowa
//
//  Created by Mac on 17/3/28.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKCameraViewController.h"
#import "APKLiveViewController.h"
#import "APKDVR.h"
#import "APKDVRTask.h"
#import "MBProgressHUD.h"
#import "APKAlertTool.h"
#import "APKCommonTaskTool.h"
#import "JYJSliderMenuTool.h"
#import "APKCustomTabBarController.h"
#import "APKSplitScreenView.h"
#import "previewSettingView.h"

@interface APKCameraViewController ()<UIGestureRecognizerDelegate,APKLiveViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *disconnectTipsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *disconnectTipsSubtitleLabel;
@property (weak, nonatomic) IBOutlet UIView *liveContentView;
@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UIButton *recordEventButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (nonatomic,retain) APKSplitScreenView *splitScreenView;
@property (weak, nonatomic) IBOutlet UIButton *recordVoiceButton;
@property (nonatomic,retain) previewSettingView *EvSettingView;

@property (weak, nonatomic) IBOutlet UIView *buttomView;
@property (strong,nonatomic) APKCommonTaskTool *taskTool;
@property (assign) BOOL isFontCamera;
@property (weak,nonatomic) APKLiveViewController *live;
/** tapGestureRec */
@property (nonatomic, weak) UITapGestureRecognizer *tapGestureRec;
/** panGestureRec */
@property (weak, nonatomic) IBOutlet UIButton *fullScreenButton;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRec;
@property (assign) BOOL isParkingMode;
@property (assign) BOOL isUrgencyVideo;
@property (weak, nonatomic) IBOutlet UIButton *changCameraButton;

@end

@implementation APKCameraViewController

#pragma mark - life circle

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        APKDVR *dvr = [APKDVR sharedInstance];
        [dvr addObserver:self forKeyPath:@"isConnected" options:NSKeyValueObservingOptionNew context:nil];
        [dvr addObserver:self forKeyPath:@"info.haveRearCamera" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = NSLocalizedString(@"摄像机", nil);
    self.disconnectTipsTitleLabel.text = NSLocalizedString(@"未连接", nil);
    self.disconnectTipsSubtitleLabel.text = NSLocalizedString(@"未连接提示", nil);
    
    APKDVR *dvr = [APKDVR sharedInstance];
    self.liveContentView.hidden = !dvr.isConnected;
//    self.switchCameraButton.hidden = !dvr.info.haveRearCamera;
    
    for (UIViewController *vc in self.childViewControllers) {
        
        if ([vc isKindOfClass:[APKLiveViewController class]]) {
            
            self.live = (APKLiveViewController *)vc;
            [self.live addObserver:self forKeyPath:@"liveWHRatio" options:NSKeyValueObservingOptionNew context:nil];
            break;
        }
    }
    
//    // 屏幕边缘pan手势(优先级高于其他手势)
//    UIScreenEdgePanGestureRecognizer *leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
//                                                                                                          action:@selector(moveViewWithGesture:)];
//    leftEdgeGesture.edges = UIRectEdgeLeft;// 屏幕左侧边缘响应
//    [self.view addGestureRecognizer:leftEdgeGesture];
//    // 这里是地图处理方式，遵守代理协议，实现代理方法
//    leftEdgeGesture.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.liveContentView addGestureRecognizer:tap];
    self.liveContentView.userInteractionEnabled = YES;
    self.view.userInteractionEnabled = YES;
    self.buttomView.userInteractionEnabled = YES;

    
}

-(void)clickSwitchCameraButtonAction
{
    [self switchCamera:self.switchCameraButton];
}

-(void)tapAction{
    
    self.fullScreenButton.hidden = !self.fullScreenButton.hidden;
    self.switchCameraButton.hidden = !self.switchCameraButton.hidden;
    [self.view bringSubviewToFront:self.fullScreenButton];
}
- (IBAction)hidePreviewActionBtnClick:(UIButton *)sender {
    [self tapAction];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    [self tapAction];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.EvSettingView refleshSliderValue];
    
    APKDVRInfo *info = [APKDVR sharedInstance].info;
    if (info) {
        self.recordVoiceButton.selected = info.recordSound;
    }
    
    __weak typeof(self)weakSelf = self;
    [self.taskTool getWifiInfo:^(BOOL success) {
        if (success) {
            
            APKDVRInfo *info = [APKDVR sharedInstance].info;
            weakSelf.recordVoiceButton.selected = info.recordSound;
            
            [self.taskTool getCameraInfo:^(BOOL success) {
                
                NSString *imageName = [APKDVR sharedInstance].info.isFrontCamera == YES ? @"icon-26" : @"icon-25";
                self.isFontCamera = [imageName isEqualToString:@"icon-26"] == YES ? YES : NO;
                self.live.isFontCamera = self.isFontCamera;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.switchCameraButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
                });
            }];
        }
    }];
}

- (void)moveViewWithGesture:(UIPanGestureRecognizer *)panGes {
    if (panGes.state == UIGestureRecognizerStateEnded) {
        [self profileCenter];
    }
}

- (void)profileCenter {
    // 展示个人中心
    [JYJSliderMenuTool showWithRootViewController:self];
}

- (void)dealloc
{
    APKDVR *dvr = [APKDVR sharedInstance];
    [dvr removeObserver:self forKeyPath:@"isConnected"];
    [dvr removeObserver:self forKeyPath:@"info.haveRearCamera"];
    if (self.live) [self.live removeObserver:self forKeyPath:@"liveWHRatio"];
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"isConnected"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            APKDVR *dvr = [APKDVR sharedInstance];
            self.liveContentView.hidden = !dvr.isConnected;
        });
        
    }else if ([keyPath isEqualToString:@"info.haveRearCamera"]){
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            BOOL haveRearCamera = [change[@"new"] boolValue];
//            self.switchCameraButton.hidden = !haveRearCamera;
//        });
    }else if ([keyPath isEqualToString:@"liveWHRatio"]){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            float ratio = [change[@"new"] floatValue];
            CGFloat videoViewWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
            CGFloat videoViewHeight = videoViewWidth / ratio;
            self.videoViewHeightConstraint.constant = videoViewHeight;
        });
    }
}

#pragma mark - actions

- (IBAction)switchCamera:(UIButton *)sender {
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected) {
        [APKAlertTool showAlertInViewController:self message:NSLocalizedString(@"未连接DVR！", nil)];
        return;
    }
    
    KWEAKSELF;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        __weak typeof(self)weakSelf = self;
        if (weakSelf.isFontCamera) {
            
            [weakSelf.taskTool setRearCamera:^(BOOL success) {
                
                [hud hideAnimated:YES];
                if (success) {
                    weakSelf.isFontCamera = NO;
                    [APKDVR sharedInstance].info.isFrontCamera = NO;
                    [weakSelf showHUDWithMessage:NSLocalizedString(@"切换镜头成功！", nil) duration:1.f];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5/*延迟执行时间*/ * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf.live startLive];
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
                    [APKDVR sharedInstance].info.isFrontCamera = YES;
                    [weakSelf showHUDWithMessage:NSLocalizedString(@"切换镜头成功！", nil) duration:1.f];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5/*延迟执行时间*/ * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf.live startLive];
                    });
                    [self.switchCameraButton setImage:[UIImage imageNamed:@"icon-26"] forState:UIControlStateNormal];

                    
                }else{
                    [APKAlertTool showAlertInViewController:weakSelf message:NSLocalizedString(@"切换镜头失败！", nil)];
                }
            }];
        }
}

- (IBAction)splitScreenButtonAction:(UIButton *)sender {
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected) {
        [APKAlertTool showAlertInViewController:self message:NSLocalizedString(@"未连接DVR！", nil)];
        return;
    }
    
    [self.taskTool getParkingModeInfo:^(BOOL success) {
        
        NSString *parkingModeInfo = [APKDVR sharedInstance].info.parkingModeInfo;
        NSString *parkMode = [parkingModeInfo substringToIndex:1];
        if ([parkMode isEqualToString:@"1"]){
            
            [APKAlertTool showAlertInViewController:self message:NSLocalizedString(@"停车模式中无法修改设置，请手动退出", nil)];
            return;
        }
        [self.backgroundView addSubview:self.splitScreenView];
        
        __weak typeof(self)weakSelf = self;
        self.splitScreenView.clickSpitButton = ^(NSInteger btnTag) {
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
            switch (btnTag) {
                case 103:
                {
                    [weakSelf.taskTool setRearCamera:^(BOOL success) {
                        
                        [hud hideAnimated:YES];
                        if (success) {
                            weakSelf.isFontCamera = NO;
                            [weakSelf showHUDWithMessage:NSLocalizedString(@"切换镜头成功！", nil) duration:1.f];
                            
                            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
                            
                            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                                [weakSelf.live startLive];
                            });
                        }else{
                            [APKAlertTool showAlertInViewController:weakSelf message:NSLocalizedString(@"切换镜头失败！", nil)];
                        }
                    }];
                    break;}
                case 102:
                {
                    [weakSelf.taskTool setFontCamera:^(BOOL success) {
                        
                        [hud hideAnimated:YES];
                        if (success) {
                            weakSelf.isFontCamera = YES;
                            [weakSelf showHUDWithMessage:NSLocalizedString(@"切换镜头成功！", nil) duration:1.f];
                        }else{
                            [APKAlertTool showAlertInViewController:weakSelf message:NSLocalizedString(@"切换镜头失败！", nil)];
                        }
                    }];
                    break;}
                default:
                    [APKAlertTool showAlertInViewController:weakSelf message:NSLocalizedString(@"切换镜头失败！", nil)];
                    [hud hideAnimated:YES];
                    break;
            }
        };
    }];
    

}

- (IBAction)clickEvSettingButtonAction:(UIButton *)sender {
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected) {
        [APKAlertTool showAlertInViewController:self message:NSLocalizedString(@"未连接DVR！", nil)];
        return;
    }
    
    [self.taskTool getParkingModeInfo:^(BOOL success) {
        
        NSString *parkingModeInfo = [APKDVR sharedInstance].info.parkingModeInfo;
        NSString *parkMode = [parkingModeInfo substringToIndex:1];
        if ([parkMode isEqualToString:@"1"]){
            
            [APKAlertTool showAlertInViewController:self message:NSLocalizedString(@"停车模式中无法修改设置，请手动退出", nil)];
            return;
        }
        [self.backgroundView addSubview:self.EvSettingView];
        [self.EvSettingView refleshSliderValue];
    }];
    

}


- (IBAction)recordVoiceButtonAction:(UIButton *)sender {
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected) {
        [APKAlertTool showAlertInViewController:self message:NSLocalizedString(@"未连接DVR！", nil)];
        return;
    }
    
    [self.taskTool getParkingModeInfo:^(BOOL success) {
        
        NSString *parkingModeInfo = [APKDVR sharedInstance].info.parkingModeInfo;
        NSString *parkMode = [parkingModeInfo substringToIndex:1];
        if ([parkMode isEqualToString:@"1"]){
            
            [APKAlertTool showAlertInViewController:self message:NSLocalizedString(@"停车模式中无法修改设置，请手动退出", nil)];
            return;
        }
        
        sender.selected = !sender.selected;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
        hud.label.text = NSLocalizedString(@"设置正在更新中", nil);
        __weak typeof(self)weakSelf = self;
        NSArray *setArray = @[@"mute",@"unmute"];
        NSString *property = @"Video";
        NSString *value = setArray[sender.selected];
        [self.taskTool setDVRWithProperty:property value:value completionHandler:^(BOOL success) {
            
            [hud hideAnimated:YES];
            if (success == YES) {
                [APKAlertTool showAlertInViewController:weakSelf message:NSLocalizedString(@"设置成功！", nil)];
                
                APKDVRInfo *info = [APKDVR sharedInstance].info;
                if (sender.selected) {
                    info.recordSound = 1;
                }else
                {
                    info.recordSound = 0;
                }
            }else{
                [APKAlertTool showAlertInViewController:weakSelf message:NSLocalizedString(@"设置失败！", nil)];
                sender.selected = !sender.selected;
            }
        }];
            
    }];
}

- (IBAction)recordEvent:(UIButton *)sender {
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected) {
        [APKAlertTool showAlertInViewController:self message:NSLocalizedString(@"未连接DVR！", nil)];
        return;
    }
    
    [self.taskTool getParkingModeInfo:^(BOOL success) {
        
        NSString *parkingModeInfo = [APKDVR sharedInstance].info.parkingModeInfo;
        NSString *parkMode = [parkingModeInfo substringToIndex:1];
        NSString *urgencyVideo = [parkingModeInfo substringFromIndex:1];
        if ([parkMode isEqualToString:@"1"]){
            
            [APKAlertTool showAlertInViewController:self message:NSLocalizedString(@"停车模式中无法修改设置，请手动退出", nil)];
            return;
        }
        if ([urgencyVideo isEqualToString:@"1"]){
            [APKAlertTool showAlertInViewController:self message:NSLocalizedString(@"正在紧急录像中", nil)];
            return;
        }
        
        sender.enabled = NO;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        __weak typeof(self)weakSelf = self;
        [self.taskTool recordEvent:^(BOOL success) {
            
            [hud hideAnimated:YES];
            
            if (!success) {
                [APKAlertTool showAlertInViewController:weakSelf message:NSLocalizedString(@"录制事件失败！", nil)];
            }else{
                [weakSelf showHUDWithMessage:NSLocalizedString(@"录制事件成功！", nil) duration:1.f];
            }
            sender.enabled = YES;
        }];
           
    }];
}

- (IBAction)capture:(UIButton *)sender {
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected) {
        [APKAlertTool showAlertInViewController:self message:NSLocalizedString(@"未连接DVR！", nil)];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self)weakSelf = self;
    [self.taskTool takePhoto:^(BOOL success) {
        
        [hud hideAnimated:YES];
        
        if (!success) {
            [APKAlertTool showAlertInViewController:weakSelf message:NSLocalizedString(@"拍摄照片失败！", nil)];
        }else{
            [weakSelf showHUDWithMessage:NSLocalizedString(@"拍摄照片成功！", nil) duration:1.f];
        }
    }];
}

#pragma mark - Utilities
- (void)showHUDWithMessage:(NSString *)message duration:(CGFloat)duration{
    
    MBProgressHUD *successHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    successHUD.mode = MBProgressHUDModeText;
    successHUD.userInteractionEnabled = NO;
    successHUD.label.text = message;
    [successHUD hideAnimated:YES afterDelay:duration];
}

#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"fullScreen"]) {
        
        APKLiveViewController *liveVC = segue.destinationViewController;
        liveVC.isFullScreenMode = YES;
    }
}

#pragma mark -  getter

- (APKCommonTaskTool *)taskTool{
    
    if (!_taskTool) {
        _taskTool = [[APKCommonTaskTool alloc] init];
    }
    return _taskTool;
}

-(APKSplitScreenView *)splitScreenView
{
    if (!_splitScreenView) {
        _splitScreenView = [[NSBundle mainBundle] loadNibNamed:@"APKSplitScreenView" owner:nil options:nil].firstObject;;
        _splitScreenView.frame = self.backgroundView.bounds;
        //        _splitScreenView.frame = CGRectMake(CGRectGetMinX(self.backgroundView.frame), CGRectGetMinY(self.backgroundView.frame), self.view.bounds.size.width, CGRectGetHeight(self.backgroundView.frame));
    }
    return _splitScreenView;
}

-(previewSettingView *)EvSettingView
{
    if (!_EvSettingView) {
        _EvSettingView = [[NSBundle mainBundle] loadNibNamed:@"previewSettingView" owner:nil options:nil].firstObject;
        _EvSettingView.frame = self.backgroundView.bounds;
        _EvSettingView.showInVC = self;
    }
    return _EvSettingView;
}

@end
