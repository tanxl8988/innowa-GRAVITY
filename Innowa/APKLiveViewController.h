//
//  APKLiveViewController.h
//  万能AIT
//
//  Created by Mac on 17/3/21.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol APKLiveViewControllerDelegate <NSObject>

- (void)clickSwitchCameraButtonAction;

@end

@interface APKLiveViewController : UIViewController

@property (nonatomic) BOOL isFullScreenMode;
@property (nonatomic) float liveWHRatio;
@property (nonatomic, assign) id<APKLiveViewControllerDelegate> delegate;
@property (nonatomic,copy) void (^clickSwitchCameraButtonAvtion)();
@property (nonatomic,assign) BOOL isFontCamera;

-(void)startLive;

@end
