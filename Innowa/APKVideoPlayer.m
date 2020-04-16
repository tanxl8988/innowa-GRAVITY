//
//  APKLocalVideoPlayerVC.m
//  第三版云智汇
//
//  Created by Mac on 16/8/10.
//  Copyright © 2016年 APK. All rights reserved.
//

#import "APKVideoPlayer.h"
#import "APKAlertTool.h"
#import "APKShareTool.h"
#import "MBProgressHUD.h"
#import "APKDownloadInfoView.h"
#import <MapKit/MapKit.h>
#import "APKLocalVidioEditTool.h"
#import "APKCachingThumbnailTool.h"
#import "APKLocalVidioCutViewController.h"
#import "APKHandleGpsInfoTool.h"

@implementation APKAVPlayerView

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

@implementation APKVideoPlayerLocalItem


@end

typedef enum : NSUInteger {
    APKVideoPlayerResourceTypeLocal,
    APKVideoPlayerResourceTypeDvr,
} APKVideoPlayerResourceType;

static int AAPLPlayerViewControllerKVOContext = 0;

@interface APKVideoPlayer ()<MKMapViewDelegate, CLLocationManagerDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *toolView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet APKAVPlayerView *playerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *flower;
@property (weak, nonatomic) IBOutlet UIView *localToolsBar;
@property (weak, nonatomic) IBOutlet UIView *dvrToolsBar;
@property (weak, nonatomic) IBOutlet UIButton *localShareButton;
@property (weak, nonatomic) IBOutlet UIButton *localCollectButton;
@property (weak, nonatomic) IBOutlet UIButton *localDeleteButton;
@property (weak, nonatomic) IBOutlet UIButton *dvrDownloadButton;
@property (weak, nonatomic) IBOutlet UIButton *dvrDeleteButton;
@property (weak, nonatomic) IBOutlet UIButton *allScreenBackButton;
@property (weak, nonatomic) IBOutlet UIImageView *collectionImage;

@property (assign) APKVideoPlayerResourceType resourceType;
@property (nonatomic ,strong) AVPlayer *player;
@property (strong,nonatomic) NSArray *nameArray;
@property (strong,nonatomic) id<NSObject> timeObserverToken;
@property (nonatomic) NSInteger currentIndex;
@property (strong,nonatomic) NSArray<NSURL *> *urlArray;
@property (nonatomic ,strong) AVAsset *avAsset;
@property (nonatomic ,strong) PHAsset *phAsset;
@property (strong,nonatomic) NSArray <PHAsset *>*assetArray;
@property (assign) BOOL isPausing;
@property (weak, nonatomic) IBOutlet UILabel *nameL;

@property (strong,nonatomic) NSMutableArray *items;
@property (weak,nonatomic) id<APKVideoPlayerDelegate>delegate;
@property (strong,nonatomic) APKDownloadDVRFileTool *downloadTool;
@property (strong,nonatomic) APKDeleteDVRFileTool *deleteTool;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic,retain) CLLocationManager *locationManager;
@property (nonatomic,retain) NSArray *locationArray;
@property (nonatomic,retain) MKPolyline *baseLine;
@property (nonatomic,retain) MKPolyline *visibleLine;
@property (nonatomic,retain) MKPolyline *lastVisibleLine;
@property (nonatomic,retain) NSTimer *time;
@property (nonatomic,retain) NSString *currentPlayUrl;
@property (nonatomic,retain) AVPlayerItemVideoOutput *videoOutPut;
@property (nonatomic,retain) UIImageView *imageView;
@property (nonatomic,assign) CGRect playViewPreviousFrame;
@property (weak, nonatomic) IBOutlet UIView *toolBackgoundView;
@property (strong,nonatomic) APKCachingThumbnailTool *cachingThumbnailTool;
@property (nonatomic,assign) float timerCount;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic,assign) BOOL isFirstShowVisibleLine;
@property (nonatomic,retain) UIScrollView *SCrollView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *fullScreenShowButton;
@property (nonatomic,assign) BOOL isHide;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (nonatomic,assign) BOOL isFinish;
@end

@implementation APKVideoPlayer

#pragma mark - life circle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //初始化地图
    [self initWithMapView];
    //初始化定位服务管理对象
    [self initWithLocationManager];
    
    [_locationManager startUpdatingLocation];
    
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"videoPlayer_sliderBar"] forState:UIControlStateNormal];
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"videoPlayer_sliderBar"] forState:UIControlStateSelected];

    if (self.resourceType == APKVideoPlayerResourceTypeDvr) {
        self.localToolsBar.hidden = YES;
    }
    else{
        self.dvrToolsBar.hidden = YES;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@[] forKey:@""];
    
    [self addObserver:self forKeyPath:@"player.currentItem.duration" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&AAPLPlayerViewControllerKVOContext];
    [self addObserver:self forKeyPath:@"player.currentItem.loadedTimeRanges" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&AAPLPlayerViewControllerKVOContext];
    [self addObserver:self forKeyPath:@"player.rate" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&AAPLPlayerViewControllerKVOContext];
    [self addObserver:self forKeyPath:@"player.currentItem.status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&AAPLPlayerViewControllerKVOContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    self.playerView.player = self.player;
    APKVideoPlayer __weak *weakSelf = self;
    self.timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:
                          ^(CMTime time) {
                              
                              double seconds = CMTimeGetSeconds(time);
//                              NSLog(@"%f",seconds);
                              weakSelf.progressSlider.value = seconds;
                              weakSelf.progressLabel.text = [weakSelf formatTimeWithSeconds:seconds];
                          }];

    [self updateUIWithCurrentIndex];
    [self loadAsset];
    
    [self drawLine];
    
//    [self showVisibleLine];
    
    float width = [[UIScreen mainScreen] bounds].size.width;
    self.scrollView.frame = CGRectMake(0, 100, width, width*9/16);
//    self.playerView.frame = self.scrollView.bounds;
    self.playViewPreviousFrame = self.scrollView.frame;
    self.allScreenBackButton.hidden = YES;
    self.toolBackgoundView.hidden = YES;
    self.isFirstShowVisibleLine = YES;
    
    self.scrollView.delegate = self;
//    [self.SCrollView addSubview:self.playerView];
//    self.playerView.frame = self.SCrollView.bounds;
//    NSLog(@"");
    [self showFullScreenActionButton:YES];
    self.nameL.hidden = YES;
    
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
    self.switchCameraButton.hidden = isHide;
    self.pauseButton.hidden = isHide;
    self.playButton.hidden = isHide;
    
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


-(void)showFullScreenActionButton:(BOOL)isHide
{
    for (UIButton *btn in self.fullScreenShowButton)
        btn.hidden = isHide;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    countNum = 0;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self invalidateTime];
}



-(void)drawLine
{
    
//    NSArray *locationArray = @[@[@"37.93563",@"116.377358"],@[@"37.935564",@"116.376414"],@[@"37.935646",@"116.376037"],@[@"37.93586",@"116.375791"],@[@"37.93586",@"116.375791"],@[@"37.937983",@"116.37474"],@[@"37.937616",@"116.3746"],@[@"37.937888",@"116.376971"],@[@"37.937855",@"116.377047"],@[@"37.937172",@"116.377132"],@[@"37.937604",@"116.377218"],@[@"37.937489",@"116.377132"],@[@"37.93614",@"116.377283"],@[@"37.935622",@"116.377347"]];
    
    NSArray *locationArray = @[@[@"37.93563",@"116.377358"],@[@"37.935564",@"116.376414"],@[@"37.935646",@"116.376037"],@[@"37.93586",@"116.375791"],@[@"37.93586",@"116.375791"],@[@"37.937983",@"116.37474"],@[@"37.937616",@"116.3746"],@[@"37.937888",@"116.376971"],@[@"37.937855",@"116.377047"],@[@"37.937172",@"116.377132"],@[@"37.937604",@"116.377218"],@[@"37.937489",@"116.377132"],@[@"37.93614",@"116.377283"],@[@"37.935622",@"116.377347"]];
    
    APKVideoPlayerLocalItem *item = self.items[self.currentIndex];

    self.locationArray = [APKHandleGpsInfoTool transformGpsInfoFromStringToArr:item.file.gpsDataStr];
    
    locationArray = self.locationArray;
    self.locationArray = locationArray;
    
    NSInteger count = locationArray.count;
    
    CLLocationCoordinate2D coords[count];
    
    for (int i = 0; i < locationArray.count; i ++) {
        
        NSString *longtitudeStr = locationArray[i][0];
        float longtitude = [longtitudeStr floatValue];
        
        NSString *latitudeStr = locationArray[i][1];
        float latitude = [latitudeStr floatValue];
        
        coords[i] = CLLocationCoordinate2DMake(longtitude,  latitude);
    }
    
    
//    coords[0] = CLLocationCoordinate2DMake(37.93563,  116.377358);
//    coords[1] = CLLocationCoordinate2DMake(37.935564,   116.376414);
//    coords[2] = CLLocationCoordinate2DMake(37.935646,  116.376037);
//    coords[3] = CLLocationCoordinate2DMake(37.93586, 116.375791);
//    coords[4] = CLLocationCoordinate2DMake(37.93586, 116.375791);
//    coords[5] = CLLocationCoordinate2DMake(37.937983, 116.37474);
//    coords[6] = CLLocationCoordinate2DMake(37.937616, 116.3746);
//    coords[7] = CLLocationCoordinate2DMake(37.937888, 116.376971);
//    coords[8] = CLLocationCoordinate2DMake(37.937855, 116.377047);
//    coords[9] = CLLocationCoordinate2DMake(37.937172,  116.377132);
//    coords[10] = CLLocationCoordinate2DMake(37.937604, 116.377218);
//    coords[11] = CLLocationCoordinate2DMake(37.937489, 116.377132);
//    coords[12] = CLLocationCoordinate2DMake(37.93614,  116.377283);
//    coords[13] = CLLocationCoordinate2DMake(37.935622,  116.377347);
    
    
//    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(22.534191,114.024867);
//    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
//    [self.mapView setRegion:MKCoordinateRegionMake(coords[13], span) animated:YES];
    
    MKPolyline *crum=[MKPolyline polylineWithCoordinates:coords count:locationArray.count];
    
    [self.mapView addOverlay:crum level:MKOverlayLevelAboveRoads];
    
    self.mapView.visibleMapRect = crum.boundingMapRect;
    
    self.baseLine = crum;
    
}

-(void)showVisibleLine:(int)duration
{
    CGFloat durationTime = duration;

    CGFloat allGpsArrayCount = self.locationArray.count;
    
    CGFloat timerCount = (CGFloat)durationTime/allGpsArrayCount;

    
    NSTimer *time = [NSTimer scheduledTimerWithTimeInterval:timerCount target:self selector:@selector(drawVisibleLine) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:time forMode:NSRunLoopCommonModes];
    
    self.time = time;
    
    
//    [self setRegion];
}

static int countNum = 0;
-(void)drawVisibleLine
{
//    [self setRegion];
    
    [self.mapView removeOverlay:self.lastVisibleLine];//移除上一个画线
    
    NSInteger count = _locationArray.count;
    
    CLLocationCoordinate2D coords[count];
    
    for (int i = 0; i < _locationArray.count; i ++) {
        
        NSString *longtitudeStr = _locationArray[i][0];
        float longtitude = [longtitudeStr floatValue];
        
        NSString *latitudeStr = _locationArray[i][1];
        float latitude = [latitudeStr floatValue];
        
        coords[i] = CLLocationCoordinate2DMake(longtitude,  latitude);
    }
    
    self.visibleLine = [MKPolyline polylineWithCoordinates:coords count:countNum];
    [self.mapView addOverlay:self.visibleLine level:MKOverlayLevelAboveRoads];
    
//    self.mapView.visibleMapRect = self.visibleLine.boundingMapRect;
    
    
    if (countNum == self.locationArray.count) {
        
//        [self invalidateTime];
         [_time setFireDate:[NSDate distantFuture]];//暂停定时器
    }
    
    self.lastVisibleLine = self.visibleLine;
    
    countNum++;
}



-(void)invalidateTime
{
    [self.time invalidate];
    self.time = nil;
}

-(void)setRegion
{
    
    
    NSString *longtiude = self.locationArray[0][0];
    NSString *latitude = self.locationArray[0][1];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([longtiude floatValue],[latitude floatValue]);
    
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
    [self.mapView setRegion:MKCoordinateRegionMake(coord, span) animated:YES];
}

//线路的绘制
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay
{
    
    if (self.visibleLine == overlay) {
        
        MKPolylineRenderer *renderer;
        renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.lineWidth = 5.0;
        renderer.strokeColor = [UIColor greenColor];
        return renderer;
    }
    
    MKPolylineRenderer *renderer;
    renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.lineWidth = 5.0;
    renderer.strokeColor = [UIColor purpleColor];
    
    return renderer;
}


- (void)initWithMapView
{
    //设置地图类型
//    _mapView.mapType = MKMapTypeStandard;
    //设置代理
    _mapView.delegate = self;
}

- (void)initWithLocationManager
{
    //初始化定位服务管理对象
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
//    [_locationManager requestAlwaysAuthorization];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        // requestAlwaysAuthorization 永久授权
        // requestWhenInUseAuthorization 使用期间授权
        [_locationManager requestAlwaysAuthorization];
    }
    //设置精确度
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //设置设备移动后获取位置信息的最小距离。单位为米
    _locationManager.distanceFilter = 10.0f;
    
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
        
        if (![self.durationLabel.text isEqualToString:@"0:00"] && self.isFirstShowVisibleLine) {
            
            self.isFirstShowVisibleLine = NO;
            [self showVisibleLine:newDurationSeconds];
        }
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
            [weakSelf.time setFireDate:[NSDate distantFuture]];//暂停定时器
            weakSelf.isFinish = YES;
            [weakSelf showOrHidePlayViewSubview:NO];
        }
    }];
}

- (void)loadPHAsset:(PHAsset *)asset{
    
    [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (asset != self.phAsset) {
                return;
            }
            
            _videoOutPut = [[AVPlayerItemVideoOutput alloc] init];
             [playerItem addOutput:self.videoOutPut];
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
        NSURL *url = [NSURL URLWithString:file.fileDownloadPath];//通过下载的本地地址获取
        AVURLAsset *asset = [AVURLAsset assetWithURL:url];
        self.avAsset = asset;
        [self loadAVAsset:asset];
        
    }else if(self.resourceType == APKVideoPlayerResourceTypeLocal){
        
        APKVideoPlayerLocalItem *item = self.items[self.currentIndex];
        PHAsset *asset = item.asset;
        self.phAsset = asset;
        self.nameL.text = item.file.name;
        [self loadPHAsset:asset];
        
        //重新画线
        countNum = 0;
        [self.mapView removeOverlay:self.baseLine];
        [self.mapView removeOverlay:self.visibleLine];
        [self drawLine];
    }
}

- (void)updateUIWithPlayerRate:(double)rate{
    
    if (rate == 1.0) {
        self.pauseButton.hidden = NO;
        self.playButton.hidden = YES;
        self.pauseButton.enabled = YES;
        [self.flower stopAnimating];
    }else{

        self.pauseButton.hidden = YES;
        self.playButton.hidden = YES;
        self.playButton.enabled = YES;
        if (!self.isPausing)
            [self.flower startAnimating];
        
    }
}

- (void)updateUIWithCurrentIndex{
    
    if (self.resourceType == APKVideoPlayerResourceTypeLocal) {
        
        APKVideoPlayerLocalItem *item = self.items[self.currentIndex];
        self.titleLabel.text = item.file.name;
        
        self.localCollectButton.selected = item.file.isCollected;
        
        self.collectionImage.hidden = item.file.isCollected == YES ? NO : YES;
    }
    else if (self.resourceType == APKVideoPlayerResourceTypeDvr){
        
        APKDVRFile *file = self.items[self.currentIndex];
        self.titleLabel.text = file.name;
        
        self.dvrDownloadButton.enabled = !file.isDownloaded;
    }
    
    NSInteger numberOfItems = self.items.count;
    self.previousButton.enabled = self.currentIndex == 0 ? NO : YES;
    self.nextButton.enabled = self.currentIndex == (numberOfItems - 1) ? NO : YES;
}

#pragma mark - public method

- (void)setupWithDvrItems:(NSArray<APKDVRFile *> *)dvrItems delegate:(id<APKVideoPlayerDelegate>)delegate downloadTool:(APKDownloadDVRFileTool *)downloadTool deleteTool:(APKDeleteDVRFileTool *)deleteTool currentIndex:(NSInteger)currentIndex{
    
    [self.items setArray:dvrItems];
    self.delegate = delegate;
    self.currentIndex = currentIndex;
    self.downloadTool = downloadTool;
    self.deleteTool = deleteTool;
    
    self.resourceType = APKVideoPlayerResourceTypeDvr;
}

- (void)setupWithLocalItems:(NSArray<APKVideoPlayerLocalItem *> *)localItems currentIndex:(NSInteger)currentIndex{
    
    [self.items setArray:localItems];
    self.currentIndex = currentIndex;
    
    self.resourceType = APKVideoPlayerResourceTypeLocal;
}

#pragma mark - action

- (IBAction)updateToolView:(UITapGestureRecognizer *)sender {
    
//    self.toolView.hidden = !self.toolView.hidden;
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
        
//        [self.mapView removeOverlay:self.visibleLine];
        
//         [self.time invalidate];
        
        
        if ((NSInteger)currentTime < self.locationArray.count) {
            
            countNum = (int)currentTime + 1;
            
            if (!self.isPausing) [_time setFireDate:[NSDate date]];//重启定时器

        }else
        {
            countNum = 0;
        }

        
    }];
    
    self.progressLabel.text = [self formatTimeWithSeconds:sender.value];
}

- (IBAction)progressSliderTouchDown:(UISlider *)sender {
    
    [self pause:self.pauseButton];
}

- (IBAction)play:(UIButton *)sender {
    
    self.isPausing = NO;
    [self.player play];
    
    [_time setFireDate:[NSDate date]];//重启定时器
}

- (IBAction)pause:(UIButton *)sender {
    
    self.isPausing = YES;
    [self.player pause];
    
    [_time setFireDate:[NSDate distantFuture]];//暂停定时器
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

- (IBAction)clickLocalShareButton:(UIButton *)sender {
    
    [self pause:self.pauseButton];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [APKShareTool loadShareItemsWithLocalVideoAsset:self.phAsset completionHandler:^(BOOL success, NSArray *items) {
        [hud hideAnimated:YES];
        if (success) {
            UIActivityViewController *avc = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
            avc.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeAddToReadingList,UIActivityTypePostToTencentWeibo];
            [self presentViewController:avc animated:YES completion:nil];
        }
    }];
}
- (IBAction)clickSwitchCameraButton:(UIButton *)sender {
    
    
    NSInteger index = self.currentIndex;
    APKVideoPlayerLocalItem *item = self.items[index];
    APKVideoPlayerLocalItem *lastItem = index == 0 ? item : self.items[index - 1];
    APKVideoPlayerLocalItem *nextItem = index == self.items.count - 1 ? item : self.items[index + 1];
    if ([lastItem.file.saveDate compare:item.file.saveDate] == NSOrderedSame && lastItem != item){
        
        self.currentIndex--;
        [self loadAsset];
        [self updateUIWithCurrentIndex];

    }
    else if ([nextItem.file.saveDate compare:item.file.saveDate] == NSOrderedSame && nextItem != item){
        
        self.currentIndex++;
        [self loadAsset];
        [self updateUIWithCurrentIndex];
    }
    else
        [APKAlertTool showAlertInViewController:self message:NSLocalizedString(@"没有文件", nil)];
}

- (IBAction)clickLocalCollectButton:(UIButton *)sender {
    
    APKVideoPlayerLocalItem *item = self.items[self.currentIndex];
    [item.file.managedObjectContext performBlock:^{
       
        item.file.isCollected = !item.file.isCollected;
        [item.file.managedObjectContext save:nil];
        
        self.localCollectButton.selected = item.file.isCollected;
        
        self.collectionImage.hidden = item.file.isCollected == YES ? NO : YES;
    }];
}

- (IBAction)clickLocalDeleteButton:(UIButton *)sender {
    
    [self pause:self.pauseButton];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    APKVideoPlayerLocalItem *item = self.items[self.currentIndex];
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        [PHAssetChangeRequest deleteAssets:@[item.asset]];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [hud hideAnimated:YES];
            
            if (success) {
                
                NSManagedObjectContext *context = item.file.managedObjectContext;
                [context deleteObject:item.file];
                [context save:nil];
                
                [self.items removeObjectAtIndex:self.currentIndex];
                if (self.items.count == 0) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                else{
                    
                    if (self.currentIndex >= self.items.count) {
                        
                        self.currentIndex--;
                    }
                    [self updateUIWithCurrentIndex];
                    [self loadAsset];
                }
            }
        });
    }];
}

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

- (IBAction)clickDvrDeleteButton:(UIButton *)sender {
    
    void (^confirmHandler)(UIAlertAction *action)  = ^(UIAlertAction *action){
        
        [self pause:self.pauseButton];
    
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        __weak typeof(self)weakSelf = self;
        APKDVRFile *file = self.items[self.currentIndex];
        __block NSMutableArray *deleteFileArr = [NSMutableArray arrayWithObject:file];
        [self.deleteTool deleteWithFileArray:@[file] completionHandler:^(NSArray *failureTaskArray) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [hud hideAnimated:YES];
                
                if (failureTaskArray.count > 0) {
                    
                    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"%d个文件删除失败！", nil),(int)failureTaskArray.count];
                    [APKAlertTool showAlertInViewController:weakSelf message:message];
                }
                else{
                    
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(APKVideoPlayer:didDeleteFileArr:)]) {
                        
                        [weakSelf.delegate APKVideoPlayer:weakSelf didDeleteFileArr:deleteFileArr];
                    }
                    
                    [weakSelf.items removeObjectAtIndex:weakSelf.currentIndex];
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
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"删除%d个文件？", nil),1];
    [APKAlertTool showAlertInViewController:self title:nil message:message handler:confirmHandler];
    [self pause:self.pauseButton];
}

- (IBAction)videoScreenShotButtonClick:(UIButton *)sender {
    
    APKVideoPlayer __weak *weakSelf = self;
    [APKLocalVidioEditTool getCurrentVideoImageWithVideoOutPut:weakSelf.videoOutPut andTime:weakSelf.player.currentItem.currentTime resultBlock:^(UIImage *image) {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
    }];
}

- (IBAction)allScreenShotButtonClick:(UIButton *)sender {
    
    APKVideoPlayer __weak *weakSelf = self;
    [APKLocalVidioEditTool getCurrentVideoImageWithVideoOutPut:weakSelf.videoOutPut andTime:weakSelf.player.currentItem.currentTime resultBlock:^(UIImage *image) {
        UIImage *videoImage = image;
        [APKLocalVidioEditTool getVideoShotWithFrame:self.mapView.frame resultBlock:^(UIImage *image) {
            UIImage *mapImage = image;
            
            CGRect playerFrame = CGRectMake(0, 100,CGRectGetWidth(self.playerView.frame), CGRectGetHeight(self.playerView.frame));
            CGRect imageFrame = CGRectMake(0, 100 + CGRectGetHeight(self.playerView.frame), CGRectGetWidth(self.mapView.frame), CGRectGetHeight(self.mapView.frame));
            
            [APKLocalVidioEditTool getVideoAndMapScreenShotWithVideoImage:videoImage videoFrame:playerFrame andMapImage:mapImage mapFrame:imageFrame resultBlock:^(UIImage *image) {
                UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
            }];
            
        }];
    }];
    
}

- (IBAction)moreButtonClick:(UIButton *)sender {
    self.toolBackgoundView.hidden = NO;
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error) {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"截取图片成功", nil),1];
        [APKAlertTool showAlertInViewController:self title:nil message:message handler:nil];
        [self.imageView removeFromSuperview];
    }
    
}

- (IBAction)allScreenButtonClick:(UIButton *)sender {
    
    self.allScreenBackButton.hidden = NO;
    self.nameL.hidden = NO;
    
    /*
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    self.scrollView.frame = CGRectMake(screenWidth / 2.f - screenHeight / 2.f, screenHeight / 2.f - screenWidth / 2.f, screenHeight, screenWidth);
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.maximumZoomScale = 3;
    self.scrollView.pinchGestureRecognizer.enabled = NO;//禁止缩放
    self.scrollView.panGestureRecognizer.enabled = NO;
    self.scrollView.transform = CGAffineTransformMakeRotation(M_PI/2);
    [self.view bringSubviewToFront:self.scrollView];*/
    
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
        self.scrollView.frame = CGRectMake(screenWidth / 2.f - screenHeight / 2.f, screenHeight / 2.f - screenWidth / 2.f, screenHeight, screenWidth);
        self.scrollView.transform = CGAffineTransformMakeRotation(M_PI/2);
        [self.view bringSubviewToFront:self.scrollView];
    
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01/*延迟执行时间*/ * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        self.playerView.frame = CGRectMake(CGRectGetMinX(self.playerView.frame), CGRectGetMinY(self.playerView.frame), screenHeight, screenWidth);
//        self.playerView.frame = self.scrollView.bounds;
    });
    
    [self showFullScreenActionButton:NO];
    NSLog(@"");
    //    self.playerView.transform = CGAffineTransformMakeRotation(M_PI/2);
    
}

- (IBAction)allScreenBackButton:(UIButton *)sender {
    
    self.nameL.hidden = YES;
    self.scrollView.transform = CGAffineTransformIdentity;
    self.scrollView.frame = self.playViewPreviousFrame;
//    self.playerView.frame = CGRectMake(CGRectGetMinX(self.playerView.frame), CGRectGetMinY(self.playerView.frame),CGRectGetWidth(self.scrollView.frame),CGRectGetHeight(self.scrollView.frame));
    self.allScreenBackButton.hidden = YES;
    self.scrollView.pinchGestureRecognizer.enabled = YES;
    self.scrollView.panGestureRecognizer.enabled = YES;
    
    [self showFullScreenActionButton:YES];
    float width = [[UIScreen mainScreen] bounds].size.width;
    self.scrollView.frame = CGRectMake(0, 134, width, width*9/16);
}
- (IBAction)toolBarButtonClick:(UIButton *)sender {
    self.toolBackgoundView.hidden = YES;
    
    __block APKVideoPlayerLocalItem *item = self.items[self.currentIndex];
    PHAsset *asset = item.asset;
    
    if (sender.tag == 102) {
        
        __weak typeof(self)weakSelf = self;
        [self.cachingThumbnailTool getVidioAsset:asset resultHandler:^(NSString *url) {
            
            APKLocalVidioCutViewController *VC = [APKLocalVidioCutViewController new];
            VC.fileUrl = url;
            VC.localFile = item.file;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf presentViewController:VC animated:YES completion:nil];
            });
        }];
    }else if(sender.tag == 103){
        
        self.mergeVidioBlock(self.indexPath);
    }
    
}

-(void)vidioPlayerWithIndexPath:(NSIndexPath *)indexPath andMergeVidioBlock:(void (^)(NSIndexPath *))mergeVidioBlock
{
    self.indexPath = indexPath;
    self.mergeVidioBlock = mergeVidioBlock;
    
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

-(APKCachingThumbnailTool *)cachingThumbnailTool
{
    if (!_cachingThumbnailTool) {
        _cachingThumbnailTool = [[APKCachingThumbnailTool alloc] init];
    }
    return _cachingThumbnailTool;
}

-(UIScrollView *)SCrollView
{
    if (!_SCrollView) {
//        _SCrollView = [[UIScrollView alloc] initWithFrame:self.playerView.frame];
        [_SCrollView setMinimumZoomScale:1.0];//设置最小的缩放大小
        _SCrollView.maximumZoomScale = 2.0;//设置最大的缩放
        _SCrollView.delegate = self;
    }
    return _SCrollView;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
//    return self.playerView;
    return nil;
}

//当正在缩放的时候调用
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    NSLog(@"正在缩放.....");
    
    
}

@end
