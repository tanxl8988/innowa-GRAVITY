//
//  APKLiveView.h
//  DvrAss
//
//  Created by 李福池 on 2018/5/28.
//  Copyright © 2018年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobileVLCKit/VLCMediaPlayer.h"
@interface APKLiveView : UIView<VLCMediaPlayerDelegate>

typedef enum : NSUInteger {
    APKLiveStateStop,
    APKLiveStateUpdate,
    APKLiveStatePlay,
} APKLiveState;

@property (weak, nonatomic) IBOutlet UIButton *quitButton;
@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (nonatomic,getter=isFullScreenMode) BOOL fullScreenMode;
@property (nonatomic) APKLiveState state;
@property (strong,nonatomic) NSURL *url;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *flower;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak,nonatomic) UIView *liveView;
@property (strong,nonatomic) VLCMediaPlayer *mediaPlayer;
@property (assign) NSInteger timeCount;
@property (nonatomic) BOOL isStopedForAnotherLive;
@property (nonatomic,copy) void (^twoTapAction)(id value);
@property (nonatomic,assign) BOOL isFullScreen;
@property (nonatomic,assign) CGRect previousRect;

- (void)startLive;
- (void)stopLive;
@end
