//
//  APKLiveView.m
//  DvrAss
//
//  Created by 李福池 on 2018/5/28.
//  Copyright © 2018年 APK. All rights reserved.
//

#import "APKLiveView.h"

@implementation APKLiveView

#pragma mark - private method


#pragma mark - KVO


- (void)loadLiveUI{
    
    self.maskView.hidden = NO;
    self.playButton.hidden = YES;
    self.flower.hidden = NO;
    if (![self.flower isAnimating]) {
        [self.flower startAnimating];
    }
}

- (void)showLiveUI{
    
    [self.flower stopAnimating];
    self.flower.hidden = YES;
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
    if (self.flower.isAnimating) {
        [self.flower stopAnimating];
        self.flower.hidden = YES;
    }
}

#pragma mark - public method

- (void)startLive{
    
    self.state = APKLiveStateUpdate;
    [self loadLiveUI];
    if (self.mediaPlayer.state != VLCMediaPlayerStateStopped) {//重新播放rtsp URL
        
        self.isStopedForAnotherLive = YES;
        [self.mediaPlayer stop];
        return;
    }
    
    self.timeCount = 0;
    VLCMedia *media = [VLCMedia mediaWithURL:self.url];
    [self.mediaPlayer setMedia:media];
    [self.mediaPlayer play];
    
}

- (void)stopLive{
    
    [self.mediaPlayer pause];
}

#pragma mark - VLCMediaPlayerDelegate

- (void)mediaPlayerStateChanged:(NSNotification *)aNotification{
    
    switch (self.mediaPlayer.state) {
        case VLCMediaPlayerStateEnded:
            NSLog(@"视频错误🙅‍♂️🙅‍♂️！！！");
        case VLCMediaPlayerStateStopped:

        case VLCMediaPlayerStateError:
            
            if (self.mediaPlayer.state == VLCMediaPlayerStateStopped && self.isStopedForAnotherLive) {
                self.isStopedForAnotherLive = NO;
                [self startLive];
            }
            else{
                self.state = APKLiveStateStop;
                [self noLiveUI];
            }
            break;
        case VLCMediaPlayerStatePlaying:
            //            NSLog(@"❌❌❌VLCMediaPlayerStatePlaying");
            //            self.state = APKLiveStatePlaying;
            break;
        case VLCMediaPlayerStateBuffering://缓冲状态
            if (self.state == APKLiveStateUpdate) {
                self.state = APKLiveStatePlay;
            }
            //            NSLog(@"😊😊😊VLCMediaPlayerStateBuffering");
            break;
        case VLCMediaPlayerStateOpening:
            //            NSLog(@"✅✅✅VLCMediaPlayerStateOpening");
            break;
        default:
            break;
    }
}

//播放时长
- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification{
    
    if (self.timeCount == 2){
        [self showLiveUI];
    }
    
    if (self.timeCount < 3) {
        self.timeCount += 1;
    }

}

#pragma mark - event response

- (IBAction)play:(UIButton *)sender {
    
    [self startLive];
}


#pragma mark - getter

- (VLCMediaPlayer *)mediaPlayer{
    
    if (!_mediaPlayer) {
        
        //安卓的缓冲参数是600
        NSString *caching = [NSString stringWithFormat:@"--network-caching=%d",400];
        NSString *jitter = [NSString stringWithFormat:@"--clock-jitter=%d",400];
        NSArray *options = @[caching,jitter,@"--extraintf=",@"--gain=0"];
//        UIViewController *content = [self.childViewControllers firstObject];
        _mediaPlayer = [[VLCMediaPlayer alloc] initWithOptions:options];
        _mediaPlayer.delegate = self;
        _mediaPlayer.drawable = self;
    }
    
    return _mediaPlayer;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
