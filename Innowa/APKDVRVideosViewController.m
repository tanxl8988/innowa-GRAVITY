//
//  APKDVRVideosViewController.m
//  Innowa
//
//  Created by Mac on 17/4/26.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKDVRVideosViewController.h"
#import "APKDVRVideoCell.h"
#import "APKCustomTabBarController.h"
#import "APKRequestDVRFileTool.h"
#import "APKDownloadDVRFileTool.h"
#import "APKDeleteDVRFileTool.h"
#import "MBProgressHUD.h"
//#import "LocalFile.h"
#import "APKVideoPlayer.h"
#import "APKDownloadInfoView.h"
#import "APKAlertTool.h"
#import "APKCommonTaskTool.h"
#import "vidioColletionCell.h"
#import "UIImageView+AFNetworking.h"
#import "APKDVRVideoPlayer.h"
#import "APKDVRTimeSelectView.h"
#import "APKDVRFile.h"
#import "APKDVR.h"

typedef enum : NSUInteger {
    kAPKRequestDVRFileStateNone,
    kAPKRequestDVRFileStateRefreshPage,//刷新页面（下拉刷新）
    kAPKRequestDVRFileStateLoadMore,//上拉加载更多
} APKRequestDVRFileState;

@interface APKDVRVideosViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,APKVideoPlayerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UIButton *checkAllButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *flower;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBarBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (strong,nonatomic) UIRefreshControl *refreshControl;
@property (strong,nonatomic) APKRequestDVRFileTool *requestDVRFrontFileTool;//被self持有，和self一起释放
@property (strong,nonatomic) APKRequestDVRFileTool *requestDVRRearFileTool;
@property (strong,nonatomic) APKDownloadDVRFileTool *downloadTool;
@property (strong,nonatomic) APKDeleteDVRFileTool *deleteTool;
@property (strong,nonatomic) NSMutableArray *dataSource;
@property (assign) APKRequestDVRFileState requestState;
@property (nonatomic, assign) BOOL isNoMoreFiles;
@property (assign) BOOL haveCheckAll;
@property (assign) BOOL haveRefreshLocalFiles;
@property (nonatomic) NSInteger selectCount;
@property (strong,nonatomic) APKRefreshLocalFilesTool *refreshLocalFilesTool;
@property (strong,nonatomic) APKCommonTaskTool *taskTool;
@property (nonatomic,assign) CGRect previousTitleLRect;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *typeButtons;
@property (nonatomic,retain) APKDVRTimeSelectView *timeView;
@property (nonatomic,assign) BOOL isHaveRearCamera;
@property (nonatomic,assign) BOOL isRequestGroupData;
@property (nonatomic,retain) NSMutableArray *headArray;
@property (nonatomic,retain) NSDate *beginDate;
@property (nonatomic,retain) NSDate *endDate;
@property (nonatomic) BOOL isSeletedRow;


@end

@implementation APKDVRVideosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"vidioColletionCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"head"];
    
    if (self.fileType == kAPKDVRFileTypeVideo) {
        if ([self.albumTitle isEqualToString:NSLocalizedString(@"视频", nil)]) {
            self.titleLabel.text = NSLocalizedString(@"视频", nil);
        }else{
            self.titleLabel.text = self.isRearCameraFile ? NSLocalizedString(@"DVR后镜头视频列表", nil) : NSLocalizedString(@"DVR前镜头视频列表",nil);
        }
        self.titleLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"DVR", nil),NSLocalizedString(@"视频", nil)];
    }else if (self.fileType == kAPKDVRFileTypeEvent){
        if ([self.albumTitle isEqualToString:NSLocalizedString(@"DVR事件视频", nil)]) {
            self.titleLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"DVR", nil),NSLocalizedString(@"事件", nil)];

        }else{
            self.titleLabel.text = self.isRearCameraFile ? NSLocalizedString(@"DVR后镜头事件列表", nil) : NSLocalizedString(@"DVR前镜头事件列表",nil);
        }
        self.titleLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"DVR", nil),NSLocalizedString(@"事件", nil)];
    }else if (self.fileType == kAPKDVRFileTypeParkTime){
        
        if ([self.albumTitle isEqualToString:NSLocalizedString(@"DVR停车时间视频", nil)]) {
            self.titleLabel.text = NSLocalizedString(@"缩时录影", nil);
        }
        self.titleLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"DVR", nil),NSLocalizedString(@"缩时录影", nil)];

    }else if (self.fileType == kAPKDVRFileTypeParkEvent){
        
        if ([self.albumTitle isEqualToString:NSLocalizedString(@"DVR停车事件视频", nil)]) {
            self.titleLabel.text = NSLocalizedString(@"泊车模式事件", nil);
        }
        self.titleLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"DVR", nil),NSLocalizedString(@"泊车模式事件", nil)];

    }
    
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    if (screenWidth > 320) {
        self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    }else{
        self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    }
    
    [self.selectButton setTitle:NSLocalizedString(@"选择", nil) forState:UIControlStateNormal];
    [self.checkAllButton setTitle:NSLocalizedString(@"全选", nil) forState:UIControlStateNormal];
    self.checkAllButton.hidden = YES;
    
    CGFloat bottomBarHeight = CGRectGetHeight(self.bottomBar.frame);
    self.bottomBarBottomConstraint.constant = -bottomBarHeight;
    
    self.previousTitleLRect = self.titleLabel.frame;
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshPage) forControlEvents:UIControlEventValueChanged];
//    [self.collectionView addSubview:self.refreshControl];
    [self.collectionView sendSubviewToBack:self.refreshControl];

    [self refreshPage];
    
    colorCount = 0;
    
    requestIndex = 0;
    requestCount = 8;
    
    UIButton *recentButton = (UIButton*)self.typeButtons[0];
    recentButton.backgroundColor = [UIColor brownColor];
    
    self.collectionView.allowsMultipleSelection = NO;
    NSString *btnTitle = @"";
    for (int i = 0;i < self.typeButtons.count; i++) {
        
        UIButton *btn = self.typeButtons[i];
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

- (void)refreshPage{
    
    if (self.requestState == kAPKRequestDVRFileStateNone) {
        
        self.requestState = kAPKRequestDVRFileStateRefreshPage;
        self.isNoMoreFiles = NO;
        [self updateFooterView];
        [self.dataSource removeAllObjects];
        [self.dataArray removeAllObjects];
        [self.collectionView reloadData];
        self.selectCount = 0;
        [self requestFileList];
        
    }else{
        
        [self.refreshControl endRefreshing];
    }
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
        if (self.fileType == kAPKDVRFileTypeVideo) {
            [self.refreshLocalFilesTool updateVideoCount];
        }else if (self.fileType == kAPKDVRFileTypeEvent){
            [self.refreshLocalFilesTool updateEventCount];
        }
    }
    
//    [self.taskTool setDVRWithProperty:@"Playback" value:@"enter" completionHandler:^(BOOL success) {
//        NSLog(@"");
//    }];
    
}

- (void)dealloc{
    NSLog(@"%s",__func__);
}

#pragma mark - private method

- (void)download:(NSMutableArray *)fileArray isFav:(BOOL)isFav{
    
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
        
        /*
        [fileArray removeObject:failureTaskArray];//移除下载失败的数据
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (APKDVRFile *file in fileArray) {
            
            NSInteger index = [weakSelf.dataSource indexOfObject:file];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [indexPaths addObject:indexPath];
        }
        [weakSelf.collectionView reloadItemsAtIndexPaths:indexPaths];*/
        
        [weakSelf.collectionView reloadData];
        
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
    
    if (isHaveLockFile == YES) {
        
        if (fileArray.count == 0) {
            [APKAlertTool showAlertInViewController:self message:NSLocalizedString(@"請先在記錄儀內解除保護檔案", nil)];
            return;
        }
    }
    
    if (fileArray.count == 0) return;
    
    void (^confirmHandler)(UIAlertAction *action)  = ^(UIAlertAction *action){
        
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        __weak typeof(self)weakSelf = self;
        [self.deleteTool deleteWithFileArray:fileArray completionHandler:^(NSArray *failureTaskArray) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [hud hideAnimated:YES];
                /*
                if (failureTaskArray.count == 0) {
                    
                    fileArray = [self getAllFileArray:indexPathArray];
                    [weakSelf.dataSource removeObjectsInArray:fileArray];
                    
                    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
                    for (int i = 0; i < indexPathArray.count; i++) {
                        NSIndexPath *path = indexPathArray[i];
                        NSMutableArray *arr = self.dataArray[path.section];
                        [arr removeObject:arr[path.row]];
                        if (arr.count == 0) {
//                            [self.dataArray removeObjectAtIndex:path.section];
                            [indexSet addIndex:path.section];
                        }
                    }
                    [self.collectionView deleteItemsAtIndexPaths:indexPathArray];
                    
                    [self.dataArray removeObjectsAtIndexes:indexSet];
                    [self.collectionView deleteSections:indexSet];
                    
                }else{
                    
                    [fileArray removeObjectsInArray:failureTaskArray];
                    [weakSelf.dataSource removeObjectsInArray:fileArray];
                    [self.dataArray removeAllObjects];
//                    [weakSelf.tableView reloadData];
                    [self combinDVRData:self.dataSource];
                    [self.collectionView reloadData];
                    
//                    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"%d个文件删除失败！", nil),(int)failureTaskArray.count];
//                    [APKAlertTool showAlertInViewController:weakSelf message:message];
                }*/
                
//                fileArray = [self getAllFileArray:indexPathArray];
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
                
//                [weakSelf.tableView endUpdates];
                [weakSelf updateFooterView];
                if (weakSelf.collectionView.allowsMultipleSelection) {
                    [weakSelf clickSelectButton:weakSelf.selectButton];
                }
            });
        }];
    };
    
    
    if (isHaveLockFile == YES) {
        [APKAlertTool showAlertInViewController:self title:nil message:NSLocalizedString(@"請先在記錄儀內解除保護檔案", nil) handler:^(UIAlertAction *action) {
            
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"删除%d个文件？", nil),(int)allIndexArr.count];
            [APKAlertTool showAlertInViewController:self title:nil message:message handler:confirmHandler];
        }];
    }else{
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"删除%d个文件？", nil),(int)fileArray.count];
        [APKAlertTool showAlertInViewController:self title:nil message:message handler:confirmHandler];
    }
}



- (void)updateFooterView{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.isNoMoreFiles) {
            
            NSString *info = [NSString stringWithFormat:NSLocalizedString(@"共有%d个文件", nil),(int)self.dataSource.count];
            self.tipsLabel.text = info;
            
        }else{
            
            self.tipsLabel.text = nil;
        }
        
        if (self.requestState == kAPKRequestDVRFileStateLoadMore) {
            
            [self.flower startAnimating];
        }else{
            
            [self.flower stopAnimating];
        }
    });
}


static int requestIndex = 0;
static int requestCount = 8;
static int RequestMoreTime = 2;
- (void)requestFileList{//请求列表数据
    
    [APKDVR sharedInstance].requestDataType = kAPKDVRFileTypeVideo;
    
    MBProgressHUD *hud = nil;
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak typeof(self)weakSelf = self;
    APKRequestDVRFileSuccessBlock successBlock = ^(NSArray<APKDVRFile *> *fileArray){
        
        NSArray *frontArray = [NSArray arrayWithArray:fileArray];
        [weakSelf.dataSource addObjectsFromArray:frontArray];
        
        [weakSelf.requestDVRRearFileTool requestDVRFileWithCount:2000 fromIndex:requestIndex successBlock:^(NSArray<APKDVRFile *> *fileArray) {
            
//            NSMutableArray *rearArray = [NSMutableArray array];
//            for (APKDVR *file in fileArray) {
//                if (![rearArray containsObject:file]) {
//                    [rearArray addObject:fileArray];
//                }
//            }
            
            if (fileArray.count > 0)
                self.isHaveRearCamera = YES;
            
            NSMutableArray *rearFiles = [NSMutableArray array];
            for (int i = 0; i < fileArray.count; i++) {
                
                APKDVRFile *file = fileArray[i];
                if (i > 0) {
                    APKDVRFile *lastFile = fileArray[i - 1];
                    if (![lastFile.originalName isEqualToString:file.originalName]) {
                        [rearFiles addObject:file];
                    }
                }else
                    [rearFiles addObject:file];
            }
            
            [weakSelf.dataSource addObjectsFromArray:rearFiles];

                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (weakSelf.requestState == kAPKRequestDVRFileStateRefreshPage) [weakSelf.refreshControl endRefreshing];
                    
                    BOOL isPull;
                    isPull = weakSelf.requestState == kAPKRequestDVRFileStateLoadMore ? YES : NO;
                    
                    weakSelf.requestState = kAPKRequestDVRFileStateNone;
                    
                    if (frontArray.count == 0)
                    {
                        weakSelf.isNoMoreFiles = YES;//new add

                    }
                    
                    requestIndex = fileArray.count == 0 ? (int)weakSelf.dataSource.count : (int)self.dataSource.count/2;
                    requestCount = fileArray.count == 0 ? 4 : 8;
                    
                    if (isPull) [weakSelf.dataArray removeAllObjects];//解决数据源被清空导致头视图复用失败
                    
                    if (weakSelf.dataSource.count == 0) {
                        RequestMoreTime--;
                        if (RequestMoreTime > 0) //没拉到数据多拉一次
                            [weakSelf refreshPage];
                        else
                            RequestMoreTime = 1;
                        
                        [hud hideAnimated:YES];
                        return;
                    }
                    
                    
                    [weakSelf loadRecentFiles];
                    [weakSelf.collectionView reloadData];
                    
                    if (hud) [hud hideAnimated:YES];
                });
        } failureBlock:^{
            
        }];
    };
    
    
    APKRequestDVRFileFailureBlock failureBlock = ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (weakSelf.requestState == kAPKRequestDVRFileStateRefreshPage) {
                [weakSelf.refreshControl endRefreshing];
            }
            weakSelf.requestState = kAPKRequestDVRFileStateNone;
            
            [weakSelf.collectionView reloadData];
            [weakSelf updateFooterView];
            if (hud) [hud hideAnimated:YES];
        });
    };
    
    
    
    [self.taskTool setDVRWithProperty:@"Playback" value:@"enter" completionHandler:^(BOOL success) {
        
        if (successBlock) {
            //请求列表
            [weakSelf.requestDVRFrontFileTool requestDVRFileWithCount:2000 fromIndex:requestIndex successBlock:successBlock failureBlock:failureBlock];
        }
        else{
            
            failureBlock();
        }
    }];

}

-(void)loadRecentFiles
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10];//recent只能显示10个最近的数据
    [arr addObjectsFromArray:self.dataSource];
    [self combinDVRData:arr]; //合并相同日期数据
    
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
        
        if ([dvrFile.date compare:self.beginDate] == NSOrderedDescending && [dvrFile.date compare:self.endDate] == NSOrderedAscending) {
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

#pragma mark ---- UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataArray.count;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *array = self.dataArray[section];
    return array.count;
}

static int colorCount = 0;
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *colorOne = [UIColor redColor];
    UIColor *colorTwo = [UIColor yellowColor];
    UIColor *colorThree = [UIColor orangeColor];
    UIColor *colorFour = [UIColor greenColor];
    
    vidioColletionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    NSArray *sectionDataArray = self.dataArray[indexPath.section];
    APKDVRFile *theFile = sectionDataArray[indexPath.row];
    
    UIImage *image = nil;
    if (theFile.thumbnailPath) {
        image = [UIImage imageWithContentsOfFile:theFile.thumbnailPath];
    }
    if (!image) {
        image = [UIImage imageNamed:@"photos_floder"];
    }
    cell.imageView.image = image;
    cell.detailL.text = theFile.name;
    cell.sizeL.text = theFile.size;
    cell.lockImage.hidden = ![theFile.attr isEqualToString:@"RW"] ? NO : YES;
    
    if (theFile.isDownloaded)
        cell.downloadImageView.hidden = NO;
    else
        cell.downloadImageView.hidden = YES;
    
//    if (indexPath.row % 2 == 0 && indexPath.row != 0) colorCount ++;
    if ([theFile.name containsString:@"F."]) colorCount ++;
    if (indexPath.row == 0 && indexPath.section == 0) colorCount = 0;

    switch (colorCount) {
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
            colorCount = 0;
            break;
    }
    
//    if (self.isHaveRearCamera == NO) {
//        cell.colorView.backgroundColor = [UIColor blackColor];
//    }
    
    cell.seletedImage.hidden = YES;
    cell.collectImage.hidden = YES;
    cell.index = indexPath;
    
    __weak typeof(self)weakSelf = self;
    cell.cellSelected = ^(BOOL isSelected, BOOL showSelectdButton, NSIndexPath *index, vidioColletionCell *cell) {
        if (showSelectdButton) {
            
            if ([weakSelf.selectButton.titleLabel.text isEqualToString:NSLocalizedString(@"选择", nil)]) {
                
                self.selectCount = 1;
                static NSIndexPath *indexP;
                indexP = [NSIndexPath indexPathForItem:index.row inSection:index.section];
                [weakSelf clickSelectedButton:weakSelf.selectButton];
                [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:NO block:^(NSTimer * _Nonnull timer) {
                    
                    [weakSelf.collectionView selectItemAtIndexPath:indexP animated:YES scrollPosition:UICollectionViewScrollPositionNone];
                    indexP = nil;
                }];
            }else return;
        }
    };
    
    
    return cell;
}

-(void)clickSelectedButton:(UIButton*)button
{
    if ([button.titleLabel.text isEqualToString:NSLocalizedString(@"选择", nil)]) {//选择
        
        [button setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
        self.checkAllButton.hidden = NO;
        self.bottomBarBottomConstraint.constant = 0;
        self.haveCheckAll = NO;
        self.titleLabel.hidden = YES;
        //        self.isSelectButtonClick = YES;
        
    }else{
        
        [button setTitle:NSLocalizedString(@"选择", nil) forState:UIControlStateNormal];//取消
        self.checkAllButton.hidden = YES;
        CGFloat bottomBarHeight = CGRectGetHeight(self.bottomBar.frame);
        self.bottomBarBottomConstraint.constant = -bottomBarHeight;
        self.titleLabel.hidden = NO;
        //        self.isLongPress = NO;
        self.selectCount = 0;
        //        self.isSelectButtonClick = NO;
    }
    self.collectionView.allowsMultipleSelection = !self.collectionView.allowsMultipleSelection;
    [self.collectionView reloadData];
    
}


// 和UITableView类似，UICollectionView也可设置段头段尾
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    if([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"head" forIndexPath:indexPath];
        
        for (UIView *view in headerView.subviews) { [view removeFromSuperview]; }//解决头视图重叠
        
        headerView.backgroundColor = [UIColor blackColor];
        
        UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 20)];
        time.textColor = [UIColor whiteColor];
        
        NSArray *sectionDataArray = self.dataArray[indexPath.section];
        APKDVRFile *theFile = sectionDataArray[indexPath.row];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];//将日期转化为字符串
        [df setDateFormat:@"yyyy-MM-dd"];
        NSString * s1 = [df stringFromDate:theFile.date];
        time.text = s1;
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
    }
    return nil;
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


#pragma mark ---- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (CGSize){(self.view.bounds.size.width-20)/4,120};
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(4, 4, 4, 4);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 4.f;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 4.f;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return (CGSize){self.view.bounds.size.width,20};
}




#pragma mark ---- UICollectionViewDelegate

// 选中某item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (collectionView.allowsMultipleSelection) {
        self.selectCount += 1;
        
        [self.selectButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
        self.checkAllButton.hidden = NO;
        self.bottomBarBottomConstraint.constant = 0;
        self.haveCheckAll = NO;
        //        self.titleLabel.hidden = YES;
        self.titleLabel.frame = CGRectMake(20, CGRectGetMinY(self.titleLabel.frame), CGRectGetWidth(self.titleLabel.frame), CGRectGetHeight(self.titleLabel.frame));
        return;
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (NSArray *arr in self.dataArray) {
        
//        file.isRearCameraFile = self.isRearCameraFile;
        for (APKDVRFile *file in arr) {
            [items addObject:file];
        }
    }

    APKDVRFile *file = self.dataArray[indexPath.section][indexPath.row];
    NSUInteger index = [items indexOfObject:file];
    
//    NSArray *indexPaths = self.collectionView.indexPathsForSelectedItems;
    
    APKDVRVideoPlayer *videoPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"APKDVRVideoPlayer"];
    [videoPlayer setupWithDvrItems:items delegate:self downloadTool:self.downloadTool deleteTool:self.deleteTool currentIndex:index];
    videoPlayer.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:videoPlayer animated:YES completion:nil];
    
    //在视频播放器内有可能删除文件
    self.haveRefreshLocalFiles = YES;
}

#pragma mark 取消选中
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"didDeselectItemAtIndexPath");
    
    if (collectionView.allowsMultipleSelection) {
        
        self.selectCount -= 1;
    }

}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (self.requestState == kAPKRequestDVRFileStateNone && self.dataSource.count != 0 && !self.isNoMoreFiles) {
        
        CGFloat x = 0;//x是触发操作的阀值
        if (scrollView.contentOffset.y >= fmaxf(.0f, scrollView.contentSize.height - scrollView.frame.size.height) + x)
        {
//            self.requestState = kAPKRequestDVRFileStateLoadMore;
//
//            [self updateFooterView];
//            [self requestFileList];
        }
    }
}



#pragma mark - APKVideoPlayerDelegate

- (void)APKVideoPlayer:(APKVideoPlayer *)videoPlayer deleteFileArr:(NSMutableArray *)deleteFileArr{
    
    for (UIButton *btn in self.typeButtons) {
        
        btn.selected = NO;
        btn.backgroundColor = [UIColor blackColor];
    }
    UIButton *btn = self.typeButtons[2];
    btn.selected = YES;
    btn.backgroundColor = [UIColor brownColor];
    
    [self.dataSource removeObjectsInArray:deleteFileArr];
    [self.dataArray removeAllObjects];
    [self combinDVRData:self.dataSource];
    [self.collectionView reloadData];
    
    [self updateFooterView];
}

- (void)APKVideoPlayer:(APKVideoPlayer *)videoPlayer didDownloadFile:(APKDVRFile *)file{
    
    [self.collectionView reloadData];
}

#pragma mark - actions

- (IBAction)clickSelectButton:(UIButton *)sender {
    
    if ([sender.titleLabel.text isEqualToString:NSLocalizedString(@"选择", nil)]) {
        
        [sender setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
        self.checkAllButton.hidden = NO;
        self.bottomBarBottomConstraint.constant = 0;
        self.haveCheckAll = NO;
//        self.titleLabel.hidden = YES;
        self.titleLabel.frame = CGRectMake(-20, CGRectGetMinY(self.titleLabel.frame), CGRectGetWidth(self.titleLabel.frame), CGRectGetHeight(self.titleLabel.frame));
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

- (IBAction)clickDownloadButton:(UIButton *)sender {
    
    NSArray *indexPaths = self.collectionView.indexPathsForSelectedItems;
    NSMutableArray *fileArray = [[NSMutableArray alloc] init];
    
    /*
    if (!self.isHaveRearCamera) {
        
        for (NSIndexPath *index in indexPaths) {
            
            APKDVRFile *file = self.dataArray[index.section][index.row];
            if (!file.isDownloaded) {
                [fileArray addObject:file];
            }
        }
    }else
    {
        fileArray = [self getAllFileArray:indexPaths];
    }*/
    
    for (NSIndexPath *index in indexPaths) {
        
        APKDVRFile *file = self.dataArray[index.section][index.row];
        if (!file.isDownloaded) {
            [fileArray addObject:file];
        }
    }
    
    [self clickSelectButton:self.selectButton];
    if (fileArray.count > 0) {
        
        self.haveRefreshLocalFiles = YES;
        [self download:fileArray isFav:NO];
    }
}
- (IBAction)clickPlayButtonAction:(UIButton *)sender {
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    NSArray *indexArr = self.collectionView.indexPathsForSelectedItems;
    
    for (NSIndexPath *path in indexArr) {
        
        APKDVRFile *file = self.dataArray[path.section][path.row];
        [items addObject:file];
    }
    
    NSMutableArray *playItems = [NSMutableArray array];
    if (items.count > 0) {
        
        NSArray *timeSortortArr = [self sortFileWithdate:items];
        NSMutableArray *nameSortArr = [self changeFAndRFile:timeSortortArr];
        playItems = [NSMutableArray arrayWithArray:nameSortArr];
    }
    
    APKDVRVideoPlayer *videoPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"APKDVRVideoPlayer"];
    [videoPlayer setupWithDvrItems:playItems delegate:self downloadTool:self.downloadTool deleteTool:self.deleteTool currentIndex:0];
    [self presentViewController:videoPlayer animated:YES completion:nil];
    
    //在视频播放器内有可能删除文件
    self.haveRefreshLocalFiles = YES;
    
}

- (IBAction)clickDeleteButton:(UIButton *)sender {
    
    [self deleteDVRFileWithIndexPathArray:self.collectionView.indexPathsForSelectedItems];
}


- (IBAction)clickDataSouceTypeButton:(UIButton *)sender {
    
    requestIndex = 0;
    colorCount = 0;
    
    for (UIButton *btn in self.typeButtons) {
        
        btn.selected = NO;
        btn.backgroundColor = [UIColor blackColor];
    }
    sender.selected = YES;
    sender.backgroundColor = [UIColor brownColor];
    
    [self.dataArray removeAllObjects];
    switch (sender.tag) {
        case 100:
            [self loadRecentFiles];
            break;
        case 101:
//            self.selectType = APkGroupType;
//            [self refreshPage];
//            self.requestDVRFrontFileTool.isRequestAll = YES;
//            self.requestDVRRearFileTool.isRequestAll = YES;
            [self combinDVRDataWithGoup:self.dataSource];
            break;
        case 102:
//            self.selectType = APkAllType;
//            self.requestDVRFrontFileTool.isRequestAll = YES;
//            self.requestDVRRearFileTool.isRequestAll = YES;
//            [self refreshPage];
            [self loadAllFiles];
            break;
        default:
        {
//            self.selectType = APkCustomType;
//            self.requestDVRFrontFileTool.isRequestAll = YES;
//            self.requestDVRRearFileTool.isRequestAll = YES;
            __weak typeof (self) weakSelf = self;
            self.timeView.confirmTimeBlock = ^(NSDate *beginDate, NSDate *endDate) {
              
                if ([beginDate compare:endDate] == NSOrderedDescending) {
                    
                    [APKAlertTool showAlertInViewController:weakSelf message:NSLocalizedString(@"結束時間不可早於開始時間，請重新設定", nil)];
                    return;
                }
                
                weakSelf.beginDate = beginDate;
                weakSelf.endDate = endDate;
//                [weakSelf refreshPage];
                [weakSelf loadCustomFiles];
            };
            [self.view addSubview:self.timeView];
            return;
        }
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

- (APKRequestDVRFileTool *)requestDVRFrontFileTool{
    
    if (!_requestDVRFrontFileTool) {
    
        _requestDVRFrontFileTool = [[APKRequestDVRFileTool alloc] initWithFileType:self.fileType isRearCameraFile:NO managedObjectContext:self.refreshLocalFilesTool.context];
    }
    return _requestDVRFrontFileTool;
}

-(APKRequestDVRFileTool *)requestDVRRearFileTool
{
    if (!_requestDVRRearFileTool) {
        _requestDVRRearFileTool = [[APKRequestDVRFileTool alloc] initWithFileType:self.fileType isRearCameraFile:YES managedObjectContext:self.refreshLocalFilesTool.context];
    }
    
    return _requestDVRRearFileTool;
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

- (IBAction)recentL:(id)sender {
}
@end
