//
//  APKDVRPhotosViewController.m
//  Innowa
//
//  Created by Mac on 17/4/25.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKDVRPhotosViewController.h"
#import "APKDVRPhotoCell.h"
#import "APKCustomTabBarController.h"
#import "APKPhotosPageFooterView.h"
#import "APKRequestDVRFileTool.h"
#import "APKDownloadDVRFileTool.h"
#import "APKDeleteDVRFileTool.h"
#import "MBProgressHUD.h"
#import "MWPhotoBrowser.h"
#import "LocalFile.h"
#import "APKDVRPhotoCaptionView.h"
#import "APKDownloadInfoView.h"
#import "APKAlertTool.h"
#import "APKCommonTaskTool.h"
#import "APKDVRTimeSelectView.h"
#import "APKDVR.h"

static NSString *headerViewIdentifier = @"headerView";
static NSString *identifier = @"APKPhotoCell";

typedef enum : NSUInteger {
    kAPKRequestDVRFileStateNone,
    kAPKRequestDVRFileStateRefreshPage,//刷新页面（下拉刷新）
    kAPKRequestDVRFileStateLoadMore,//上拉加载更多
} APKRequestDVRFileState;

@interface APKDVRPhotosViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,APKDVRPhotoCellDelegate,MWPhotoBrowserDelegate,APKDVRPhotoCaptionViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkAllButton;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBarBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (weak,nonatomic) APKPhotosPageFooterView *footerView;
@property (strong,nonatomic) UIRefreshControl *refreshControl;
@property (strong,nonatomic) APKRequestDVRFileTool *requestDVRFileTool;
@property (strong,nonatomic) APKDownloadDVRFileTool *downloadTool;
@property (strong,nonatomic) APKDeleteDVRFileTool *deleteTool;
@property (strong,nonatomic) NSMutableArray *dataSource;
@property (assign) APKRequestDVRFileState requestState;
@property (nonatomic, assign) BOOL isNoMoreFiles;
@property (strong,nonatomic) NSMutableArray *photos;
@property (weak,nonatomic) MWPhotoBrowser *photoBrowser;
@property (assign) BOOL haveCheckAll;
@property (strong,nonatomic) NSIndexPath *longPressIndexPath;
@property (assign) BOOL haveRefreshLocalFiles;
@property (nonatomic) NSInteger selectCount;
@property (strong,nonatomic) APKRefreshLocalFilesTool *refreshLocalFilesTool;
@property (strong,nonatomic) APKCommonTaskTool *taskTool;
@property (nonatomic,assign) CGRect previousTitleLRect;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *classifyButton;
@property (nonatomic,retain) APKDVRTimeSelectView *timeView;
@property (nonatomic,assign) BOOL isRequestGroupData;
@property (nonatomic,retain) NSMutableArray *headArray;
@property (nonatomic,retain) NSDate *beginDate;
@property (nonatomic,retain) NSDate *endDate;
@property (nonatomic) int colorCount;
@property (nonatomic,assign) BOOL isHaveRearCamera;

@end

@implementation APKDVRPhotosViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshPage) forControlEvents:UIControlEventValueChanged];
//    [self.collectionView addSubview:self.refreshControl];
    [self.collectionView sendSubviewToBack:self.refreshControl];
    
    self.collectionView.alwaysBounceVertical = YES;
    
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter   withReuseIdentifier:headerViewIdentifier];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader   withReuseIdentifier:headerViewIdentifier];
    
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    self.layout.footerReferenceSize = CGSizeMake(screenWidth, 40);
//    UINib *nib = [UINib nibWithNibName:@"APKPhotosPageFooterView" bundle:nil];
//    [self.collectionView registerNib:nib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:headerViewIdentifier];

    CGFloat space = 20 * 2 + 8 * 2;
    CGFloat infoLabelHeight = 42;
    CGFloat cellWidth = (screenWidth - space) / 3;
    CGFloat cellHeight = cellWidth / 16.f * 9.f + infoLabelHeight;
    self.layout.itemSize = CGSizeMake(cellWidth, cellHeight);
    
    CGFloat bottomBarHeight = CGRectGetHeight(self.bottomBar.frame);
    self.bottomBarBottomConstraint.constant = -bottomBarHeight;
    
    self.previousTitleLRect = self.titleLabel.frame;
    
    self.checkAllButton.hidden = YES;
    if ([self.albumTitle isEqualToString:NSLocalizedString(@"DVR照片", nil)]) {
        self.titleLabel.text = NSLocalizedString(@"DVR照片", nil);
    }else if([self.albumTitle isEqualToString:NSLocalizedString(@"DVR前镜头照片", nil)]){
        self.titleLabel.text = NSLocalizedString(@"DVR前镜头照片列表", nil);
    }else if([self.albumTitle isEqualToString:NSLocalizedString(@"DVR后镜头照片", nil)]){
        self.titleLabel.text = NSLocalizedString(@"DVR后镜头照片列表", nil);
    }
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"本地", nil),NSLocalizedString(@"照片", nil)];

    if (screenWidth > 320) {
        self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    }else{
        self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    }
    
    [self.selectButton setTitle:NSLocalizedString(@"选择", nil) forState:UIControlStateNormal];
    [self.checkAllButton setTitle:NSLocalizedString(@"全选", nil) forState:UIControlStateNormal];
    
    [self refreshPage];
    
    UIButton *recentButton = (UIButton*)self.classifyButton[0];
    recentButton.backgroundColor = [UIColor brownColor];
    
    classifytype = 0;
    
    self.collectionView.allowsMultipleSelection = NO;
    
    NSString *btnTitle = @"";
    for (int i = 0;i < self.classifyButton.count; i++) {
        
        UIButton *btn = self.classifyButton[i];
        switch (i) {
            case 0:
                btnTitle = NSLocalizedString(@"最近", nil);
                break;
            case 1:
                btnTitle = NSLocalizedString(@"群组", nil);
                break;
            case 2:
                btnTitle = NSLocalizedString(@"全部", nil);
                break;
            default:
                btnTitle = NSLocalizedString(@"自定义", nil);
                break;
        }
        [btn setTitle:btnTitle forState:UIControlStateNormal];
        btn.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    self.selectButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.checkAllButton.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    APKCustomTabBarController *tabBarVC = (APKCustomTabBarController *)self.tabBarController;
    tabBarVC.customTabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    APKCustomTabBarController *tabBarVC = (APKCustomTabBarController *)self.tabBarController;
    tabBarVC.customTabBar.hidden = NO;
    
    if (self.haveRefreshLocalFiles) {
        [self.refreshLocalFilesTool updatePhotoCount];
    }
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

#pragma mark - private method

- (void)download:(NSArray *)fileArray isFav:(BOOL)isFav{
    
    __weak typeof(self)weakSelf = self;
    APKDownloadInfoView *downloadInfoView = [[NSBundle mainBundle] loadNibNamed:@"APKDownloadInfoView" owner:self options:nil].firstObject;
    [downloadInfoView showInView:self.view cancelHandler:^{
        
        [weakSelf.downloadTool cancelDownloadTask];
        
        for (UIButton *btn in self.headArray) {
            btn.selected = NO;
        }
    }];
    
    [self.downloadTool addDownloadTask:fileArray isCollected:isFav isRearCameraFile:self.isRearCameraFile updateHandler:^(APKDVRFile *targetFile) {
        
        NSString *info = [NSString stringWithFormat:@"%@ (%d/%d)",targetFile.name,(int)([fileArray indexOfObject:targetFile] + 1),(int)fileArray.count];
        downloadInfoView.downloadInfoLabel.text = info;
        
    } progressHandler:^(float progress,NSString *progressMsg) {
        
        downloadInfoView.progressView.progress = progress;
        NSString *progressInfo = [NSString stringWithFormat:@"%.1f%%",progress * 100.f];
        downloadInfoView.progressLabel.text = progressInfo;
        downloadInfoView.progressLabel2.text = progressMsg;
        
    } completionHandler:^(NSArray *failureTaskArray) {
        
        [downloadInfoView dismiss];
        [weakSelf clickSelectButton:weakSelf.selectButton];
    }];
}

- (void)deleteDVRFileWithIndexPathArray:(NSArray *)indexPathArray{
    
    __block NSMutableArray *allIndexArr = [NSMutableArray array];
    __block NSMutableArray *fileArray = [[NSMutableArray alloc] init];
    BOOL isHaveLockFile = NO;
    for (NSIndexPath *indexPath in indexPathArray) {
        
        APKDVRFile *file = self.dataArray[indexPath.section][indexPath.row];
        if ([file.attr isEqualToString:@"RW"]){
            
            NSMutableArray *allFiles = [self getAllFiles];
            if (allFiles.count == 1){
                
                [fileArray addObject:file];
                [allIndexArr addObject:indexPath];
            }else{
                
                if (self.isHaveRearCamera == YES) {
                    
                    NSInteger fileIndex = [allFiles indexOfObject:file];
                    if (fileIndex == 0){
                        
                        APKDVRFile *rightFile = allFiles[1];
                        if ([file.date compare:rightFile.date] == NSOrderedSame && ![fileArray containsObject:rightFile]){
                            
                            [fileArray addObject:rightFile];
                            NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
                            [allIndexArr addObject:path];
                        }
                    }else if (fileIndex + 1 == allFiles.count){
                        
                        APKDVRFile *leftFile = allFiles[fileIndex - 1];
                        if ([file.date compare:leftFile.date] == NSOrderedSame && ![fileArray containsObject:leftFile]){
                            
                            [fileArray addObject:leftFile];
                            NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
                            [allIndexArr addObject:path];
                        }
                    }else{
                        
                        APKDVRFile *leftFile = allFiles[fileIndex - 1];
                        if ([file.date compare:leftFile.date] == NSOrderedSame && ![fileArray containsObject:leftFile]){
                            
                            [fileArray addObject:leftFile];
                            NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
                            [allIndexArr addObject:path];
                        }
                        
                        APKDVRFile *rightFile = allFiles[fileIndex + 1];
                        if ([file.date compare:rightFile.date] == NSOrderedSame && ![fileArray containsObject:rightFile]){
                            
                            [fileArray addObject:rightFile];
                            NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
                            [allIndexArr addObject:path];
                        }
                    }
                    
                    if (![fileArray containsObject:file]){
                        
                        [fileArray addObject:file];
                        [allIndexArr addObject:indexPath];
                    }
                    
                }else{
                    
                    [fileArray addObject:file];
                    [allIndexArr addObject:indexPath];
                }
            }
        }
        else{
            isHaveLockFile = YES;
        }
    }
    
    void (^confirmHandler)(UIAlertAction *action)  = ^(UIAlertAction *action){
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        __weak typeof(self)weakSelf = self;
        [self.deleteTool deleteWithFileArray:fileArray completionHandler:^(NSArray *failureTaskArray) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [hud hideAnimated:YES];
                
                /*
                if (failureTaskArray.count == 0) {
                    
                    [weakSelf.dataSource removeObjectsInArray:fileArray];
//                    [weakSelf.collectionView deleteItemsAtIndexPaths:indexPathArray];
                    [self combinDVRData:self.dataSource];
                    [self.collectionView reloadData];
                    
                }else{
                    
                    [fileArray removeObjectsInArray:failureTaskArray];
                    [weakSelf.dataSource removeObjectsInArray:fileArray];//删除已经成功删除的数据
//                    [weakSelf.collectionView reloadData];
                    [self combinDVRData:self.dataSource];
                    [self.collectionView reloadData];
                    
                    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"%d个文件删除失败！", nil),(int)failureTaskArray.count];
                    [APKAlertTool showAlertInViewController:weakSelf message:message];
                }*/
                
                [weakSelf.dataSource removeObjectsInArray:fileArray];
                
                for (int i = 0; i < allIndexArr.count; i++)
                {
                    NSIndexPath *path = allIndexArr[i];
                    
                    @try {
                        // 可能会出现崩溃的代码
                        NSMutableArray *arr = self.dataArray[path.section];
                        [arr removeObject:fileArray[i]];
                    }
                    @catch (NSException *exception) {
                        // 捕获到的异常exception
                    }
                    @finally {
                        // 结果处理
                        NSLog(@"➡️➡️➡️删除出现异常❕❕❕");
                    }
                }
                
                NSMutableArray *array = [NSMutableArray array];
                for (NSMutableArray *arr in self.dataArray) {
                    
                    if (arr.count != 0)
                        [array addObject:arr];
                    
                }
                self.dataArray = [NSMutableArray arrayWithArray:array];
                [self.collectionView reloadData];
                [weakSelf updateFooterView];
                [weakSelf clickSelectButton:weakSelf.selectButton];
            });
        }];
    };
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"删除%d个文件？", nil),(int)indexPathArray.count];
    [APKAlertTool showAlertInViewController:self title:nil message:message handler:confirmHandler];
}

- (void)refreshPage{
    
    if (self.requestState == kAPKRequestDVRFileStateNone) {
        
        self.requestState = kAPKRequestDVRFileStateRefreshPage;
        self.isNoMoreFiles = NO;
        [self.dataSource removeAllObjects];
        [self.dataArray removeAllObjects];
        [self.collectionView reloadData];
        self.selectCount = 0;
        [self requestFileList];
        
    }else{
        
        [self.refreshControl endRefreshing];
    }
}

- (void)requestFileList{
    
    [APKDVR sharedInstance].requestDataType = kAPKDVRFileTypePhoto;
    
    MBProgressHUD *hud = nil;
    if (self.dataSource.count == 0 && !self.refreshControl.isRefreshing) {
        
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    __weak typeof(self)weakSelf = self;
    
    APKRequestDVRFileFailureBlock failureBlock = ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (weakSelf.refreshControl.isRefreshing) [weakSelf.refreshControl endRefreshing];
            if (hud) [hud hideAnimated:YES];
            weakSelf.requestState = kAPKRequestDVRFileStateNone;
            [weakSelf.collectionView reloadData];
        });
    };
    
    
    APKRequestDVRFileSuccessBlock successBlock = ^(NSArray<APKDVRFile *> *fileArray){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSArray *frontArray = [NSArray arrayWithArray:fileArray];
            
            weakSelf.isRearCameraFile = YES;
            [weakSelf.requestDVRFileTool requestDVRFileWithCount:2000 fromIndex:weakSelf.dataSource.count successBlock:^(NSArray<APKDVRFile *> *fileArray) {
                
                if (weakSelf.refreshControl.isRefreshing) [weakSelf.refreshControl endRefreshing];
                if (hud) [hud hideAnimated:YES];
                
                BOOL isPull;
                isPull = weakSelf.requestState == kAPKRequestDVRFileStateLoadMore ? YES : NO;
                weakSelf.requestState = kAPKRequestDVRFileStateNone;
                
                if (fileArray.count == 0) {
                    weakSelf.isNoMoreFiles = YES;
                }
                
                for (int i = 0;i < frontArray.count; i ++) {
                    
                    APKDVRFile *DvrFile = frontArray[i];
                    if (![self.dataSource containsObject:DvrFile])
                        [weakSelf.dataSource addObject:DvrFile];
                    
                    if (fileArray.count > i)
                        [weakSelf.dataSource addObject:fileArray[i]];
                }
                
//                [weakSelf.dataSource addObjectsFromArray:fileArray];
                //            [weakSelf.collectionView insertItemsAtIndexPaths:indexPaths];
                
                if (isPull) {//解决数据源被清空
                    [self.dataArray removeAllObjects];
                }
                
                [self loadRecentFiles];
                self.isRearCameraFile = NO;
                
                [weakSelf.collectionView reloadData];
                
                [weakSelf updateFooterView];
                
            } failureBlock:^{
                
            }];
            
      
        });
    };

    
    [self.taskTool setDVRWithProperty:@"Playback" value:@"enter" completionHandler:^(BOOL success) {
        
        if (success) {
            
            [weakSelf.requestDVRFileTool requestDVRFileWithCount:2000 fromIndex:weakSelf.dataSource.count successBlock:successBlock failureBlock:failureBlock];//每次取九个数据
        }
        else{
            
            failureBlock();
        }
    }];
}

-(void)loadRecentFiles
{
    [self combinDVRData:self.dataSource]; //合并相同日期数据
    NSMutableArray *allFiles = [self getAllFiles];
    NSMutableArray *recentFiles = [NSMutableArray array];
    NSInteger num = allFiles.count >= 10 ? 10 : allFiles.count;
    if (num == 0) return;
    for (int i = 0; i < num; i++) {
        [recentFiles addObject:allFiles[i]];
    }
    [self.dataArray removeAllObjects];
    [self combinDVRData:recentFiles]; //合并相同日期数据
}

-(void)loadAllFiles
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10];
    [arr addObjectsFromArray:self.dataSource];
    [self combinDVRData:arr]; //合并相同日期数据
    NSMutableArray *allFiles = [self getAllFiles];
    [self.dataArray removeAllObjects];
    [self.dataArray addObject:allFiles];
}

-(void)loadCustomFiles
{
    NSMutableArray *Arr = [NSMutableArray array];
    for (APKDVRFile *dvrFile in self.dataSource) {
        
        NSDate *fileDate = dvrFile.date;
        
        int beginState = [self compareOneDay:self.beginDate withAnotherDay:fileDate];
        int endState = [self compareOneDay:self.endDate withAnotherDay:fileDate];
        if (beginState == -1 && endState == 1) {
            
            [Arr addObject:dvrFile];
        }
    }
    [self combinDVRData:Arr];
    [self.collectionView reloadData];
}

-(NSMutableArray *)getAllFiles
{
    NSMutableArray *files = [NSMutableArray array];
    for (NSArray *arr in self.dataArray) {
        for (APKDVRFile *file in arr) {
            [files addObject:file];
        }
    }
    return files;
}

#pragma mark - APKDVRPhotoCellDelegate

- (void)beganLongPressAPKDVRPhotoCell:(APKDVRPhotoCell *)cell{
    
    //此处需要把indexpath保存起来，因为变成多选模式并刷新列表后，用该Cell找到的IndexPath会变化！
    self.longPressIndexPath = [self.collectionView indexPathForCell:cell];
    [self clickSelectButton:self.selectButton];
}

- (void)endedLongPressAPKDVRPhotoCell:(APKDVRPhotoCell *)cell{
    
    [self.collectionView selectItemAtIndexPath:self.longPressIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    self.longPressIndexPath = nil;
    self.selectCount += 1;
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    
    return self.photos.count;
}
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    
    MWPhoto *photo = self.photos[index];
    return photo;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index{
    
    APKDVRFile *file = self.dataSource[index];
    if (!file.previewPath) {
        
        if (!self.downloadTool.downloadPreviewPhotoCompletionHandler) {
            
            __weak typeof(self) weakSelf = self;
            self.downloadTool.downloadPreviewPhotoCompletionHandler = ^(APKDVRFile *file){
                
                if (!weakSelf.photoBrowser) return;
                
                NSInteger index  = [weakSelf.dataSource indexOfObject:file];
                UIImage *image = [UIImage imageWithContentsOfFile:file.previewPath];
                MWPhoto *photo = [MWPhoto photoWithImage:image];
                [weakSelf.photos replaceObjectAtIndex:index withObject:photo];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [weakSelf.photoBrowser reloadData];
                });
            };
        }
        
        [self.downloadTool addPreviewPhotoTask:file];
    }
}

- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index{
    
    MWPhoto *photo = self.photos[index];
    APKDVRPhotoCaptionView *captionView = [[APKDVRPhotoCaptionView alloc] initWithPhoto:photo];
    captionView.customDelegate = self;
    
    APKDVRFile *dvrFile = self.dataSource[index];
    [captionView configureViewWithDVRFile:dvrFile];
    
    return captionView;
}

#pragma mark APKDVRPhotoCaptionViewDelegate
- (void)APKDVRPhotoCaptionView:(APKDVRPhotoCaptionView *)captionView didClickDeleteButton:(UIButton *)sender{
    
    void (^confirmHandler)(UIAlertAction *action)  = ^(UIAlertAction *action){
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        
        NSInteger index = self.photoBrowser.currentIndex;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        APKDVRFile *file = self.dataSource[indexPath.row];
        __weak typeof(self)weakSelf = self;
        [self.deleteTool deleteWithFileArray:@[file] completionHandler:^(NSArray *failureTaskArray) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [hud hideAnimated:YES];
                if (failureTaskArray.count == 0) {
                    
                    [self.dataArray removeAllObjects];
                    [weakSelf.dataSource removeObject:file];
                    [self combinDVRData:self.dataSource];
                    [weakSelf.collectionView reloadData];
                    
                    MWPhoto *photo = weakSelf.photos[index];
                    [weakSelf.photos removeObject:photo];
                    if (weakSelf.photos.count == 0) {
                        [weakSelf.photoBrowser.navigationController dismissViewControllerAnimated:YES completion:nil];
                    }else{
                        [weakSelf.photoBrowser reloadData];
                        [weakSelf photoBrowser:weakSelf.photoBrowser didDisplayPhotoAtIndex:weakSelf.photoBrowser.currentIndex];
                    }
                    
                }else{
                    
                    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"%d个文件删除失败！", nil),1];
                    [APKAlertTool showAlertInViewController:weakSelf message:message];
                }
            });
        }];
    };
    
    [APKAlertTool showAlertInViewController:self.photoBrowser title:nil message:NSLocalizedString(@"删除该文件？", nil)  handler:confirmHandler];
}

- (void)APKDVRPhotoCaptionView:(APKDVRPhotoCaptionView *)captionView didClickDownloadButton:(UIButton *)sender{
    
    self.haveRefreshLocalFiles = YES;
    [self saveImageWithCaptionView:captionView shouldCollect:NO];
}

#pragma mark utilities

- (void)saveImageWithCaptionView:(APKDVRPhotoCaptionView *)captionView shouldCollect:(BOOL)shouldCollect{
    
    APKDVRFile *file = self.dataSource[self.photoBrowser.currentIndex];
    MWPhoto *photo = self.photos[self.photoBrowser.currentIndex];
    if (!photo.underlyingImage) {
        return;
    }
    
    if (shouldCollect && file.isDownloaded) {
        
        __weak typeof(self)weakSelf = self;
        [self.refreshLocalFilesTool.context performBlock:^{
            
            LocalFile *localFile = [LocalFile getLocalFileWithName:file.name context:weakSelf.refreshLocalFilesTool.context];
            localFile.isCollected = YES;
            [weakSelf.refreshLocalFilesTool.context save:nil];
//            file.isCollected = YES;
            [weakSelf.collectionView reloadData];
            [captionView configureViewWithDVRFile:file];
        }];
        
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.photoBrowser.navigationController.view animated:YES];
    __weak typeof(self) weakSelf = self;
    [self.downloadTool savePhoto:file image:photo.underlyingImage isCollected:shouldCollect isRearCameraFile:self.isRearCameraFile completionHandler:^(NSArray *failureTaskArray) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [hud hideAnimated:YES];
            if (failureTaskArray.count == 0) {
                
                [weakSelf.collectionView reloadData];
                [captionView configureViewWithDVRFile:file];
                
            }else{
                
                [APKAlertTool showAlertInViewController:weakSelf.photoBrowser message:NSLocalizedString(@"保存失败！", nil)];
            }
        });
    }];
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView.allowsMultipleSelection) {
        self.selectCount -= 1;
        return;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView.allowsMultipleSelection) {
        
        self.selectCount += 1;
        return;
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    [self.photos removeAllObjects];
    for (APKDVRFile *file in self.dataSource) {
        
        UIImage *image = nil;
        if (file.previewPath) {
            image = [UIImage imageWithContentsOfFile:file.previewPath];
        }else if (file.thumbnailPath) {
            image = [UIImage imageWithContentsOfFile:file.thumbnailPath];
        }else{
            image = [UIImage imageNamed:@"photos_floder"];
        }
        MWPhoto *photo = [MWPhoto photoWithImage:image];
        [self.photos addObject:photo];
    }
    
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    photoBrowser.alwaysShowControls = YES;
    photoBrowser.displayActionButton = NO;
    [photoBrowser setCurrentPhotoIndex:indexPath.row];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:photoBrowser];
    navi .modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navi animated:YES completion:nil];
    self.photoBrowser = photoBrowser;
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    NSArray *array = self.dataArray[section];
    
    return array.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"dvrPhotoCell";
    
    APKDVRPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    APKDVRFile *file = self.dataArray[indexPath.section][indexPath.row];
    [cell configureCellWithFile:file];
    
    UIColor *colorOne = [UIColor redColor];
    UIColor *colorTwo = [UIColor yellowColor];
    UIColor *colorThree = [UIColor orangeColor];
    UIColor *colorFour = [UIColor greenColor];
    if ([file.name containsString:@"F."]) _colorCount ++;
    if (indexPath.row == 0 && indexPath.section == 0) _colorCount = 0;
    switch (_colorCount) {
        case 0:
            cell.colorView.backgroundColor = colorOne;
            break;
        case 1:
            cell.colorView.backgroundColor = colorTwo;
            break;
        case 2:
            cell.colorView.backgroundColor = colorThree;
            break;
        case 3:
            cell.colorView.backgroundColor = colorFour;
            break;
        default:
            cell.colorView.backgroundColor = colorOne;
            _colorCount = 0;
            break;
    }
    cell.delegate = self;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if (kind == UICollectionElementKindSectionHeader) {
        
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerViewIdentifier forIndexPath:indexPath];
        
        for (UIView *view in headerView.subviews) { [view removeFromSuperview]; }//解决头视图重叠
            
        headerView.backgroundColor = [UIColor blackColor];
        
        UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 20)];
        
        NSArray *sectionDataArray = self.dataArray[indexPath.section];
        if (sectionDataArray.count == 0) return headerView;
        APKDVRFile *theFile = sectionDataArray[indexPath.row];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];//将日期转化为字符串
        [df setDateFormat:@"yyyy-MM-dd"];
        NSString * s1 = [df stringFromDate:theFile.date];
        time.text = s1;
        time.textColor = [UIColor whiteColor];
        [headerView addSubview:time];
    
        UILabel *detailTime = [self setDVRDetailtimeL:indexPath];
        [headerView addSubview:detailTime];
    
        UIButton *allSelectButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-40, 0, 24, 24)];
        [allSelectButton setBackgroundImage:[UIImage imageNamed:@"icon_album_res_checkbox_off"] forState:UIControlStateNormal];
        [allSelectButton setBackgroundImage:[UIImage imageNamed:@"icon_album_res_checkbox_on"] forState:UIControlStateSelected];
        allSelectButton.tag = indexPath.section;
        [allSelectButton addTarget:self action:@selector(allSelecteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:allSelectButton];
        [self.headArray addObject:allSelectButton];
        
        return headerView;
       
        
    } else { // 返回每一组的尾部视图
        UICollectionReusableView *footerView =  [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:headerViewIdentifier forIndexPath:indexPath];
        
        footerView.backgroundColor = [UIColor purpleColor];
        return footerView;
    }
}

-(void)allSelecteButtonClick:(UIButton*)Btn
{
    Btn.selected = !Btn.selected;
    NSArray *seletedArray = self.dataArray[Btn.tag];
    self.selectCount = Btn.selected ? seletedArray.count : 0;
    self.collectionView.allowsMultipleSelection = YES;
    if (Btn.selected) {
        for (int i = 0; i < seletedArray.count; i++) {
            
            [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:Btn.tag] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            self.bottomBarBottomConstraint.constant = 0;
            self.selectCount = seletedArray.count;
        }
    }else
    {
        for (int i = 0; i < seletedArray.count; i++) {
            
            CGFloat bottomBarHeight = CGRectGetHeight(self.bottomBar.frame);
            self.bottomBarBottomConstraint.constant = -bottomBarHeight;
            [self.collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:Btn.tag] animated:NO];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return (CGSize){self.view.bounds.size.width,20};
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return (CGSize){self.view.bounds.size.width,0};
}

- (void)updateFooterView{
    
    if (self.footerView) {
        
        if (self.requestState == kAPKRequestDVRFileStateLoadMore) {
            [self.footerView.flower startAnimating];
        }else{
            [self.footerView.flower stopAnimating];
        }
        if (self.isNoMoreFiles) {
            
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"共有%d个文件", nil),(int)self.dataSource.count];
            self.footerView.label.text = msg;
            
        }else{
            
            self.footerView.label.text = nil;
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
//    if (self.requestState == kAPKRequestDVRFileStateNone && self.dataSource.count != 0 && !self.isNoMoreFiles) {
//        
//        CGFloat x = 0;//x是触发操作的阀值
//        if (scrollView.contentOffset.y >= fmaxf(.0f, scrollView.contentSize.height - scrollView.frame.size.height) + x)
//        {
//            self.requestState = kAPKRequestDVRFileStateLoadMore;
//            if (self.footerView) {
//                [self.footerView.flower startAnimating];
//            }
//            [self requestFileList];
//        }
//    }
}

#pragma mark - event response

- (IBAction)clickDownloadButton:(UIButton *)sender {
    
    NSArray *indexPaths = self.collectionView.indexPathsForSelectedItems;
    NSMutableArray *fileArray = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in indexPaths) {
        
        APKDVRFile *file = self.dataArray[indexPath.section][indexPath.row];
        if (!file.isDownloaded) {
            [fileArray addObject:file];
        }
    }
    
    if (fileArray.count == 0) {
        
        [self clickSelectButton:self.selectButton];
        return;
    }
    
    self.haveRefreshLocalFiles = YES;
    [self download:fileArray isFav:NO];
}

- (IBAction)clickDeleteButton:(UIButton *)sender {
    
    [self deleteDVRFileWithIndexPathArray:self.collectionView.indexPathsForSelectedItems];
}

- (IBAction)clickSelectButton:(UIButton *)sender {
    
    if ([sender.titleLabel.text isEqualToString:NSLocalizedString(@"选择", nil)]) {
        
        [sender setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
        self.checkAllButton.hidden = NO;
        self.bottomBarBottomConstraint.constant = 0;
        self.haveCheckAll = NO;
//        self.titleLabel.hidden = YES;
        self.titleLabel.frame = CGRectMake(20, CGRectGetMinY(self.titleLabel.frame), CGRectGetWidth(self.titleLabel.frame), CGRectGetHeight(self.titleLabel.frame));
        self.collectionView.allowsMultipleSelection = YES;
        
    }else{
        
        [sender setTitle:NSLocalizedString(@"选择", nil) forState:UIControlStateNormal];
        self.checkAllButton.hidden = YES;
        CGFloat bottomBarHeight = CGRectGetHeight(self.bottomBar.frame);
        self.bottomBarBottomConstraint.constant = -bottomBarHeight;
        self.titleLabel.hidden = NO;
        self.titleLabel.frame = self.titleLabel.frame = CGRectMake(self.view.center.x - CGRectGetWidth(self.titleLabel.frame)/2, CGRectGetMinY(self.titleLabel.frame), CGRectGetWidth(self.titleLabel.frame), CGRectGetHeight(self.titleLabel.frame));
        self.selectCount = 0;
        self.collectionView.allowsMultipleSelection = NO;
        [self.collectionView reloadData];
    }
    
//    self.collectionView.allowsMultipleSelection = !self.collectionView.allowsMultipleSelection;
    
}

- (IBAction)clickCheckAllButton:(UIButton *)sender {
    
    if (self.haveCheckAll) {
        
        for (int i = 0; i < self.dataArray.count; i++) {
            
            NSMutableArray *oneArray = self.dataArray[i];
            
            for ( int j = 0; j < oneArray.count; j++) {
                
                NSIndexPath *index = [NSIndexPath indexPathForRow:j inSection:i];
                [self.collectionView deselectItemAtIndexPath:index animated:NO];
            }
        }
        self.selectCount = 0;
        
        for (UIButton *btn in self.headArray) {
            
            btn.selected = NO;
        }
        
    }else{
        
        for (int i = 0; i < self.dataArray.count; i++) {
            
            NSMutableArray *oneArray = self.dataArray[i];
            
            for ( int j = 0; j < oneArray.count; j++) {
                
                NSIndexPath *index = [NSIndexPath indexPathForRow:j inSection:i];
                [self.collectionView selectItemAtIndexPath:index animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            }
            
        }
        
        for (UIButton *btn in self.headArray) {
            
            btn.selected = YES;
        }
        self.selectCount = self.dataSource.count;
    }
    
    self.haveCheckAll = !self.haveCheckAll;
}

- (IBAction)clickQuitButton:(UIButton *)sender {
    
    [self.taskTool setDVRWithProperty:@"Playback" value:@"exit" completionHandler:^(BOOL success) {
        
    }];
    [self.navigationController popViewControllerAnimated:YES];
}

static int classifytype = 0;
- (IBAction)clickClassifyButtonAction:(UIButton *)sender {
    
    _colorCount = 0;
    
    for (UIButton *btn in self.classifyButton) {
        
        btn.selected = NO;
        btn.backgroundColor = [UIColor blackColor];
    }
    sender.selected = YES;
    sender.backgroundColor = [UIColor brownColor];
    [self.dataArray removeAllObjects];
    switch (sender.tag) {
        case 100:
//            classifytype = 0;
//            self.isRequestGroupData = NO;
//            [self refreshPage];
//            self.requestDVRFileTool.isRequestAll = NO;
            [self loadRecentFiles];
            break;
        case 101:
//            classifytype = 1;
//            [self refreshPage];
//            self.requestDVRFileTool.isRequestAll = NO;
//            self.isRequestGroupData = YES;
            [self combinDVRDataWithGoup:self.dataSource];
            break;
        case 102:
//            classifytype = 2;
//            self.isRequestGroupData = NO;
//            self.requestDVRFileTool.isRequestAll = YES;
//            [self refreshPage];
            [self loadAllFiles];
            break;
        default:
            classifytype = 3;
            self.isRequestGroupData = NO;
            __weak typeof (self) weakSelf = self;
            self.timeView.confirmTimeBlock = ^(NSDate *beginDate, NSDate *endDate) {
                
                weakSelf.beginDate = beginDate;
                weakSelf.endDate = endDate;
//                [weakSelf refreshPage];
                [weakSelf loadCustomFiles];
                
            };
            [self.view addSubview:self.timeView];
            return;
    }
    [self.collectionView reloadData];
    [self.timeView removeFromSuperview];
}

#pragma mark - setter

- (void)setSelectCount:(NSInteger)selectCount{
    
    _selectCount = selectCount;
    
    if (selectCount == 0) {
        
        self.deleteButton.enabled = NO;
        self.downloadButton.enabled = NO;
        
    }else{
        
        self.deleteButton.enabled = YES;
        self.downloadButton.enabled = YES;
    }
}

#pragma mark - getter

- (APKCommonTaskTool *)taskTool{
    
    if (!_taskTool) {
        
        _taskTool = [[APKCommonTaskTool alloc] init];
    }
    
    return _taskTool;
}

- (APKRefreshLocalFilesTool *)refreshLocalFilesTool{
    
    if (!_refreshLocalFilesTool) {
        _refreshLocalFilesTool = [APKRefreshLocalFilesTool sharedInstace];
    }
    return _refreshLocalFilesTool;
}

- (NSMutableArray *)photos{
    
    if (!_photos) {
        
        _photos = [[NSMutableArray alloc] init];
    }
    return _photos;
}

- (APKDeleteDVRFileTool *)deleteTool{
    
    if (!_deleteTool) {
        
        _deleteTool = [[APKDeleteDVRFileTool alloc] initWithManagedObjectContext:self.refreshLocalFilesTool.context];
    }
    
    return _deleteTool;
}

- (APKDownloadDVRFileTool *)downloadTool{
    
    if (!_downloadTool) {
        
        _downloadTool = [[APKDownloadDVRFileTool alloc] initWithManagedObjectContext:self.refreshLocalFilesTool.context];
    }
    
    return _downloadTool;
}

- (APKRequestDVRFileTool *)requestDVRFileTool{
    
    _requestDVRFileTool = [[APKRequestDVRFileTool alloc] initWithFileType:kAPKDVRFileTypePhoto isRearCameraFile:self.isRearCameraFile managedObjectContext:self.refreshLocalFilesTool.context];
    return _requestDVRFileTool;
}

- (NSMutableArray *)dataSource{
    
    if (!_dataSource) {
        
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}
    
-(APKDVRTimeSelectView *)timeView
{
    if (!_timeView) {
        _timeView = [[NSBundle mainBundle] loadNibNamed:@"APKDVRTimeSelectView" owner:nil options:nil].firstObject;
        _timeView.frame = self.collectionView.frame;
        [self.view addSubview:_timeView];
    }
    return _timeView;
}

-(NSMutableArray *)headArray
{
    if (!_headArray) {
        _headArray = [NSMutableArray array];
    }
    return _headArray;
}

@end
