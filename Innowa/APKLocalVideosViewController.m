//
//  APKLocalVideosViewController.m
//  Innowa
//
//  Created by Mac on 17/4/27.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKLocalVideosViewController.h"
#import "MBProgressHUD.h"
#import <CoreData/CoreData.h>
#import "APKCustomTabBarController.h"
#import "APKLocalVideoCell.h"
#import <Photos/Photos.h>
#import "APKShareTool.h"
#import "APKCachingThumbnailTool.h"
#import "APKVideoPlayer.h"
#import "vidioColletionCell.h"
#import "APKAlertTool.h"
#import "APKLocalVidioCutViewController.h"
#import "APKLocalVidioEditTool.h"
#import "APKDownloadDVRFileTool.h"

@interface APKLocalVideosViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *collectionBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UIButton *checkAllButton;
@property (weak, nonatomic) IBOutlet UIButton *collectButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBarBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *arrowsButon;
@property (strong,nonatomic) NSFetchedResultsController *fetchedReslutsController;
@property (assign) BOOL haveCheckAll;
@property (assign) BOOL haveRefreshLocalFiles;
@property (nonatomic) NSInteger selectCount;
@property (strong,nonatomic) APKCachingThumbnailTool *cachingThumbnailTool;
@property (strong,nonatomic) NSMutableDictionary *assetInfo;
@property (strong,nonatomic) APKRefreshLocalFilesTool *refreshLocalFilesTool;
@property (nonatomic) NSInteger numberOfCollectedFiles;
@property (nonatomic,retain) APKLocalVidioEditTool *vidioEditTool;
@property (nonatomic,retain) APKDownloadDVRFileTool *downloadTool;
@property (nonatomic,assign) CGRect previousTitleLRect;
@property (nonatomic,assign) BOOL rotateValue;
@property (nonatomic,retain) NSMutableArray *dataSourceArray;
@property (nonatomic,assign) BOOL isFileBackScheduling;
@property (nonatomic,assign) int colorCount;
@end

@implementation APKLocalVideosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.collectionBtn setTitle:NSLocalizedString(@"收藏", nil) forState:UIControlStateNormal];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"vidioColletionCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"head"];
    
    CGFloat bottomBarHeight = CGRectGetHeight(self.bottomBar.frame);
    self.bottomBarBottomConstraint.constant = -bottomBarHeight;
    
    self.checkAllButton.hidden = YES;
    [self.selectButton setTitle:NSLocalizedString(@"选择", nil) forState:UIControlStateNormal];
    [self.checkAllButton setTitle:NSLocalizedString(@"全选", nil) forState:UIControlStateNormal];
    
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    if (screenWidth > 320) {
        self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    }else{
        self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    }
    
    if (self.fileType == kAPKDVRFileTypeVideo) {
        if ([self.albumTitle isEqualToString:NSLocalizedString(@"视频", nil)]) {
            self.titleLabel.text = NSLocalizedString(@"视频", nil);
        }else{
            self.titleLabel.text = NSLocalizedString(@"视频", nil);
        }
        self.titleLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"本地", nil),NSLocalizedString(@"视频", nil)];

    }else if (self.fileType == kAPKDVRFileTypeEvent){
        if ([self.albumTitle isEqualToString:NSLocalizedString(@"事件", nil)]) {
            self.titleLabel.text = NSLocalizedString(@"事件", nil);
        }else{
            self.titleLabel.text = NSLocalizedString(@"事件", nil);
        }
        self.titleLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"本地", nil),NSLocalizedString(@"事件", nil)];

    }else if (self.fileType == kAPKDVRFileTypeParkTime){
        if ([self.albumTitle isEqualToString:NSLocalizedString(@"停车时间视频", nil)]) {
            self.titleLabel.text = NSLocalizedString(@"缩时录影", nil);
        }else{
            self.titleLabel.text = NSLocalizedString(@"缩时录影", nil);
        }
        self.titleLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"本地", nil),NSLocalizedString(@"缩时录影", nil)];

    }else if (self.fileType == kAPKDVRFileTypeParkEvent){
        if ([self.albumTitle isEqualToString:NSLocalizedString(@"停车事件视频", nil)]) {
            self.titleLabel.text = NSLocalizedString(@"泊车模式事件", nil);
        }else{
            self.titleLabel.text = NSLocalizedString(@"泊车模式事件", nil);
        }
        self.titleLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"本地", nil),NSLocalizedString(@"泊车模式事件", nil)];

    }else if (self.fileType == kAPKDVRFileTypeVidioEdit){
        if ([self.albumTitle isEqualToString:NSLocalizedString(@"编辑", nil)]) {
            self.titleLabel.text = NSLocalizedString(@"编辑", nil);
        }else{
            self.titleLabel.text = NSLocalizedString(@"编辑", nil);
        }
        self.titleLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"本地", nil),NSLocalizedString(@"编辑", nil)];

    }

    self.selectCount = 0;
    
    self.previousTitleLRect = self.titleLabel.frame;
    
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskPortrait;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.dataArray removeAllObjects];
    
    APKCustomTabBarController *tabBarVC = (APKCustomTabBarController *)self.tabBarController;
    tabBarVC.customTabBar.hidden = YES;
    
    [self.dataSourceArray removeAllObjects];
    
    [self setupFetchedReslutsController];
    [self.dataSourceArray setArray:self.fetchedReslutsController.fetchedObjects];
    
    CGSize thumbnailSize = CGSizeMake(80, 48);
    self.cachingThumbnailTool = [[APKCachingThumbnailTool alloc] initWithThumbNailSize:thumbnailSize];
    [self startCachingThumbnail];
    
    if (self.dataSourceArray.count > 0) {
        [self combinData:self.dataSourceArray isBackScheduling:NO]; //合并相同日期数据
        NSArray *fileArray = self.dataArray.firstObject;
        LocalFile *file = fileArray.firstObject;
        NSString *time = [self getTimeLabelString:file.saveDate];
        self.timeLabel.text = time;
    }
    
     [self.collectionView reloadData];
}

-(NSString*)getTimeLabelString:(NSDate*)date
{
    NSDate *currentDate = date;
    if (!currentDate) {
        currentDate = [NSDate date];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    return dateString;
}
- (IBAction)arrowsButtonClick:(UIButton *)sender {
    
    NSInteger rotatValue = self.rotateValue;
    [UIView animateWithDuration:0.5f animations:^{
        
        CGFloat rotateAngle = 0;
        switch (rotatValue) {
            case 0:
                rotateAngle = M_PI;
                self.rotateValue = YES;
                break;
                
            default:
                rotateAngle = 0;
                self.rotateValue = NO;
                break;
        }
        
        [sender setTransform:CGAffineTransformMakeRotation(rotateAngle)];
    }];
    
    NSMutableArray *NewDataArray = [NSMutableArray array];
    NSArray *dataSourceArray = self.dataSourceArray;
    if (dataSourceArray.count > 0) {
        
        for (int i = (int)dataSourceArray.count - 1; i >= 0; i--) [NewDataArray addObject:dataSourceArray[i]];
    }
    self.isFileBackScheduling = !self.isFileBackScheduling;
    [self combinData:NewDataArray isBackScheduling:self.isFileBackScheduling];
    [self.collectionView reloadData];
    [self.dataSourceArray setArray:NewDataArray];
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
}

- (void)dealloc
{
    [self.cachingThumbnailTool stopCaching];
    NSLog(@"%s",__func__);
}

#pragma mark - setter

- (void)setSelectCount:(NSInteger)selectCount{
    
    _selectCount = selectCount;
    
    if (selectCount == 0) {
        
        self.numberOfCollectedFiles = 0;

        self.deleteButton.enabled = NO;
        self.shareButton.enabled = NO;
        
        self.collectButton.selected = NO;
        self.collectButton.enabled = NO;
        
        
    }else{
        
        self.deleteButton.enabled = YES;
        self.shareButton.enabled = YES;
        
        self.collectButton.selected = self.numberOfCollectedFiles == selectCount;
        self.collectButton.enabled = YES;
    }
}

#pragma mark - getter

- (APKRefreshLocalFilesTool *)refreshLocalFilesTool{
    
    if (!_refreshLocalFilesTool) {
        _refreshLocalFilesTool = [APKRefreshLocalFilesTool sharedInstace];
    }
    return _refreshLocalFilesTool;
}

- (NSMutableDictionary *)assetInfo{
    
    if (!_assetInfo) {
        _assetInfo = [[NSMutableDictionary alloc] init];
    }
    return _assetInfo;
}

-(APKLocalVidioEditTool*)vidioEditTool
{
    if (!_vidioEditTool) {
        _vidioEditTool = [[APKLocalVidioEditTool alloc] init];
    }
    return _vidioEditTool;
}

- (APKDownloadDVRFileTool *)downloadTool{
    
    if (!_downloadTool) {
        
        _downloadTool = [[APKDownloadDVRFileTool alloc] initWithManagedObjectContext:self.refreshLocalFilesTool.context];
    }
    
    return _downloadTool;
}

-(NSMutableArray *)dataSourceArray
{
    if (!_dataSourceArray) _dataSourceArray = [NSMutableArray array];
    return _dataSourceArray;
}

#pragma mark - private method

- (void)startCachingThumbnail{
    
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    NSMutableArray *identifiers = [[NSMutableArray alloc] init];
    for (LocalFile *file in self.dataSourceArray) {
        [identifiers addObject:file.identifier];
    }
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:identifiers options:nil];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PHAsset *asset = obj;
        [assets addObject:asset];
        [self.assetInfo setObject:asset forKey:asset.localIdentifier];
        
    }];
    
    [self.cachingThumbnailTool startCachingWithAssets:assets];//缓存图片
}

- (void)delete:(NSArray *)fileArray completionHandler:(void(^)(BOOL success))completionHandler{
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        NSMutableArray *assets = [[NSMutableArray alloc] init];
        for (LocalFile *file in fileArray) {
            PHAsset *asset = [self.assetInfo objectForKey:file.identifier];
            [assets addObject:asset];
        }
        [PHAssetChangeRequest deleteAssets:assets];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        completionHandler(success);
    }];
}

- (void)setupFetchedReslutsController{
    
    NSSortDescriptor *saveDateSort = [NSSortDescriptor sortDescriptorWithKey:@"saveDate" ascending:NO];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %d AND isFromRearCamera == %d",(int16_t)self.fileType,self.isRearCameraFile];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %d AND isFromRearCamera BETWEEN {0,1}",(int16_t)self.fileType];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"LocalFile"];
    request.sortDescriptors = @[saveDateSort];
    request.predicate = predicate;
    
    self.fetchedReslutsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.refreshLocalFilesTool.context sectionNameKeyPath:nil cacheName:nil];
    self.fetchedReslutsController.delegate = self;
    NSError *error;
    [self.fetchedReslutsController performFetch:&error];
    NSAssert(!error, error.localizedDescription);
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


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    vidioColletionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    NSArray *sectionDataArray = self.dataArray[indexPath.section];
    LocalFile *theFile = sectionDataArray[indexPath.row];
    
    PHAsset *asset = [self.assetInfo objectForKey:theFile.identifier];
    [self.cachingThumbnailTool requestThumbnailForAsset:asset resultHandler:^(UIImage *thumbnail) {//获得asset视频第一帧
        
        cell.imageView.image = thumbnail;
        
    }];
    cell.detailL.text = theFile.name;
    cell.seletedImage.hidden = YES;
    cell.collectImage.hidden = !theFile.isCollected;
    cell.lockImage.hidden = YES;
    cell.index = indexPath;
//    cell.colorView.backgroundColor = [UIColor blackColor];
    
    UIColor *colorOne = [UIColor redColor];
    UIColor *colorTwo = [UIColor yellowColor];
    UIColor *colorThree = [UIColor orangeColor];
    UIColor *colorFour = [UIColor greenColor];
    
    //    if (indexPath.row % 2 == 0 && indexPath.row != 0) colorCount ++;
    if ([theFile.name containsString:@"F."]) _colorCount ++;
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
    
    //    cell.selectdButton.selected = self.haveCheckAll ? YES : NO;
    
    //    cell.selectdButton.hidden = self.isSelectButtonClick || self.isLongPress ? NO : YES;
    
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
//        self.titleLabel.hidden = YES;
        self.titleLabel.frame = CGRectMake(-100, CGRectGetMinY(self.titleLabel.frame), CGRectGetWidth(self.titleLabel.frame), CGRectGetHeight(self.titleLabel.frame));
        //        self.isSelectButtonClick = YES;
        
    }else{
        
        [button setTitle:NSLocalizedString(@"选择", nil) forState:UIControlStateNormal];//取消
        self.checkAllButton.hidden = YES;
        CGFloat bottomBarHeight = CGRectGetHeight(self.bottomBar.frame);
        self.bottomBarBottomConstraint.constant = -bottomBarHeight;
        self.titleLabel.frame = _previousTitleLRect;
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
        
        NSArray *sectionDataArray = self.dataArray[indexPath.section];
        LocalFile *theFile = sectionDataArray[indexPath.row];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];//将日期转化为字符串
        [df setDateFormat:@"yyyy-MM-dd"];
        NSString * s1 = [df stringFromDate:theFile.saveDate];
        time.text = s1,time.textColor = [UIColor whiteColor];
        [headerView addSubview:time];
        
        UILabel *detailTime = [self setDetailtimeL:indexPath];
        detailTime.textColor = [UIColor whiteColor];
        [headerView addSubview:detailTime];
        
        return headerView;
    }
    
    return nil;
}




#pragma mark ---- UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (CGSize){(self.view.bounds.size.width-20)/3,120};
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.f;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.f;
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
        LocalFile *file = self.dataArray[indexPath.section][indexPath.row];
        if (file.isCollected) {
            self.numberOfCollectedFiles++;
        }
        self.selectCount += 1;
        return;
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (LocalFile *file in self.dataSourceArray) {
        
        APKVideoPlayerLocalItem *item = [[APKVideoPlayerLocalItem alloc] init];
        item.file = file;
        item.asset = [self.assetInfo objectForKey:file.identifier];
        [items addObject:item];
    }
    
    __weak typeof(self)weakSelf = self;
    APKVideoPlayer *videoPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"APKVideoPlayer"];
    [videoPlayer vidioPlayerWithIndexPath:indexPath andMergeVidioBlock:^(NSIndexPath *indexPath) {
        [weakSelf.selectButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
        weakSelf.checkAllButton.hidden = NO;
        weakSelf.bottomBarBottomConstraint.constant = 0;
        weakSelf.haveCheckAll = NO;
        weakSelf.collectionView.allowsMultipleSelection = !weakSelf.collectionView.allowsMultipleSelection;
        weakSelf.titleLabel.frame = CGRectMake(20, CGRectGetMinY(weakSelf.titleLabel.frame), CGRectGetWidth(weakSelf.titleLabel.frame), CGRectGetHeight(weakSelf.titleLabel.frame));
        [weakSelf.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    }];
    
    LocalFile *file = self.dataArray[indexPath.section][indexPath.row];
    NSInteger index = [self.dataSourceArray indexOfObject:file];
    
    [videoPlayer setupWithLocalItems:items currentIndex:index];
    videoPlayer.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:videoPlayer animated:YES completion:nil];
    
    //在视频播放器内有可能删除文件
    self.haveRefreshLocalFiles = YES;
    
}

#pragma mark 取消选中
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"didDeselectItemAtIndexPath");
    
    if (collectionView.allowsMultipleSelection) {
        
        LocalFile *file = self.dataArray[indexPath.section][indexPath.row];
        if (file.isCollected) {
            self.numberOfCollectedFiles--;
        }
        self.selectCount -= 1;
        return;
    }
}





#pragma mark - actions

- (IBAction)clickQuitButton:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickSelectButton:(UIButton *)sender {
    
    if ([sender.titleLabel.text isEqualToString:NSLocalizedString(@"选择", nil)]) {
        
        [sender setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
        self.checkAllButton.hidden = NO;
        self.bottomBarBottomConstraint.constant = 0;
        self.haveCheckAll = NO;
//        self.titleLabel.hidden = YES;

        self.titleLabel.frame = CGRectMake(-20, CGRectGetMinY(self.titleLabel.frame), CGRectGetWidth(self.titleLabel.frame), CGRectGetHeight(self.titleLabel.frame));
        
    }else{
        
        [sender setTitle:NSLocalizedString(@"选择", nil) forState:UIControlStateNormal];
        self.checkAllButton.hidden = YES;
        CGFloat bottomBarHeight = CGRectGetHeight(self.bottomBar.frame);
        self.bottomBarBottomConstraint.constant = -bottomBarHeight;
        self.titleLabel.frame = self.titleLabel.frame = CGRectMake(self.view.center.x - CGRectGetWidth(self.titleLabel.frame)/2, CGRectGetMinY(self.titleLabel.frame), CGRectGetWidth(self.titleLabel.frame), CGRectGetHeight(self.titleLabel.frame));
        
        self.selectCount = 0;
    }
    
    self.collectionView.allowsMultipleSelection = !self.collectionView.allowsMultipleSelection;
    [self.collectionView reloadData];
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
        
    }else{
        
        self.numberOfCollectedFiles = 0;
        
        for (int i = 0; i < self.dataArray.count; i++) {
            
            NSMutableArray *oneArray = self.dataArray[i];
            
            for ( int j = 0; j < oneArray.count; j++) {
                
                NSIndexPath *index = [NSIndexPath indexPathForRow:j inSection:i];
                [self.collectionView selectItemAtIndexPath:index animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                
                LocalFile *file = self.dataArray[index.section][index.row];
                if (file.isCollected) {
                    self.numberOfCollectedFiles++;
                }
            }
            
        }
        
        self.selectCount = self.fetchedReslutsController.fetchedObjects.count;
    }
    
    self.haveCheckAll = !self.haveCheckAll;
}

- (IBAction)clickDeleteButton:(UIButton *)sender {
    
    self.haveRefreshLocalFiles = YES;
    
    NSArray *indexPaths = self.collectionView.indexPathsForSelectedItems;
    
    if (indexPaths.count == 0) return;
    
    NSMutableArray *fileArray = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in indexPaths)
        [fileArray addObject:self.dataArray[indexPath.section][indexPath.row]];
    
    [self delete:fileArray completionHandler:^(BOOL success) {
        
        if (success) {
            [self.refreshLocalFilesTool.context performBlock:^{
                
                for (LocalFile *file in fileArray) {
                    
                    [self.refreshLocalFilesTool.context deleteObject:file];
                    [self.assetInfo removeObjectForKey:file.identifier];
                }
                [self.refreshLocalFilesTool.context save:nil];
                [self clickSelectButton:self.selectButton];
            }];
            
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue,^{
                
                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.dataArray];
                for (NSMutableArray *array in self.dataArray) {
                    
                    for (LocalFile *file in fileArray) {
                        
                        if ([array containsObject:file])
                            [array removeObject:file];
                    }
                }
                
                for (NSMutableArray *array in tempArray) {
                    
                    if (array.count == 0)
                        [self.dataArray removeObject:array];//数组不能同时遍历同时修改
                }
                [self.collectionView reloadData];
            });
        }
        
    }];
}

- (IBAction)clickCollectButton:(UIButton *)sender {
    
    self.haveRefreshLocalFiles = YES;
    
    NSArray *indexPaths = self.collectionView.indexPathsForSelectedItems;
    
    if (indexPaths.count == 0) return;
    
    NSMutableArray *collectArray = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in indexPaths) {
        LocalFile *file = self.dataArray[indexPath.section][indexPath.row];
        [collectArray addObject:file];
    }
    
    [self.refreshLocalFilesTool.context performBlock:^{
        
        for (LocalFile *theFile in collectArray) {
            
            theFile.isCollected = !theFile.isCollected;
        }
        
        [self.refreshLocalFilesTool.context save:nil];
        [self clickSelectButton:self.selectButton];
    }];
}

- (IBAction)clickColletionFileButton:(UIButton *)sender {
    
    NSMutableArray *collectionFiles = [NSMutableArray array];
    for (LocalFile *file in self.dataSourceArray) {
        
        if (file.isCollected == YES)
            [collectionFiles addObject:file];
    }
    
    [self combinData:collectionFiles isBackScheduling:NO];
    [self.collectionView reloadData];
}


- (IBAction)clickCutVidioButton:(UIButton *)sender {
    
    self.haveRefreshLocalFiles = YES;
    
    NSArray *indexPaths = self.collectionView.indexPathsForSelectedItems;
    
    if (indexPaths.count == 0) return;
    
    if (indexPaths.count > 1) {
        
        [APKAlertTool showAlertInViewController:self message:NSLocalizedString(@"只能裁剪一个视频", nil)];
        
        return;
    }
    
    if (indexPaths.count == 1) {
        
        NSIndexPath *indexPath = indexPaths.firstObject;
        
        __block LocalFile *file = self.dataArray[indexPath.section][indexPath.row];
        
        PHAsset *asset = [self.assetInfo objectForKey:file.identifier];
        
        __weak typeof(self)weakSelf = self;
        
        [self.cachingThumbnailTool getVidioAsset:asset resultHandler:^(NSString *url) {
            
            APKLocalVidioCutViewController *VC = [APKLocalVidioCutViewController new];
            
            VC.fileUrl = url;
            
            VC.localFile = file;
            
            [weakSelf presentViewController:VC animated:NO completion:^{
                nil;
            }];
        }];
    }
    
}
- (IBAction)clickCombineVidioButton:(UIButton *)sender {
    
    self.haveRefreshLocalFiles = YES;
    
    __block  NSArray *indexPaths = self.collectionView.indexPathsForSelectedItems;
    
    if (indexPaths.count < 2)  return;
    
    __weak typeof(self)weakSelf = self;
    __block NSMutableArray *assetArray = [NSMutableArray array];

    NSString *fileName = [self getCurrentTime];
    
    for (NSIndexPath *indexPath in indexPaths) {
        
        LocalFile *file = self.dataArray[indexPath.section][indexPath.row];
        PHAsset *asset = [self.assetInfo objectForKey:file.identifier];
        
        [self.cachingThumbnailTool getVidioAsset:asset resultHandler:^(NSString *url) {
            
            [assetArray addObject:url];
            
            if (indexPaths.count == assetArray.count) {
                
                [weakSelf.vidioEditTool mergeVideoToOneVideo:assetArray toStorePath:@"combinVidio" WithStoreName:fileName andIf3D:NO success:^(NSURL *storePath){
                    
                    APKDVRFile *file = [APKDVRFile new];
                    file.type = kAPKDVRFileTypeVidioEdit;
                    NSString *name = [NSString stringWithFormat:@"%@_edit.MOV",fileName];
                    file.name = name;
                    file.date = [NSDate date];
                    
//                    NSData *data = [NSData dataWithContentsOfURL:@""];
                    
                    
                    [weakSelf.downloadTool saveFile:file withUrl:storePath isVidioEdit:YES];
                    
                } failure:^{
                    NSLog(@"no");
                }];
            }
        }];
    }
}

-(NSString *)getCurrentTime
{
    NSDate *date=[NSDate date];
    NSDateFormatter *format1=[[NSDateFormatter alloc] init];
    [format1 setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *dateStr;
    dateStr=[format1 stringFromDate:date];
    return dateStr;
}
- (IBAction)clickPlayButton:(UIButton *)sender {
    
    NSArray *indexpaths = self.collectionView.indexPathsForSelectedItems;
    
    if (indexpaths.count == 0)
    {
        return;
    }
    
    NSIndexPath *index = indexpaths.firstObject;//取第一个数据
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (LocalFile *file in self.dataSourceArray) {
        
        APKVideoPlayerLocalItem *item = [[APKVideoPlayerLocalItem alloc] init];
        item.file = file;
        item.asset = [self.assetInfo objectForKey:file.identifier];
        [items addObject:item];
    }
    
    APKVideoPlayer *videoPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"APKVideoPlayer"];
    [videoPlayer setupWithLocalItems:items currentIndex:index];
    [self presentViewController:videoPlayer animated:YES completion:nil];
    
    //在视频播放器内有可能删除文件
    self.haveRefreshLocalFiles = YES;
}

- (IBAction)clickShareButton:(UIButton *)sender {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSArray *indexpaths = self.collectionView.indexPathsForSelectedItems;
    
    if (indexpaths.count == 0)
    {
        [hud hideAnimated:YES];
        
        return;
    }
    
    
    NSIndexPath *index = indexpaths.firstObject;//取第一个数据
    
    LocalFile *firstFile = self.dataArray[index.section][index.row];
    PHAsset *asset = [self.assetInfo objectForKey:firstFile.identifier];
    [APKShareTool loadShareItemsWithLocalVideoAsset:asset completionHandler:^(BOOL success, NSArray *items) {
        
        [hud hideAnimated:YES];
        if (success) {
            UIActivityViewController *avc = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
            avc.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeAddToReadingList,UIActivityTypePostToTencentWeibo];
            [self presentViewController:avc animated:YES completion:nil];
        }
    }];
    
    [self clickSelectButton:self.selectButton];

}

@end
