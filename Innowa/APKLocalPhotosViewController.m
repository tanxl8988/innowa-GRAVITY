//
//  APKLocalPhotosViewController.m
//  Innowa
//
//  Created by Mac on 17/4/27.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKLocalPhotosViewController.h"
#import "APKLocalPhotoCell.h"
#import "APKPhotosPageFooterView.h"
#import <CoreData/CoreData.h>
#import "APKDVRFile.h"
#import "APKLocalPhotoCaptionView.h"
#import "APKCustomTabBarController.h"
#import "LocalFile.h"
#import "MBProgressHUD.h"
#import <Photos/Photos.h>
#import "MWPhotoBrowser.h"
#import "APKMWPhoto.h"
#import "APKShareTool.h"
#import "APKCachingThumbnailTool.h"

static NSString *headerViewIdentifier = @"headerView";
static NSString *identifier = @"localPhotoCell";

@interface APKLocalPhotosViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,APKLocalPhotoCellDelegate,MWPhotoBrowserDelegate,APKLocalPhotoCaptionViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *collectionBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UIButton *checkAllButton;
@property (weak, nonatomic) IBOutlet UIButton *collectButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBarBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *arrowsbutton;

@property (strong,nonatomic) NSIndexPath *longPressIndexPath;
@property (assign) BOOL haveCheckAll;
@property (strong,nonatomic) NSMutableArray *dataSource;
@property (strong,nonatomic) NSMutableArray *photos;
@property (weak,nonatomic) MWPhotoBrowser *photoBrowser;
@property (weak,nonatomic) APKPhotosPageFooterView *footerView;
@property (assign) BOOL haveRefreshLocalFiles;
@property (nonatomic) NSInteger selectCount;
@property (strong,nonatomic) APKCachingThumbnailTool *cachingThumbnailTool;
@property (strong,nonatomic) NSMutableDictionary *assetInfo;
@property (strong,nonatomic) APKRefreshLocalFilesTool *refreshLocalFilesTool;
@property (nonatomic) NSInteger numberOfCollectedFiles;
@property (nonatomic,assign) CGRect previousTitleLRect;
@property (nonatomic,assign) BOOL rotateValue;
@property (nonatomic,assign) BOOL isFileBackScheduling;
@property (nonatomic,assign) int colorCount;
@end

@implementation APKLocalPhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.collectionView.alwaysBounceVertical = YES;
    
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    self.layout.footerReferenceSize = CGSizeMake(screenWidth, 40);
    
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter   withReuseIdentifier:headerViewIdentifier];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader   withReuseIdentifier:headerViewIdentifier];
    
    CGFloat space = 20 * 2 + 8 * 2;
    CGFloat infoLabelHeight = 42;
    CGFloat cellWidth = (screenWidth - space) / 3;
    CGFloat imagevHeight = cellWidth / 16.f * 9.f;
    CGFloat cellHeight = imagevHeight + infoLabelHeight;
    self.layout.itemSize = CGSizeMake(cellWidth, cellHeight);
    
    CGFloat bottomBarHeight = CGRectGetHeight(self.bottomBar.frame);
    self.bottomBarBottomConstraint.constant = -bottomBarHeight;
    
    [self.collectionBtn setTitle:NSLocalizedString(@"收藏", nil) forState:UIControlStateNormal];
    
    self.checkAllButton.hidden = YES;
    if (screenWidth > 320) {
        self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    }else{
        self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    }
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"本地", nil),NSLocalizedString(@"照片", nil)];

    [self.selectButton setTitle:NSLocalizedString(@"选择", nil) forState:UIControlStateNormal];
    [self.checkAllButton setTitle:NSLocalizedString(@"全选", nil) forState:UIControlStateNormal];
    
    self.selectCount = 0;
    self.previousTitleLRect = self.titleLabel.frame;
    
    [self fetchFileList:^(NSArray *fileList) {
       
        [self.dataSource setArray:fileList];
        
        self.cachingThumbnailTool = [[APKCachingThumbnailTool alloc] initWithThumbNailSize:CGSizeMake(cellWidth, imagevHeight)];
        [self startCachingThumbnail];
        if (self.dataSource.count == 0) {
            return;
        }
        [self combinData:self.dataSource isBackScheduling:NO]; //合并相同日期数据
        [self.collectionView reloadData];
        NSArray *fileArray = self.dataArray.firstObject;
        LocalFile *file = fileArray.firstObject;
        NSString *time = [self getTimeLabelString:file.saveDate];
        self.timeLabel.text = time;
    }];
    
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
- (IBAction)clickArrowsButton:(UIButton *)sender {
    
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
    NSArray *dataSourceArray = self.dataSource;
    if (dataSourceArray.count > 0) {
        
        for (int i = (int)dataSourceArray.count - 1; i >= 0; i--)
        {
            [NewDataArray addObject:dataSourceArray[i]];
        }
    }
    self.isFileBackScheduling = !self.isFileBackScheduling;
    [self combinData:NewDataArray isBackScheduling:self.isFileBackScheduling];
    [self.collectionView reloadData];
    [self.dataSource setArray:NewDataArray];
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
    [self.cachingThumbnailTool stopCaching];
    NSLog(@"%s",__func__);
}

#pragma mark - setter

- (void)setSelectCount:(NSInteger)selectCount{
    
    _selectCount = selectCount;
    
    if (selectCount == 0) {
        
        self.deleteButton.enabled = NO;
        self.shareButton.enabled = NO;
        
        self.collectButton.enabled = NO;
        self.collectButton.selected = NO;
        
        self.numberOfCollectedFiles = 0;
        
    }else{
        
        self.deleteButton.enabled = YES;
        self.shareButton.enabled = selectCount <= 9 ? YES : NO;
        
        self.collectButton.enabled = YES;
        self.collectButton.selected = self.numberOfCollectedFiles == selectCount;
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

- (NSMutableArray *)photos{
    
    if (!_photos) {
        _photos = [[NSMutableArray alloc] init];
    }
    return _photos;
}

- (NSMutableArray *)dataSource{
    
    if (!_dataSource) {
        
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

#pragma mark - private method

- (void)startCachingThumbnail{
    
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    NSMutableArray *identifiers = [[NSMutableArray alloc] init];
    for (LocalFile *file in self.dataSource) {
        [identifiers addObject:file.identifier];
    }
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:identifiers options:nil];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PHAsset *asset = obj;
        [assets addObject:asset];
        [self.assetInfo setObject:asset forKey:asset.localIdentifier];
    }];
    
    [self.cachingThumbnailTool startCachingWithAssets:assets];
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

- (void)fetchFileList:(void (^)(NSArray *fileList))completionHandler{
    
    [self.refreshLocalFilesTool.context performBlock:^{
        
        NSSortDescriptor *saveDateSort = [NSSortDescriptor sortDescriptorWithKey:@"saveDate" ascending:NO];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %d AND isFromRearCamera == %d",(int16_t)kAPKDVRFileTypePhoto,self.isRearCameraFile];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %d AND isFromRearCamera BETWEEN {0,1}",(int16_t)kAPKDVRFileTypePhoto];//获得前后镜头照片
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"LocalFile"];
        request.sortDescriptors = @[saveDateSort];
        request.predicate = predicate;
        
        NSError *error = nil;
        NSArray *result = [self.refreshLocalFilesTool.context executeFetchRequest:request error:&error];
        NSAssert(!error, error.localizedDescription);
        completionHandler(result);
    }];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    
    return self.photos.count;
}
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    
    MWPhoto *photo = self.photos[index];
    return photo;
}

- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index{
    
    MWPhoto *photo = self.photos[index];
    APKLocalPhotoCaptionView *captionView = [[APKLocalPhotoCaptionView alloc] initWithPhoto:photo];
    captionView.customDelegate = self;
    LocalFile *file = self.dataSource[index];
    [captionView configureViewWithLocalFile:file];
    
    return captionView;
}

#pragma mark APKLocalPhotoCaptionViewDelegate

- (void)APKLocalPhotoCaptionView:(APKLocalPhotoCaptionView *)captionView didClickDeleteButton:(UIButton *)sender{
    
    self.haveRefreshLocalFiles = YES;
    
    NSInteger index = self.photoBrowser.currentIndex;
    LocalFile *file = self.dataSource[index];
    [self delete:@[file] completionHandler:^(BOOL success) {
       
        if (success) {
            
            [self.refreshLocalFilesTool.context performBlock:^{
                
                [self.refreshLocalFilesTool.context deleteObject:file];
                [self.assetInfo removeObjectForKey:file.identifier];
                [self.refreshLocalFilesTool.context save:nil];
                
                [self.dataSource removeObject:file];
                [self.collectionView reloadData];
                
                [self.photos removeObjectAtIndex:index];
                if (self.photos.count == 0) {
                    [self.photoBrowser.navigationController dismissViewControllerAnimated:YES completion:nil];
                }else{
                    [self.photoBrowser reloadData];
                }
            }];
        }
    }];
}

- (void)APKLocalPhotoCaptionView:(APKLocalPhotoCaptionView *)captionView didClickCollectButton:(UIButton *)sender{
    
    self.haveRefreshLocalFiles = YES;
    
    NSInteger index = self.photoBrowser.currentIndex;
    LocalFile *file = self.dataSource[index];
    
    [self.refreshLocalFilesTool.context performBlock:^{
       
        file.isCollected = !file.isCollected;
        [self.refreshLocalFilesTool.context save:nil];
        [captionView configureViewWithLocalFile:file];
        
        [self.collectionView reloadData];
    }];
}

- (void)APKLocalPhotoCaptionView:(APKLocalPhotoCaptionView *)captionView didClickShareButton:(UIButton *)sender{
    
    NSInteger index = self.photoBrowser.currentIndex;
    MWPhoto *photo = [self.photos objectAtIndex:index];
    UIImage *image = photo.underlyingImage;
    if (!image) {
        return;
    }
    
    NSArray *items = @[image];
    UIActivityViewController *avc = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
    avc.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeAddToReadingList,UIActivityTypePostToTencentWeibo];
    [self.photoBrowser.navigationController presentViewController:avc animated:YES completion:nil];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{

    if (collectionView.allowsMultipleSelection) {
        
        LocalFile *file = self.dataSource[indexPath.item];
        if (file.isCollected) {
            self.numberOfCollectedFiles--;
        }
        self.selectCount -= 1;
        return;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView.allowsMultipleSelection) {
        LocalFile *file = self.dataSource[indexPath.item];
        if (file.isCollected) {
            self.numberOfCollectedFiles++;
        }
        self.selectCount += 1;
        return;
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    LocalFile *selectedFile = self.dataSource[indexPath.item];
    APKMWPhoto *selectedPhoto = nil;
    [self.photos removeAllObjects];
    for (LocalFile *file in self.dataSource) {
        
        PHAsset *asset = [self.assetInfo objectForKey:file.identifier];
        APKMWPhoto *photo = [APKMWPhoto photoWithAsset:asset targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight)];
        [self.photos addObject:photo];
        if (file == selectedFile) {
            selectedPhoto = photo;
        }
    }
    
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    photoBrowser.alwaysShowControls = YES;
    photoBrowser.displayActionButton = NO;
    [photoBrowser setCurrentPhotoIndex:[self.photos indexOfObject:selectedPhoto]];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:photoBrowser];
    navi.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navi animated:YES completion:nil];
    self.photoBrowser = photoBrowser;
}

#pragma mark - APKLocalPhotoCellDelegate

- (void)beganLongPressAPKLocalPhotoCell:(APKLocalPhotoCell *)cell{
    
    if (self.collectionView.allowsMultipleSelection) {
        return;
    }
    
    //此处需要把indexpath保存起来，因为变成多选模式并刷新列表后，用该Cell找到的IndexPath会变化！
    self.longPressIndexPath = [self.collectionView indexPathForCell:cell];
    [self clickSelectButton:self.selectButton];
}

- (void)endedLongPressAPKLocalPhotoCell:(APKLocalPhotoCell *)cell{
    
    if (self.longPressIndexPath) {
        
        [self.collectionView selectItemAtIndexPath:self.longPressIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        
        LocalFile *file = self.dataSource[self.longPressIndexPath.item];
        if (file.isCollected) {
            self.numberOfCollectedFiles++;
        }
        self.selectCount += 1;
        
        self.longPressIndexPath = nil;
    }
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
    
    APKLocalPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.delegate = self;
    LocalFile *file = self.dataArray[indexPath.section][indexPath.row];
    [cell configureCellWithFile:file];
    
    UIColor *colorOne = [UIColor redColor];
    UIColor *colorTwo = [UIColor yellowColor];
    UIColor *colorThree = [UIColor orangeColor];
    UIColor *colorFour = [UIColor greenColor];
    
    //    if (indexPath.row % 2 == 0 && indexPath.row != 0) colorCount ++;
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
    PHAsset *asset = [self.assetInfo objectForKey:file.identifier];
    [self.cachingThumbnailTool requestThumbnailForAsset:asset resultHandler:^(UIImage *thumbnail) {
        cell.imagev.image = thumbnail;
    }];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    
    if (kind == UICollectionElementKindSectionHeader) {
        
        
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerViewIdentifier forIndexPath:indexPath];
        
        for (UIView *view in headerView.subviews) { [view removeFromSuperview]; }//解决头视图重叠
        
        headerView.backgroundColor = [UIColor blackColor];
        
        UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 20)];
        
        time.textColor = [UIColor whiteColor];
        
        NSArray *sectionDataArray = self.dataArray[indexPath.section];
        LocalFile *theFile = sectionDataArray.firstObject;
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];//将日期转化为字符串
        [df setDateFormat:@"yyyy-MM-dd"];
        NSString * s1 = [df stringFromDate:theFile.saveDate];
        time.text = s1;
        [headerView addSubview:time];
        
        
        UILabel *detailTime = [self setDetailtimeL:indexPath];
        
        [headerView addSubview:detailTime];
        
        [self setDetailtimeL:indexPath];
        
        return headerView;
        
    } else { // 返回每一组的尾部视图
        UICollectionReusableView *footerView =  [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:headerViewIdentifier forIndexPath:indexPath];
        
        footerView.backgroundColor = [UIColor purpleColor];
        return footerView;
    }
    
}

-(UILabel*)setDetailtimeL:(NSIndexPath*)indexPath
{
    UILabel *detailTime = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 220, 0, 200, 20)];
    
    detailTime.textAlignment = NSTextAlignmentRight;
    
    detailTime.textColor = [UIColor whiteColor];
    
    NSMutableArray *timeArray = [NSMutableArray array];
    
    for (LocalFile *file in self.dataArray[indexPath.section]) {
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];//将日期转化为字符串
        [df setDateFormat:@"hh:mm:ss"];
        NSString * s1 = [df stringFromDate:file.saveDate];
        [timeArray addObject:s1];
        
    }
    
    detailTime.text = timeArray.count == 1 ? timeArray.firstObject : [NSString stringWithFormat:@"%@ ~ %@",timeArray.firstObject,timeArray.lastObject];
    
    return detailTime;
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
        
        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"共有%d个文件", nil),(int)self.dataSource.count];
        self.footerView.label.text = msg;
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
         self.titleLabel.frame = CGRectMake(20, CGRectGetMinY(self.titleLabel.frame), CGRectGetWidth(self.titleLabel.frame), CGRectGetHeight(self.titleLabel.frame));
        
    }else{
        
        [sender setTitle:NSLocalizedString(@"选择", nil) forState:UIControlStateNormal];
        self.checkAllButton.hidden = YES;
        CGFloat bottomBarHeight = CGRectGetHeight(self.bottomBar.frame);
        self.bottomBarBottomConstraint.constant = -bottomBarHeight;
        self.titleLabel.hidden = NO;
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
        
        self.selectCount = self.dataSource.count;
    }
    
    self.haveCheckAll = !self.haveCheckAll;
}

- (IBAction)clickDeleteButton:(UIButton *)sender {
    
    self.haveRefreshLocalFiles = YES;
    
    NSArray *indexPaths = self.collectionView.indexPathsForSelectedItems;
    NSMutableArray *fileArray = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in indexPaths) {
        
        //        LocalFile *file = self.dataSource[indexPath.row];
        [fileArray addObject:self.dataArray[indexPath.section][indexPath.row]];
    }
    
    [self delete:fileArray completionHandler:^(BOOL success) {
        
        if (success) {
            
            //刷新本地文件
            [self.refreshLocalFilesTool.context performBlock:^{
                
                for (LocalFile *file in fileArray) {
                    
                    [self.refreshLocalFilesTool.context deleteObject:file];
                    [self.assetInfo removeObjectForKey:file.identifier];
                }
                [self.refreshLocalFilesTool.context save:nil];
                
                [self.dataSource removeObjectsInArray:fileArray];//刷新图片数据
                [self refleshData:fileArray];//刷新数据
                [self.collectionView reloadData];
                
                [self updateFooterView];
                [self clickSelectButton:self.selectButton];
            }];
        }
    }];
}

- (IBAction)clickCollectButton:(UIButton *)sender {
    
    self.haveRefreshLocalFiles = YES;
    
    NSArray *indexPaths = self.collectionView.indexPathsForSelectedItems;
    [self.refreshLocalFilesTool.context performBlock:^{
        
        for (NSIndexPath *indexPath in indexPaths) {
            
            LocalFile *file = self.dataArray[indexPath.section][indexPath.row];
            file.isCollected = !self.collectButton.selected;
        }
        
        [self.refreshLocalFilesTool.context save:nil];
        [self clickSelectButton:self.selectButton];
    }];
}

- (IBAction)clickCollectionFileButton:(UIButton *)sender {
    
}

- (IBAction)clickShareButton:(UIButton *)sender {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSArray *indexPaths = self.collectionView.indexPathsForSelectedItems;
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in indexPaths) {
        LocalFile *file = self.dataArray[indexPath.section][indexPath.row];
        PHAsset *asset = [self.assetInfo objectForKey:file.identifier];
        [assets addObject:asset];
    }
    [APKShareTool loadShareItemsWithLocalPhotoAssets:assets completionHandler:^(BOOL success, NSArray *items) {
        
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
