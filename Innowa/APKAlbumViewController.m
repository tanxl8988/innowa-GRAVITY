//
//  APKAlbumViewController.m
//  Innowa
//
//  Created by Mac on 17/3/28.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKAlbumViewController.h"
#import "APKFloderCell.h"
#import "APKDVR.h"
#import "MBProgressHUD.h"
#import "APKDVRPhotosViewController.h"
#import "APKDVRVideosViewController.h"
#import "APKLocalPhotosViewController.h"
#import "APKLocalVideosViewController.h"
#import "APKCollectFilesViewController.h"
#import "APKAlertTool.h"
#import <Photos/Photos.h>
#import "APKCommonTaskTool.h"

#define APKHaveRearCameraKey @"APKHaveRearCameraKey"

@implementation APKAlbumInfo

@end

@interface APKAlbumViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewContentWidth;
@property (weak, nonatomic) IBOutlet UICollectionView *localFlodersCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *dvrFlodersCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *localFlodersLayout;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *dvrFlodersLayout;
@property (weak, nonatomic) IBOutlet UIButton *localButton;
@property (weak, nonatomic) IBOutlet UIButton *dvrButton;
@property (weak,nonatomic) MBProgressHUD *validateLocalFilesHUD;
@property (strong,nonatomic) NSMutableArray *localAlbumInfos;
@property (strong,nonatomic) NSMutableArray *dvrAlbumInfos;
@property (strong,nonatomic) APKCommonTaskTool *taskTool;
@end

@implementation APKAlbumViewController

extern float test;
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        [[APKRefreshLocalFilesTool sharedInstace] addObserver:self forKeyPath:@"enable" options:NSKeyValueObservingOptionNew context:nil];
        APKDVR *dvr = [APKDVR sharedInstance];
        [dvr addObserver:self forKeyPath:@"info.haveRearCamera" options:NSKeyValueObservingOptionNew context:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPage) name:APKHaveRefreshLocalFilesNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.localButton setTitle:NSLocalizedString(@"本地", nil) forState:UIControlStateNormal];
    [self.dvrButton setTitle:NSLocalizedString(@"DVR", nil) forState:UIControlStateNormal];
    [self updateUIWithClickButton:self.localButton];

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.scrollViewContentWidth.constant = screenWidth * 2;
    
    CGFloat space = (self.localFlodersLayout.sectionInset.left + self.localFlodersLayout.sectionInset.right) * 2;
    CGFloat infoViewHeight = 37;
    CGFloat cellWidth = (screenWidth - space) / 2;
    CGFloat cellHeight = (cellWidth / 1.24) + infoViewHeight;
    CGSize cellSize = CGSizeMake(cellWidth, cellHeight);
    self.localFlodersLayout.itemSize = cellSize;
    self.dvrFlodersLayout.itemSize = cellSize;
    
    APKDVR *dvr = [APKDVR sharedInstance];
    //曾经有过后镜头
    if (dvr.info.haveRearCamera) {
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:YES forKey:APKHaveRearCameraKey];
        [userDefaults synchronize];
    }
    
    [self updateAlbumInfo];
    
    //Photos authorization
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status != PHAuthorizationStatusAuthorized) {
        
        if (status == PHAuthorizationStatusDenied) {
            
            [self showGetPHAuthorizationAlert];
            
        }else{
            
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                
            }];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"endFullScreen" object:nil];
}

- (void)updateAlbumInfo{
    
    NSArray *infoArray = [self getInfoArray:YES];
    NSArray *coverImageNameArray = [self getCoverImageNameArray:YES];;
    NSArray *fileTypeArray = [self getFileTypeArray:YES];;
    NSArray *isRearCameraArray = [self getIsRearCameraArray:YES];;
    NSArray *segueIdentifierArray = [self getSegueIdentifierArray:YES];
//    NSArray *fileCountArray = [self getLocalFileCountArray];
    NSInteger floderCount = segueIdentifierArray.count;
    
    [self.localAlbumInfos removeAllObjects];
    for (NSInteger i = 0; i < floderCount; i++) {
        
        APKAlbumInfo *info = [APKAlbumInfo new];
        NSString *infoKey = infoArray[i];
//        NSInteger count = [fileCountArray[i] integerValue];
        NSString *infoStr = [NSString stringWithFormat:@"%@",NSLocalizedString(infoKey, nil)];
        info.info = infoStr;
        info.albumTitle = NSLocalizedString(infoKey, nil);
        info.coverImageName = coverImageNameArray[i];
        info.fileType = [fileTypeArray[i] integerValue];
        info.isRearCamera = [isRearCameraArray[i] boolValue];
        info.segueIdentifier = segueIdentifierArray[i];
        [self.localAlbumInfos addObject:info];
    }
    
    infoArray = [self getInfoArray:NO];
    coverImageNameArray = [self getCoverImageNameArray:NO];;
    fileTypeArray = [self getFileTypeArray:NO];;
    isRearCameraArray = [self getIsRearCameraArray:NO];;
    segueIdentifierArray = [self getSegueIdentifierArray:NO];
    floderCount = segueIdentifierArray.count;
    
    [self.dvrAlbumInfos removeAllObjects];
    for (NSInteger i = 0; i < floderCount; i++) {
        
        APKAlbumInfo *info = [APKAlbumInfo new];
        NSString *infoKey = infoArray[i];
        info.info = NSLocalizedString(infoKey, nil);
        info.albumTitle = NSLocalizedString(infoKey, nil);
        info.coverImageName = coverImageNameArray[i];
        info.fileType = [fileTypeArray[i] integerValue];
        info.isRearCamera = [isRearCameraArray[i] boolValue];
        info.segueIdentifier = segueIdentifierArray[i];
        [self.dvrAlbumInfos addObject:info];
    }
}


- (void)dealloc
{
    APKDVR *dvr = [APKDVR sharedInstance];
    [dvr removeObserver:self forKeyPath:@"info.haveRearCamera"];
    [[APKRefreshLocalFilesTool sharedInstace] removeObserver:self forKeyPath:@"enable"];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"enable"]) {
        
        BOOL finished = [change[@"new"] boolValue];
        if (finished) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.validateLocalFilesHUD) {
                    [self.validateLocalFilesHUD hideAnimated:YES];
                }
            });
        }
        
    }else if ([keyPath isEqualToString:@"info.haveRearCamera"]){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            BOOL haveRearCamera = [change[@"new"] boolValue];
            //曾经有过后镜头
            if (haveRearCamera) {
                
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setBool:YES forKey:APKHaveRearCameraKey];
                [userDefaults synchronize];
            }
            
            [self updateAlbumInfo];
            [self.localFlodersCollectionView reloadData];
            [self.dvrFlodersCollectionView reloadData];
        });
    }
}

#pragma mark - getter

- (NSMutableArray *)localAlbumInfos{
    
    if (!_localAlbumInfos) {
        _localAlbumInfos = [[NSMutableArray alloc] init];
    }
    return _localAlbumInfos;
}

- (NSMutableArray *)dvrAlbumInfos{
    
    if (!_dvrAlbumInfos) {
        _dvrAlbumInfos = [[NSMutableArray alloc] init];
    }
    return _dvrAlbumInfos;
}

#pragma mark - private method

- (void)showGetPHAuthorizationAlert{
    
    [APKAlertTool showAlertInViewController:self title:nil message:NSLocalizedString(@"请允许Journey访问iPhone的\"照片\"，否则无法使用下载功能！", nil) cancelHandler:^(UIAlertAction *action) {
        
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        UIApplication *app = [UIApplication sharedApplication];
        if ([app canOpenURL:url]) {
            
            NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
            NSInteger iosVersionNumber = [[[iosVersion componentsSeparatedByString:@"."] firstObject] integerValue];
            if (iosVersionNumber >= 10) {
                
                [app openURL:url options:@{} completionHandler:^(BOOL success) { /*do nothing*/ }];
                
            }else{
                
                [app openURL:url];
            }
        }
    }];
}

- (void)refreshPage{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateAlbumInfo];
        [self.localFlodersCollectionView reloadData];
    });
}


- (NSArray *)getLocalFileCountArray{
    
    NSArray *arr = nil;
    
    BOOL useToHaveRearCamera = [[NSUserDefaults standardUserDefaults] boolForKey:APKHaveRearCameraKey];
    APKRefreshLocalFilesTool *refreshLocalFilesTool = [APKRefreshLocalFilesTool sharedInstace];
    if (useToHaveRearCamera) {
        arr = @[@(refreshLocalFilesTool.videoCount),@(refreshLocalFilesTool.rearVideoCount),@(refreshLocalFilesTool.eventCount),@(refreshLocalFilesTool.rearEventCount),@(refreshLocalFilesTool.photoCount),@(refreshLocalFilesTool.rearPhotoCount),@(refreshLocalFilesTool.collectCount)];

    }else{
        arr = @[@(refreshLocalFilesTool.videoCount),@(refreshLocalFilesTool.eventCount),@(refreshLocalFilesTool.photoCount),@(refreshLocalFilesTool.collectCount)];
    }
    
    return arr;
}

- (NSArray *)getInfoArray:(BOOL)isLocalAlbum{
    
    NSArray *arr = nil;
    
    if (isLocalAlbum) {
        
        BOOL useToHaveRearCamera = [[NSUserDefaults standardUserDefaults] boolForKey:APKHaveRearCameraKey];
        if (useToHaveRearCamera) {
            arr = @[NSLocalizedString(@"视频", nil),NSLocalizedString(@"事件", nil),NSLocalizedString(@"停车时间视频", nil),NSLocalizedString(@"停车事件视频", nil),NSLocalizedString(@"图片", nil),NSLocalizedString(@"收藏", nil),NSLocalizedString(@"编辑", nil)];

        }else{
            arr = @[@"本地视频",@"本地事件",@"本地照片",@"我的收藏"];
        }
        arr = @[NSLocalizedString(@"视频", nil),NSLocalizedString(@"事件", nil),NSLocalizedString(@"缩时录影", nil),NSLocalizedString(@"泊车模式事件", nil),NSLocalizedString(@"照片", nil),NSLocalizedString(@"收藏", nil)/*,NSLocalizedString(@"编辑", nil)*/];
        
    }else{
        
        APKDVR *dvr = [APKDVR sharedInstance];
        if (dvr.info.haveRearCamera) {
            arr = @[@"DVR录像视频",@"DVR事件视频",@"DVR停车时间视频",@"DVR停车事件视频",@"DVR照片"];
        }else{
            arr = @[@"DVR视频",@"DVR事件",@"DVR照片"];
        }
        arr = @[NSLocalizedString(@"视频", nil),NSLocalizedString(@"事件", nil),NSLocalizedString(@"缩时录影", nil),NSLocalizedString(@"泊车模式事件", nil),NSLocalizedString(@"照片", nil)];
    }
    
    return arr;

}

- (NSArray *)getCoverImageNameArray:(BOOL)isLocalAlbum{
    
    NSArray *arr = nil;
    
    if (isLocalAlbum) {
        
        BOOL useToHaveRearCamera = [[NSUserDefaults standardUserDefaults] boolForKey:APKHaveRearCameraKey];
        if (useToHaveRearCamera) {
            arr = @[@"icon-29",@"icon-31",@"icon-33",@"icon-35",@"icon-37",@"icon-39",@"icon-41"];
        }else{
            arr = @[@"videos_floder",@"events_floder",@"photos_floder",@"fav_floder"];
        }
        arr = @[@"icon-29",@"icon-31",@"icon-33",@"icon-35",@"icon-37",@"icon-39"/*,@"icon-41"*/];
        
    }else{
        
        APKDVR *dvr = [APKDVR sharedInstance];
        if (dvr.info.haveRearCamera) {
            arr = @[@"icon-29",@"icon-31",@"icon-33",@"icon-35",@"icon-37"];

        }else{
            arr = @[@"videos_floder",@"events_floder",@"photos_floder"];
        }
        arr = @[@"icon-29",@"icon-31",@"icon-33",@"icon-35",@"icon-37"];
    }
    
    return arr;
}

- (NSArray *)getFileTypeArray:(BOOL)isLocalAlbum{
    
    NSArray *arr = nil;
    
    if (isLocalAlbum) {
        
        BOOL useToHaveRearCamera = [[NSUserDefaults standardUserDefaults] boolForKey:APKHaveRearCameraKey];
        if (useToHaveRearCamera) {
            arr = @[@(kAPKDVRFileTypeVideo),@(kAPKDVRFileTypeEvent),@(kAPKDVRFileTypeParkTime),@(kAPKDVRFileTypeParkEvent),@(kAPKDVRFileTypePhoto),@(100),@(kAPKDVRFileTypeVidioEdit)];
        }else{
            arr = @[@(kAPKDVRFileTypeVideo),@(kAPKDVRFileTypeEvent),@(kAPKDVRFileTypePhoto),@(100)];
        }
        arr = @[@(kAPKDVRFileTypeVideo),@(kAPKDVRFileTypeEvent),@(kAPKDVRFileTypeParkTime),@(kAPKDVRFileTypeParkEvent),@(kAPKDVRFileTypePhoto),@(100)/*,@(kAPKDVRFileTypeVidioEdit)*/];
        
    }else{
        
        APKDVR *dvr = [APKDVR sharedInstance];
        if (dvr.info.haveRearCamera) {
            arr = @[@(kAPKDVRFileTypeVideo),@(kAPKDVRFileTypeEvent),@(kAPKDVRFileTypeParkTime),@(kAPKDVRFileTypeParkEvent),@(kAPKDVRFileTypePhoto)];
        }else{
            arr = @[@(kAPKDVRFileTypeVideo),@(kAPKDVRFileTypeEvent),@(kAPKDVRFileTypePhoto)];
        }
        arr = @[@(kAPKDVRFileTypeVideo),@(kAPKDVRFileTypeEvent),@(kAPKDVRFileTypeParkTime),@(kAPKDVRFileTypeParkEvent),@(kAPKDVRFileTypePhoto)];
    }
    
    return arr;
}

- (NSArray *)getIsRearCameraArray:(BOOL)isLocalAlbum{
    
    NSArray *arr = nil;
    
    if (isLocalAlbum) {
        
        BOOL useToHaveRearCamera = [[NSUserDefaults standardUserDefaults] boolForKey:APKHaveRearCameraKey];
        if (useToHaveRearCamera) {
            arr = @[@(NO),@(YES),@(NO),@(YES),@(NO),@(YES),@(NO)];
        }else{
            arr = @[@(NO),@(NO),@(NO),@(NO)];
        }
        arr = @[@(NO),@(YES),@(NO),@(YES),@(NO),@(YES)/*,@(NO)*/];
        
    }else{
        
        APKDVR *dvr = [APKDVR sharedInstance];
        if (dvr.info.haveRearCamera) {
            arr = @[@(NO),@(YES),@(NO),@(YES),@(NO),@(YES)];
        }else{
            arr = @[@(NO),@(NO),@(NO)];
        }
        arr = @[@(NO),@(YES),@(NO),@(YES),@(NO),@(YES)];
    }
    
    return arr;

}

- (NSArray *)getSegueIdentifierArray:(BOOL)isLocalAlbum{
    
    NSArray *arr = nil;
    
    if (isLocalAlbum) {
        
        BOOL useToHaveRearCamera = [[NSUserDefaults standardUserDefaults] boolForKey:APKHaveRearCameraKey];
        if (useToHaveRearCamera) {
            arr = @[@"checkLocalVideos",@"checkLocalVideos",@"checkLocalVideos",@"checkLocalVideos",@"checkLocalPhotos",@"checkCollectFiles",@"checkLocalVideos"];
        }else{
            arr = @[@"checkLocalVideos",@"checkLocalVideos",@"checkLocalPhotos",@"checkCollectFiles"];
        }
        arr = @[@"checkLocalVideos",@"checkLocalVideos",@"checkLocalVideos",@"checkLocalVideos",@"checkLocalPhotos",@"checkCollectFiles"/*,@"checkLocalVideos"*/];
        
    }else{
        
        APKDVR *dvr = [APKDVR sharedInstance];
        if (dvr.info.haveRearCamera) {
            arr = @[@"checkDVRVideos",@"checkDVRVideos",@"checkDVRVideos",@"checkDVRVideos",@"checkDVRPhotos"];
        }else{
            arr = @[@"checkDVRVideos",@"checkDVRVideos",@"checkDVRPhotos"];
        }
        arr = @[@"checkDVRVideos",@"checkDVRVideos",@"checkDVRVideos",@"checkDVRVideos",@"checkDVRPhotos"];
    }
    
    return arr;

}





#pragma mark - UI

- (void)updateUIWithRefreshLocalFilesState:(BOOL)finished{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (finished) {
            
            if (self.validateLocalFilesHUD) {
                [self.validateLocalFilesHUD hideAnimated:YES];
            }
        }
    });
}

- (void)updateUIWithClickButton:(UIButton *)sender{
    
    sender.enabled = NO;
    if (sender == self.localButton) {
        
        self.dvrButton.enabled = YES;
        self.dvrButton.backgroundColor = [UIColor blackColor];
        self.localButton.backgroundColor = [UIColor blackColor];
        self.dvrButton.selected = NO;
        self.localButton.selected = YES;
       

    }else if (sender == self.dvrButton){
        
        self.localButton.enabled = YES;
        self.dvrButton.backgroundColor = [UIColor blackColor];
        self.localButton.backgroundColor = [UIColor blackColor];
        self.dvrButton.selected = YES;
        self.localButton.selected = NO;
    }
}

#pragma mark - actions

- (IBAction)clickButton:(UIButton *)sender {
    
    [self updateUIWithClickButton:sender];
    
    CGFloat offsetX = 0;
    if (sender == self.dvrButton){
        
        CGFloat scrollViewWidth = CGRectGetWidth(self.scrollView.frame);
        offsetX = scrollViewWidth;
    }
    CGPoint offset = self.scrollView.contentOffset;
    offset.x = offsetX;
    [UIView animateWithDuration:0.3 animations:^{
        
        self.scrollView.contentOffset = offset;
    }];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (scrollView != self.scrollView) {
        return;
    }
    
    CGFloat offsetX = scrollView.contentOffset.x;
    if (offsetX == 0) {
        
        [self updateUIWithClickButton:self.localButton];
        
    }else{
        
        [self updateUIWithClickButton:self.dvrButton];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    NSInteger count = 0;
    if (collectionView == self.localFlodersCollectionView) {
        
        count = self.localAlbumInfos.count;
        
    }else if (collectionView == self.dvrFlodersCollectionView){
        
        count = self.dvrAlbumInfos.count;
    }
    
    return count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *localFloderCellIdentifier = @"localFloderCell";
    static NSString *dvrFloderCellIdentifier = @"dvrFloderCell";
    
    APKFloderCell *cell = nil;
    APKAlbumInfo *info = nil;
    if (collectionView == self.localFlodersCollectionView) {
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:localFloderCellIdentifier forIndexPath:indexPath];
        info = self.localAlbumInfos[indexPath.row];
        
    }else if (collectionView == self.dvrFlodersCollectionView){
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:dvrFloderCellIdentifier forIndexPath:indexPath];
        info = self.dvrAlbumInfos[indexPath.row];
    }
    
    if (cell) {
        cell.imagev.image = [UIImage imageNamed:info.coverImageName];
        cell.label.text = info.info;
    }

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (![APKRefreshLocalFilesTool sharedInstace].enable) {
        
        if (!self.validateLocalFilesHUD) {
            self.validateLocalFilesHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
        return;
    }
    
    if (collectionView == self.localFlodersCollectionView) {
        
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status != PHAuthorizationStatusAuthorized) {
            
            [self showGetPHAuthorizationAlert];
            return;
        }
        
        APKAlbumInfo *info = self.localAlbumInfos[indexPath.row];
        [self performSegueWithIdentifier:info.segueIdentifier sender:info];
        
    }else if (collectionView == self.dvrFlodersCollectionView){
        
        if (![APKDVR sharedInstance].isConnected) {
            
            [APKAlertTool showAlertInViewController:self message:NSLocalizedString(@"未连接DVR！", nil)];
            return;
        }
        
        [self.taskTool getParkingModeInfo:^(BOOL success) {
            
            NSString *parkingModeInfo = [APKDVR sharedInstance].info.parkingModeInfo;
            NSString *parkMode = [parkingModeInfo substringToIndex:1];
            if ([parkMode isEqualToString:@"1"]){
                
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"在泊车模式下查看SD卡档案已自动退出泊车模式。请在主机长按P键重新进入停车模式", nil) preferredStyle:UIAlertControllerStyleAlert];//UIAlertControllerStyleAlert视图在中央
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    [self presentViewController:indexPath.row];
                    
                }];//https在iTunes中找，这里的事件是前往手机端App store下载微信
                [alertController addAction:cancelAction];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }else
                [self presentViewController:indexPath.row];
        }];
    }
}

-(void)presentViewController:(NSInteger)row
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status != PHAuthorizationStatusAuthorized) {
        
        [self showGetPHAuthorizationAlert];
        return;
    }
    
    APKAlbumInfo *info = self.dvrAlbumInfos[row];
    [self performSegueWithIdentifier:info.segueIdentifier sender:info];
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"checkDVRPhotos"]) {
        
        APKAlbumInfo *info = sender;
        APKDVRPhotosViewController *vc = segue.destinationViewController;
        vc.isRearCameraFile = info.isRearCamera;
        vc.albumTitle = info.albumTitle;
        
    }else if ([segue.identifier isEqualToString:@"checkDVRVideos"]) {
        
        APKAlbumInfo *info = sender;
        APKDVRVideosViewController *vc = segue.destinationViewController;
        vc.fileType = info.fileType;
        vc.isRearCameraFile = info.isRearCamera;
        vc.albumTitle = info.albumTitle;
        
    }else if ([segue.identifier isEqualToString:@"checkLocalPhotos"]) {
    
        APKAlbumInfo *info = sender;
        APKLocalPhotosViewController *vc = segue.destinationViewController;
        vc.isRearCameraFile = info.isRearCamera;
        vc.albumTitle = info.albumTitle;

    }else if ([segue.identifier isEqualToString:@"checkLocalVideos"]){
        
        APKLocalVideosViewController *vc = segue.destinationViewController;
        APKAlbumInfo *info = sender;
        vc.fileType = info.fileType;
        vc.isRearCameraFile = info.isRearCamera;
        vc.albumTitle = info.albumTitle;
        
    }else if ([segue.identifier isEqualToString:@"checkCollectFiles"]){
        
    }
}

- (APKCommonTaskTool *)taskTool{
    
    if (!_taskTool) {
        
        _taskTool = [[APKCommonTaskTool alloc] init];
    }
    
    return _taskTool;
}


@end
