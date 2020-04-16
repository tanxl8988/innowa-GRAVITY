//
//  APKCollectPhotosViewController.m
//  Innowa
//
//  Created by Mac on 17/4/27.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKCollectPhotosViewController.h"
#import "APKLocalPhotoCell.h"
#import "APKPhotosPageFooterView.h"
#import <CoreData/CoreData.h>
#import "APKDVRFile.h"
#import "APKLocalPhotoCaptionView.h"
#import "LocalFile.h"
#import "MBProgressHUD.h"
#import <Photos/Photos.h>
#import "MWPhotoBrowser.h"
#import "APKMWPhoto.h"
#import "APKShareTool.h"
#import "APKCachingThumbnailTool.h"

static NSString *headerViewIdentifier = @"headerView";
static NSString *identifier = @"localPhotoCell";

@interface APKCollectPhotosViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,APKLocalPhotoCellDelegate,MWPhotoBrowserDelegate,APKLocalPhotoCaptionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBarBottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *collectButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;
@property (strong,nonatomic) NSIndexPath *longPressIndexPath;
@property (assign) BOOL haveCheckAll;
@property (strong,nonatomic) NSMutableArray *dataSource;
@property (strong,nonatomic) NSMutableArray *photos;
@property (weak,nonatomic) MWPhotoBrowser *photoBrowser;
@property (weak,nonatomic) APKPhotosPageFooterView *footerView;
@property (nonatomic) NSInteger selectCount;
@property (strong,nonatomic) APKCachingThumbnailTool *cachingThumbnailTool;
@property (strong,nonatomic) NSMutableDictionary *assetInfo;
@property (assign) CGSize thumbnailSize;
@property (strong,nonatomic) APKRefreshLocalFilesTool *refreshLocalFilesTool;
@property (nonatomic,assign) int colorCount;
@end

@implementation APKCollectPhotosViewController

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
    self.thumbnailSize = CGSizeMake(cellWidth, imagevHeight);
    
    CGFloat bottomBarHeight = CGRectGetHeight(self.bottomBar.frame);
    self.bottomBarBottomConstraint.constant = -bottomBarHeight;
    
    self.selectCount = 0;
    
    [self fetchFileList:^(NSArray *fileList) {
        
        [self.dataSource setArray:fileList];
        
        self.cachingThumbnailTool = [[APKCachingThumbnailTool alloc] initWithThumbNailSize:self.thumbnailSize];
        [self startCachingThumbnail];
        [self combinData:self.dataSource isBackScheduling:NO]; //合并相同日期数据
        [self.collectionView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [self.cachingThumbnailTool stopCaching];
    NSLog(@"%s",__func__);
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

#pragma mark - setter

- (void)setSelectCount:(NSInteger)selectCount{
    
    _selectCount = selectCount;
    
    if (selectCount == 0) {
        
        self.deleteButton.enabled = NO;
        self.shareButton.enabled = NO;
        
        self.collectButton.selected = NO;
        self.collectButton.enabled = NO;
        
    }else{
        
        self.deleteButton.enabled = YES;
        self.shareButton.enabled = YES;
        
        self.collectButton.selected = YES;
        self.collectButton.enabled = YES;
    }
}

- (void)setSelectMode:(BOOL)selectMode{
    
    _selectMode = selectMode;
    
    if (selectMode) {
        
        self.bottomBarBottomConstraint.constant = 0;
        
        self.collectionView.allowsMultipleSelection = YES;
        [self.collectionView reloadData];
        _checkAll = NO;

    }else{
        
        CGFloat bottomBarHeight = CGRectGetHeight(self.bottomBar.frame);
        self.bottomBarBottomConstraint.constant = -bottomBarHeight;
        
        self.collectionView.allowsMultipleSelection = NO;
        [self.collectionView reloadData];
        
        self.selectCount = 0;
    }
}

- (void)setCheckAll:(BOOL)checkAll{
    
    _checkAll = checkAll;
    
    if (checkAll) {
        
        for (int i = 0; i < self.dataArray.count; i++) {
            
            NSMutableArray *oneArray = self.dataArray[i];
            
            for ( int j = 0; j < oneArray.count; j++) {
                
                NSIndexPath *index = [NSIndexPath indexPathForRow:j inSection:i];
                [self.collectionView selectItemAtIndexPath:index animated:NO scrollPosition:UICollectionViewScrollPositionNone];
                
                LocalFile *file = self.dataArray[index.section][index.row];
                if (file.isCollected) {
                    //                    self.numberOfCollectedFiles++;
                }
            }
            
        }
        
        self.selectCount = self.dataSource.count;
        
    }else{
        
        for (int i = 0; i < self.dataArray.count; i++) {
            
            NSMutableArray *oneArray = self.dataArray[i];
            
            for ( int j = 0; j < oneArray.count; j++) {
                
                NSIndexPath *index = [NSIndexPath indexPathForRow:j inSection:i];
                [self.collectionView deselectItemAtIndexPath:index animated:NO];
                
            }
            
        }
        
        self.selectCount = 0;
    }
}

#pragma mark - private method

- (void)startCachingThumbnail{
    
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    for (LocalFile *file in self.dataSource) {
        
        PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[file.identifier] options:nil].firstObject;
        [assets addObject:asset];
        [self.assetInfo setObject:asset forKey:file.identifier];
    }
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
        NSSortDescriptor *cameraTypeSort = [NSSortDescriptor sortDescriptorWithKey:@"isFromRearCamera" ascending:YES];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %d AND %K == YES",@"type",(int16_t)kAPKDVRFileTypePhoto,@"isCollected"];;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"LocalFile"];
        request.sortDescriptors = @[saveDateSort,cameraTypeSort];
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

        file.isCollected = NO;
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
    
    //此处需要把indexpath保存起来，因为变成多选模式并刷新列表后，用该Cell找到的IndexPath会变化！
    self.longPressIndexPath = [self.collectionView indexPathForCell:cell];
    
    self.selectMode = YES;
    if (self.selectModeHandler) {
        self.selectModeHandler();
    }
}

- (void)endedLongPressAPKLocalPhotoCell:(APKLocalPhotoCell *)cell{
    
    [self.collectionView selectItemAtIndexPath:self.longPressIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    self.longPressIndexPath = nil;
    self.selectCount += 1;
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
    PHAsset *asset = [self.assetInfo objectForKey:file.identifier];
    [self.cachingThumbnailTool requestThumbnailForAsset:asset resultHandler:^(UIImage *thumbnail) {
        cell.imagev.image = thumbnail;
    }];
    
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
    cell.colorView.hidden = NO;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if (kind == UICollectionElementKindSectionHeader) {
        
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerViewIdentifier forIndexPath:indexPath];
        
        for (UIView *view in headerView.subviews) { [view removeFromSuperview]; }//解决头视图重叠
        
        headerView.backgroundColor = [UIColor blackColor];
        
        UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 100, 20)];
        
        NSArray *sectionDataArray = self.dataArray[indexPath.section];
        LocalFile *theFile = sectionDataArray.firstObject;
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];//将日期转化为字符串
        [df setDateFormat:@"yyyy-MM-dd"];
        NSString * s1 = [df stringFromDate:theFile.saveDate];
        time.text = s1;
        time.textColor = [UIColor whiteColor];
        [headerView addSubview:time];
        
        
        UILabel *detailTime = [self setDetailtimeL:indexPath];
        
        [headerView addSubview:detailTime];
        
        [self setDetailtimeL:indexPath];
        detailTime.frame = CGRectMake(self.view.bounds.size.width - 220, 15, 200, 20);
        detailTime.textColor = [UIColor whiteColor];
        
        return headerView;
        
    } else { // 返回每一组的尾部视图
        UICollectionReusableView *footerView =  [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:headerViewIdentifier forIndexPath:indexPath];
        
        footerView.backgroundColor = [UIColor purpleColor];
        return footerView;
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return (CGSize){self.view.bounds.size.width,44};
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

- (IBAction)clickDeleteButton:(UIButton *)sender {
    
    self.haveRefreshLocalFiles = YES;
    
    NSArray *indexPaths = self.collectionView.indexPathsForSelectedItems;
    NSMutableArray *fileArray = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in indexPaths) {
        
        LocalFile *file = self.dataArray[indexPath.section][indexPath.row];
        [fileArray addObject:file];
    }
    
    [self delete:fileArray completionHandler:^(BOOL success) {
        
        if (success) {
            [self.refreshLocalFilesTool.context performBlock:^{
                
                for (LocalFile *file in fileArray) {
                    
                    [self.refreshLocalFilesTool.context deleteObject:file];
                    [self.assetInfo removeObjectForKey:file.identifier];
                }
                [self.refreshLocalFilesTool.context save:nil];
                [self.dataSource removeObjectsInArray:fileArray];
                
                [self refleshData:fileArray];//刷新数据
                [self.collectionView reloadData];
                
                [self updateFooterView];
                
                self.selectMode = NO;
                if (self.selectModeHandler) {
                    self.selectModeHandler();
                }
            }];
        }
    }];

}

- (IBAction)clickCollectButton:(UIButton *)sender {
    
    self.haveRefreshLocalFiles = YES;
    
    NSArray *indexPaths = self.collectionView.indexPathsForSelectedItems;
    [self.refreshLocalFilesTool.context performBlock:^{
        
        NSMutableArray *fileArray = [[NSMutableArray alloc] init];
        for (NSIndexPath *indexPath in indexPaths) {
            LocalFile *file = self.dataArray[indexPath.section][indexPath.row];
            file.isCollected = NO;
            [fileArray addObject:file];
        }
        [self.refreshLocalFilesTool.context save:nil];
        [self.dataSource removeObjectsInArray:fileArray];
        
        [self refleshData:fileArray];//刷新数据
        [self.collectionView reloadData];
        
        [self updateFooterView];
        self.selectMode = NO;
        if (self.selectModeHandler) {
            self.selectModeHandler();
        }
    }];
}

- (IBAction)clickShareButton:(UIButton *)sender {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.parentViewController.view animated:YES];
    
    NSArray *indexPaths = self.collectionView.indexPathsForSelectedItems;
    NSMutableArray *assets = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in indexPaths) {
        LocalFile *file = self.dataArray[indexPath.section][indexPath.row];
        PHAsset *asset = [self.assetInfo objectForKey:file.identifier];
        [assets addObject:asset];
    }
    
    [APKShareTool loadShareItemsWithLocalPhotoAssets:assets[0] completionHandler:^(BOOL success, NSArray *items) {
        
        [hud hideAnimated:YES];
        if (success) {
            
            UIActivityViewController *avc = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
            avc.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeAddToReadingList,UIActivityTypePostToTencentWeibo];
            [self presentViewController:avc animated:YES completion:nil];
        }
    }];
    
    self.selectMode = NO;
    if (self.selectModeHandler) {
        self.selectModeHandler();
    }}

@end
