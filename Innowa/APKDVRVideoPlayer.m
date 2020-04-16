//
//  APKDVRVideoPlayer.m
//  Innowa
//
//  Created by 李福池 on 2018/6/25.
//  Copyright © 2018年 APK. All rights reserved.
//

#import "APKDVRVideoPlayer.h"
#import "APKAlertTool.h"
#import "APKShareTool.h"
#import "MBProgressHUD.h"
#import "APKDownloadInfoView.h"
#import "APKDVRVideoPlayerCell.h"

@implementation APKPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

@end

@implementation APKPlayerLocalItem


@end

typedef enum : NSUInteger {
    APKVideoPlayerResourceTypeLocal,
    APKVideoPlayerResourceTypeDvr,
} APKPlayerResourceType;

static int AAPLPlayerViewControllerKVOContext = 0;

@interface APKDVRVideoPlayer ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *toolView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet APKPlayerView *playerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *flower;
@property (weak, nonatomic) IBOutlet UIView *localToolsBar;
@property (weak, nonatomic) IBOutlet UIView *dvrToolsBar;
@property (weak, nonatomic) IBOutlet UIButton *localShareButton;
@property (weak, nonatomic) IBOutlet UIButton *localCollectButton;
@property (weak, nonatomic) IBOutlet UIButton *localDeleteButton;
@property (weak, nonatomic) IBOutlet UIButton *dvrDownloadButton;
@property (weak, nonatomic) IBOutlet UIButton *dvrDeleteButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *currentIndexL;

@property (assign) APKPlayerResourceType resourceType;
@property (nonatomic ,strong) AVPlayer *player;
@property (strong,nonatomic) NSArray *nameArray;
@property (strong,nonatomic) id<NSObject> timeObserverToken;
@property (nonatomic) NSInteger currentIndex;
@property (strong,nonatomic) NSArray<NSURL *> *urlArray;
@property (nonatomic ,strong) AVAsset *avAsset;
@property (nonatomic ,strong) PHAsset *phAsset;
@property (strong,nonatomic) NSArray <PHAsset *>*assetArray;
@property (assign) BOOL isPausing;

@property (strong,nonatomic) NSMutableArray *items;
@property (weak,nonatomic) id<APKPlayerDelegate>delegate;
@property (strong,nonatomic) APKDownloadDVRFileTool *downloadTool;
@property (strong,nonatomic) APKDeleteDVRFileTool *deleteTool;
@property (assign) BOOL isAllScreenState;
@property (nonatomic,assign) CGRect previosPlayViewFrame;
@property (nonatomic,retain) UIScrollView *backSC;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (nonatomic,assign) BOOL isHide;

@end

@implementation APKDVRVideoPlayer

#pragma mark - life circle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"videoPlayer_sliderBar"] forState:UIControlStateNormal];
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"videoPlayer_sliderBar"] forState:UIControlStateSelected];
    
    if (self.resourceType == APKVideoPlayerResourceTypeDvr) {
        
        self.localToolsBar.hidden = YES;
    }
    else{
        
        self.dvrToolsBar.hidden = YES;
    }
    
    [self addObserver:self forKeyPath:@"player.currentItem.duration" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&AAPLPlayerViewControllerKVOContext];
    [self addObserver:self forKeyPath:@"player.currentItem.loadedTimeRanges" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&AAPLPlayerViewControllerKVOContext];
    [self addObserver:self forKeyPath:@"player.rate" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&AAPLPlayerViewControllerKVOContext];
    [self addObserver:self forKeyPath:@"player.currentItem.status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&AAPLPlayerViewControllerKVOContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    self.playerView.player = self.player;
    APKDVRVideoPlayer __weak *weakSelf = self;
    self.timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:
                              ^(CMTime time) {
                                  
                                  double seconds = CMTimeGetSeconds(time);
                                  //                              NSLog(@"%f",seconds);
                                  weakSelf.progressSlider.value = seconds;
                                  weakSelf.progressLabel.text = [weakSelf formatTimeWithSeconds:seconds];
                              }];
    
    
    [self updateUIWithCurrentIndex];
    [self loadAsset];
    
    self.currentIndexL.text = [NSString stringWithFormat:@"%ld/%ld",self.currentIndex + 1,self.items.count];
    
    self.tableView.tableFooterView = [UIView new];
    
    self.previosPlayViewFrame = self.playerView.frame;
    
    
    [self.playerView removeFromSuperview];
    UIScrollView *backSC = [[UIScrollView alloc] initWithFrame:self.playerView.frame];
    self.playerView.frame = backSC.bounds;
    [backSC addSubview:self.playerView];
    backSC.maximumZoomScale = 2.0;
    backSC.minimumZoomScale = 1.0;
    backSC.delegate = self;
    backSC.backgroundColor = [UIColor blackColor];
    [self.view addSubview:backSC];
    self.backSC = backSC;
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    [self.playerView addGestureRecognizer:singleTapGestureRecognizer];
    [self showOrHidePlayViewSubview:NO];
}

-(void)showOrHidePlayViewSubview:(BOOL)isHide
{
    self.nextButton.hidden = isHide;
    self.previousButton.hidden = isHide;
    self.progressLabel.hidden = isHide;
    self.durationLabel.hidden = isHide;
    self.progressSlider.hidden = isHide;
    self.playButton.hidden = isHide;
    self.pauseButton.hidden = isHide;
    
    if (isHide == NO) {
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            
            [self showOrHidePlayViewSubview:!isHide];
            self.isHide = !self.isHide;
        });
    }
}

- (void)singleTap:(UIGestureRecognizer*)gestureRecognizer

{
    self.isHide = !self.isHide;
    [self showOrHidePlayViewSubview:self.isHide];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
//    return self.playerView;
    return  nil;
}

- (void)dealloc {
    
    NSLog(@"%s",__func__);
    
    if (self.timeObserverToken) {
        
        [self.player removeTimeObserver:self.timeObserverToken];
        self.timeObserverToken = nil;
    }
    [self.player pause];
    
    [self removeObserver:self forKeyPath:@"player.currentItem.duration" context:&AAPLPlayerViewControllerKVOContext];
    [self removeObserver:self forKeyPath:@"player.currentItem.loadedTimeRanges" context:&AAPLPlayerViewControllerKVOContext];
    [self removeObserver:self forKeyPath:@"player.rate" context:&AAPLPlayerViewControllerKVOContext];
    [self removeObserver:self forKeyPath:@"player.currentItem.status" context:&AAPLPlayerViewControllerKVOContext];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context != &AAPLPlayerViewControllerKVOContext) {
        // KVO isn't for us.
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([keyPath isEqualToString:@"player.currentItem.duration"]) {
        
        //        NSLog(@"player.currentItem.duration");
        
        NSValue *newDurationAsValue = change[NSKeyValueChangeNewKey];
        CMTime newDuration = [newDurationAsValue isKindOfClass:[NSValue class]] ? newDurationAsValue.CMTimeValue : kCMTimeZero;
        BOOL hasValidDuration = CMTIME_IS_NUMERIC(newDuration) && newDuration.value != 0;
        double newDurationSeconds = hasValidDuration ? CMTimeGetSeconds(newDuration) : 0.0;
        
        self.progressSlider.maximumValue = newDurationSeconds;
        self.progressSlider.value = hasValidDuration ? CMTimeGetSeconds(self.player.currentTime) : 0.0;
        self.playButton.enabled = hasValidDuration;
        self.pauseButton.enabled = hasValidDuration;
        self.durationLabel.text = [self formatTimeWithSeconds:newDurationSeconds];
    }
    else if ([keyPath isEqualToString:@"player.rate"]) {
        
        double newRate = [change[NSKeyValueChangeNewKey] doubleValue];
        //        NSLog(@"play rate : %f",newRate);
        [self updateUIWithPlayerRate:newRate];
        
    }
    else if ([keyPath isEqualToString:@"player.currentItem.status"]) {
        
        NSNumber *newStatusAsNumber = change[NSKeyValueChangeNewKey];
        AVPlayerItemStatus newStatus = [newStatusAsNumber isKindOfClass:[NSNumber class]] ? newStatusAsNumber.integerValue : AVPlayerItemStatusUnknown;
        
        if (newStatus == AVPlayerItemStatusFailed) {
            //           NSLog(@"AVPlayerItemStatusFailed");
        }else if (newStatus == AVPlayerItemStatusReadyToPlay){
            //            NSLog(@"AVPlayerItemStatusReadyToPlay");
            [self play:self.playButton];
        }else{
            //            NSLog(@"AVPlayerItemStatusUnknown");
        }
    }
    else if ([keyPath isEqualToString:@"player.currentItem.loadedTimeRanges"]) {
        
        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
        //        NSLog(@"已缓存时长 : %f",timeInterval);
        
        if (self.player.rate == 0.f && !self.isPausing) {
            if (CMTimeGetSeconds(self.player.currentTime) < timeInterval) {
                
                [self.player play];
            }
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - private method

- (NSString *)formatTimeWithSeconds:(double)seconds{
    
    int wholeMinutes = (int)trunc(seconds / 60);
    int wholdSeconds = (int)trunc(seconds) - wholeMinutes * 60;
    NSString *formatTime = [NSString stringWithFormat:@"%d:%02d", wholeMinutes, wholdSeconds];
    return formatTime;
}

//返回 当前 视频 缓存时长
- (NSTimeInterval)availableDuration{
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    
    return result;
}

- (void)handlePlayToEndTimeNotification:(NSNotification *)notification{
    
    //    NSLog(@"%@",notification.name);
    __weak typeof(self)weakSelf = self;
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        
        if (finished) {
            [weakSelf.flower stopAnimating];
            [weakSelf pause:weakSelf.pauseButton];
        }
    }];
}

- (void)loadPHAsset:(PHAsset *)asset{
    
    [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (asset != self.phAsset) {
                return;
            }
            [self.player replaceCurrentItemWithPlayerItem:playerItem];
        });
    }];
}

- (void)loadAVAsset:(AVAsset *)asset{
    
    NSArray *loadKeys = @[@"playable",@"hasProtectedContent"];
    [asset loadValuesAsynchronouslyForKeys:loadKeys completionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (asset != self.avAsset) {
                return;
            }
            
            //判断是否加载keys成功
            for (NSString *key in loadKeys) {
                NSError *error = nil;
                if ([asset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed) {
                    
                    NSString *message = NSLocalizedString(@"加载视频失败！", nil);
                    [APKAlertTool showAlertInViewController:self message:message];
                    return;
                }
            }
            
            //判断是否可以播放该asset
            if (!asset.playable || asset.hasProtectedContent) {
                
                NSString *message = NSLocalizedString(@"该视频不可播放！", nil);
                [APKAlertTool showAlertInViewController:self message:message];
                return;
            }
            
            //可以播放该asset
            AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
            [self.player replaceCurrentItemWithPlayerItem:item];
        });
    }];
}

- (void)loadAsset{
    
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.isPausing = NO;
    [self.player pause];
    
    if (self.resourceType == APKVideoPlayerResourceTypeDvr) {
        
        APKDVRFile *file = self.items[self.currentIndex];
        NSURL *url = [NSURL URLWithString:file.fileDownloadPath];
        AVURLAsset *asset = [AVURLAsset assetWithURL:url];
        self.avAsset = asset;
        [self loadAVAsset:asset];
        
    }else if(self.resourceType == APKVideoPlayerResourceTypeLocal){
        
        APKPlayerLocalItem *item = self.items[self.currentIndex];
        PHAsset *asset = item.asset;
        self.phAsset = asset;
        [self loadPHAsset:asset];
    }

    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    NSIndexPath *path = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)updateUIWithPlayerRate:(double)rate{
    
    if (rate == 1.0) {
        self.pauseButton.hidden = NO;
        self.playButton.hidden = YES;
        self.pauseButton.enabled = YES;
        [self.flower stopAnimating];
    }else{
        self.pauseButton.hidden = YES;
        self.playButton.hidden = NO;
        self.playButton.enabled = YES;
        if (!self.isPausing) {
            [self.flower startAnimating];
        }
    }
}

- (void)updateUIWithCurrentIndex{
    
    if (self.resourceType == APKVideoPlayerResourceTypeLocal) {
        
        APKPlayerLocalItem *item = self.items[self.currentIndex];
        self.titleLabel.text = item.file.name;
        
        self.localCollectButton.selected = item.file.isCollected;
    }
    else if (self.resourceType == APKVideoPlayerResourceTypeDvr){
        
        APKDVRFile *file = self.items[self.currentIndex];
        self.titleLabel.text = file.name;
        
        self.dvrDownloadButton.enabled = !file.isDownloaded;
    }
    
    NSInteger numberOfItems = self.items.count;
    self.previousButton.enabled = self.currentIndex == 0 ? NO : YES;
    self.nextButton.enabled = self.currentIndex == (numberOfItems - 1) ? NO : YES;
    
    self.currentIndexL.text = [NSString stringWithFormat:@"%ld/%ld",self.currentIndex + 1,self.items.count];
}

#pragma mark - public method

- (void)setupWithDvrItems:(NSArray<APKDVRFile *> *)dvrItems delegate:(id<APKPlayerDelegate>)delegate downloadTool:(APKDownloadDVRFileTool *)downloadTool deleteTool:(APKDeleteDVRFileTool *)deleteTool currentIndex:(NSInteger)currentIndex{
    
    [self.items addObjectsFromArray:dvrItems];
    self.delegate = delegate;
    self.currentIndex = currentIndex;
    self.downloadTool = downloadTool;
    self.deleteTool = deleteTool;
    
    self.resourceType = APKVideoPlayerResourceTypeDvr;
}

- (void)setupWithLocalItems:(NSArray<APKPlayerLocalItem *> *)localItems currentIndex:(NSInteger)currentIndex{
    
    [self.items setArray:localItems];
    self.currentIndex = currentIndex;
    
    self.resourceType = APKVideoPlayerResourceTypeLocal;
}

#pragma mark - action

- (IBAction)updateToolView:(UITapGestureRecognizer *)sender {
    
    self.toolView.hidden = !self.toolView.hidden;
}

- (IBAction)progressSliderTouchFinished:(UISlider *)sender {
    
    [self play:self.playButton];
}

- (IBAction)progressSliderValueChanged:(UISlider *)sender {
    
    double currentTime = sender.value;
    CMTimeScale scale = self.player.currentTime.timescale;
    CMTime time = CMTimeMake(scale * currentTime, scale);
    [self.player seekToTime:time completionHandler:^(BOOL finished) {
        
        //        if (finished) {
        //            NSLog(@"seek time finish == YES");
        //        }else{
        //            NSLog(@"seek time finish == NO");
        //        }
    }];
    
    self.progressLabel.text = [self formatTimeWithSeconds:sender.value];
}

- (IBAction)progressSliderTouchDown:(UISlider *)sender {
    
    [self pause:self.pauseButton];
}

- (IBAction)play:(UIButton *)sender {
    
    self.isPausing = NO;
    [self.player play];
}

- (IBAction)pause:(UIButton *)sender {
    
    self.isPausing = YES;
    [self.player pause];
}

- (IBAction)chengePlayItemWithSender:(UIButton *)sender {
    
    if (sender == self.previousButton) {
        self.currentIndex -= 1;
    }else if(sender == self.nextButton){
        self.currentIndex += 1;
    }
    [self updateUIWithCurrentIndex];
    
    [self loadAsset];
}

- (IBAction)quit {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark tools bar

- (IBAction)clickDvrDownloadButton:(UIButton *)sender {
    
    [self pause:self.pauseButton];
    
    __weak typeof(self)weakSelf = self;
    APKDownloadInfoView *downloadInfoView = [[NSBundle mainBundle] loadNibNamed:@"APKDownloadInfoView" owner:self options:nil].firstObject;
    [downloadInfoView showInView:self.view cancelHandler:^{
        
        [weakSelf.downloadTool cancelDownloadTask];
    }];
    
    APKDVRFile *file = self.items[self.currentIndex];
    [self.downloadTool addDownloadTask:@[file] isCollected:NO isRearCameraFile:file.isRearCameraFile updateHandler:^(APKDVRFile *targetFile) {
        
        downloadInfoView.downloadInfoLabel.text = file.name;
        
    } progressHandler:^(float progress, NSString *progressMsg) {
        
        downloadInfoView.progressView.progress = progress;
        NSString *progressInfo = [NSString stringWithFormat:@"%.1f%%",progress * 100.f];
        downloadInfoView.progressLabel.text = progressInfo;
        downloadInfoView.progressLabel2.text = progressMsg;
        
    } completionHandler:^(NSArray *failureTaskArray) {
        
        [downloadInfoView dismiss];
        
        if (failureTaskArray.count == 0) {
            
            weakSelf.dvrDownloadButton.enabled = NO;
            
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(APKVideoPlayer:didDownloadFile:)]) {
                
                [weakSelf.delegate APKVideoPlayer:weakSelf didDownloadFile:file];
            }
        }
    }];
}

- (IBAction)clickSwitchCameraButton:(UIButton *)sender {
    
    NSInteger index = self.tableView.indexPathForSelectedRow.row;
    APKDVRFile *file = self.items[index];
    APKDVRFile *lastFile = index == 0 ? file : self.items[index - 1];
    APKDVRFile *nextFile = index == self.items.count - 1 ? file : self.items[index + 1];
    if ([lastFile.date compare:file.date] == NSOrderedSame && lastFile != file){
        
        self.currentIndex--;
        [self loadAsset];
        [self updateUIWithCurrentIndex];
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index-1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    else if ([nextFile.date compare:file.date] == NSOrderedSame && nextFile != file){
        
        self.currentIndex++;
        [self loadAsset];
        [self updateUIWithCurrentIndex];
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index+1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    else
        [APKAlertTool showAlertInViewController:self message:NSLocalizedString(@"没有文件", nil)];
}


- (IBAction)clickAllScreenButton:(UIButton *)sender {
    
    _isAllScreenState = !_isAllScreenState;
    if (_isAllScreenState) {
        CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
        self.backSC.frame = CGRectMake(screenWidth / 2.f - screenHeight / 2.f, screenHeight / 2.f - screenWidth / 2.f, screenHeight, screenWidth);
        self.backSC.transform = CGAffineTransformMakeRotation(M_PI/2);
        [self.view bringSubviewToFront:self.backSC];
        self.deleteButton.hidden = NO;
        self.downloadButton.hidden = NO;
    }
    else
    {
        self.backSC.transform = CGAffineTransformIdentity;
        self.backSC.frame = self.previosPlayViewFrame;
        [self.view sendSubviewToBack:self.backSC];
        self.deleteButton.hidden = YES;
        self.downloadButton.hidden = YES;
    }
}

- (IBAction)clickDvrDeleteButton:(UIButton *)sender {
    
    __weak typeof(self)weakSelf = self;
    __block APKDVRFile *file = self.items[self.currentIndex];
    
    NSMutableArray *fileArr = [NSMutableArray arrayWithObject:file];

    if (self.items.count > 1){
        
        APKDVRFile *frontFile = self.currentIndex == 0 ? nil : self.items[self.currentIndex - 1];
        APKDVRFile *nextFile = self.currentIndex == self.items.count - 1 ? nil : self.items[self.currentIndex + 1];
        if (frontFile != nil && [frontFile.date compare:file.date] == NSOrderedSame)
            [fileArr addObject:frontFile];
        if (nextFile != nil && [nextFile.date compare:file.date] == NSOrderedSame)
            [fileArr addObject:nextFile];
    }
    
    BOOL haveLockFile = NO;
    __block NSMutableArray *deleteFileArr = [NSMutableArray array];
    for (APKDVRFile *file in fileArr) {
        
        if ([file.attr isEqualToString:@"RW"])
            [deleteFileArr addObject:file];
        else
            haveLockFile = YES;
    }
    
    void (^confirmHandler)(UIAlertAction *action)  = ^(UIAlertAction *action){
        
        [self pause:self.pauseButton];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [self.deleteTool deleteWithFileArray:deleteFileArr completionHandler:^(NSArray *failureTaskArray) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [hud hideAnimated:YES];
                
                if (failureTaskArray.count > 0) {
                    
                    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"%d个文件删除失败！", nil),(int)failureTaskArray.count];
                    [APKAlertTool showAlertInViewController:weakSelf message:message];
                }
                else{
                    
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(APKVideoPlayer:deleteFileArr:)]) {
                        
                        [weakSelf.delegate APKVideoPlayer:weakSelf deleteFileArr:deleteFileArr];
                        
                    }
                    
                    [weakSelf.items removeObjectAtIndex:weakSelf.currentIndex];
                    [self.tableView reloadData];
                    if (weakSelf.items.count == 0) {
                        
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    }
                    else{
                        
                        if (weakSelf.currentIndex >= weakSelf.items.count) {
                            
                            weakSelf.currentIndex--;
                        }
                        
                        [weakSelf updateUIWithCurrentIndex];
                        [weakSelf loadAsset];
                    }
                }
            });
        }];
    };
    
    if (haveLockFile == YES) {
        
        if (deleteFileArr.count == 0) {
            [APKAlertTool showAlertInViewController:self message:NSLocalizedString(@"請先在記錄儀內解除保護檔案", nil)];
            return;
        }
    }
    
    if (deleteFileArr.count == 0) return;
    
    if (haveLockFile == YES) {
        
        [APKAlertTool showAlertInViewController:self title:nil message:NSLocalizedString(@"請先在記錄儀內解除保護檔案", nil) handler:^(UIAlertAction *action) {
            
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"删除%d个文件？", nil),(int)deleteFileArr.count];
            [APKAlertTool showAlertInViewController:self title:nil message:message handler:confirmHandler];
        }];
    }else{
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"删除%d个文件？", nil),(int)deleteFileArr.count];
        [APKAlertTool showAlertInViewController:self title:nil message:message handler:confirmHandler];
    }
    [self pause:self.pauseButton];
}

#pragma mark - UITableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    APKDVRVideoPlayerCell *vidioPlayerCell = [tableView dequeueReusableCellWithIdentifier:@"APKDVRVideoPlayerCell" forIndexPath:indexPath];
    APKDVRFile *file = self.items[indexPath.row];
    vidioPlayerCell.nameL.text = file.name;
    vidioPlayerCell.selectionStyle = UITableViewCellSelectionStyleDefault;
    vidioPlayerCell.selectedBackgroundView = [UIView new];
    vidioPlayerCell.selectedBackgroundView.backgroundColor = [UIColor brownColor];
    
    return vidioPlayerCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentIndex = indexPath.row;
    
    [self updateUIWithCurrentIndex];
                         
    [self loadAsset];
}

#pragma mark - system

- (BOOL)prefersStatusBarHidden{
    
    return YES;
}

#pragma mark - getter

- (NSMutableArray *)items{
    
    if (!_items) {
        
        _items = [[NSMutableArray alloc] init];
    }
    return _items;
}

- (AVPlayer *)player{
    
    if (!_player) {
        _player = [[AVPlayer alloc] init];
    }
    return _player;
}

@end




