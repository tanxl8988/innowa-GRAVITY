//
//  APKCollectVideosViewController.m
//  Innowa
//
//  Created by Mac on 17/4/27.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKCollectVideosViewController.h"
#import "MBProgressHUD.h"
#import <CoreData/CoreData.h>
#import "APKLocalVideoCell.h"
#import <Photos/Photos.h>
#import "APKDVRFile.h"
#import "APKShareTool.h"
#import "APKCachingThumbnailTool.h"
#import "APKVideoPlayer.h"
#import "vidioColletionCell.h"

@interface APKCollectVideosViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBarBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *collectButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (strong,nonatomic) NSFetchedResultsController *fetchedReslutsController;
@property (nonatomic) NSInteger selectCount;
@property (strong,nonatomic) APKCachingThumbnailTool *cachingThumbnailTool;
@property (strong,nonatomic) NSMutableDictionary *assetInfo;
@property (strong,nonatomic) APKRefreshLocalFilesTool *refreshLocalFilesTool;
@property (nonatomic,assign) int colorCount;

@end

@implementation APKCollectVideosViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"vidioColletionCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"head"];
    
    CGFloat bottomBarHeight = CGRectGetHeight(self.bottomBar.frame);
    self.bottomBarBottomConstraint.constant = -bottomBarHeight;
    
    self.selectCount = 0;
    
    [self setupFetchedReslutsController];
    
    [self combinData:self.fetchedReslutsController.fetchedObjects isBackScheduling:NO];//合并相同日期数据
    
    CGSize thumbnailSize = CGSizeMake(80, 48);
    self.cachingThumbnailTool = [[APKCachingThumbnailTool alloc] initWithThumbNailSize:thumbnailSize];
    [self startCachingThumbnail];
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
        _checkAll = NO;
        
    }else{
        
        CGFloat bottomBarHeight = CGRectGetHeight(self.bottomBar.frame);
        self.bottomBarBottomConstraint.constant = -bottomBarHeight;
        
        //        self.tableView.editing = NO;
        
        self.collectionView.allowsMultipleSelection = NO;
        
        self.selectCount = 0;
        
        [self.collectionView reloadData];
    }
}

- (void)setCheckAll:(BOOL)checkAll{
    
    _checkAll = checkAll;
    
    NSInteger count = [self.fetchedReslutsController.sections[0] numberOfObjects];
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
        self.selectCount = count;
        
        
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
    NSMutableArray *identifiers = [[NSMutableArray alloc] init];
    for (LocalFile *file in self.fetchedReslutsController.fetchedObjects) {
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

- (void)setupFetchedReslutsController{
    
    NSSortDescriptor *saveDateSort = [NSSortDescriptor sortDescriptorWithKey:@"saveDate" ascending:NO];
    NSSortDescriptor *cameraTypeSort = [NSSortDescriptor sortDescriptorWithKey:@"isFromRearCamera" ascending:YES];
    NSString *predicateFormat = [NSString stringWithFormat:@"type == %d AND isCollected == YES OR type == %d AND isCollected == YES OR type == %d AND isCollected == YES",(int16_t)kAPKDVRFileTypeVideo,(int16_t)kAPKDVRFileTypeEvent,(int16_t)kAPKDVRFileTypeVidioEdit];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"LocalFile"];
    request.sortDescriptors = @[saveDateSort,cameraTypeSort];
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
    
    [self.cachingThumbnailTool requestThumbnailForAsset:asset resultHandler:^(UIImage *thumbnail) {
        
        cell.imageView.image = thumbnail;
        
    }];
    
    cell.detailL.text = theFile.name;
    cell.seletedImage.hidden = YES;
    cell.collectImage.hidden = !theFile.isCollected;
    cell.index = indexPath;
    cell.lockImage.hidden = YES;
    
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
    
    __weak typeof(self)weakSelf = self;
    
    cell.cellSelected = ^(BOOL isSelected, BOOL showSelectdButton, NSIndexPath *index, vidioColletionCell *cell) {
        if (showSelectdButton) {
            
            if ([self.selectButton.titleLabel.text isEqualToString:NSLocalizedString(@"选择", nil)]) {
                
                
                self.selectMode = YES;
                if (self.selectModeHandler) {
                    self.selectModeHandler();
                }
                
                self.selectCount = 1;
                
                static NSIndexPath *indexP;
                indexP = [NSIndexPath indexPathForItem:index.row inSection:index.section];
                [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:NO block:^(NSTimer * _Nonnull timer) {
                    
                    [weakSelf.collectionView selectItemAtIndexPath:indexP animated:YES scrollPosition:UICollectionViewScrollPositionNone];
                    
                    indexP = nil;
                    
                }];
                
            }else return;
            
        }
    };
    
    
    return cell;
}

// 和UITableView类似，UICollectionView也可设置段头段尾
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    if([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"head" forIndexPath:indexPath];
        
        for (UIView *view in headerView.subviews) { [view removeFromSuperview]; }//解决头视图重叠
        
        headerView.backgroundColor = [UIColor blackColor];
        
        UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 100, 20)];
        time.textColor = [UIColor whiteColor];
        
        NSArray *sectionDataArray = self.dataArray[indexPath.section];
        LocalFile *theFile = sectionDataArray[indexPath.row];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];//将日期转化为字符串
        [df setDateFormat:@"yyyy-MM-dd"];
        NSString * s1 = [df stringFromDate:theFile.saveDate];
        time.text = s1;
        [headerView addSubview:time];
        
        UILabel *detailTime = [self setDetailtimeL:indexPath];
        [headerView addSubview:detailTime];
        detailTime.textColor = [UIColor whiteColor];
        detailTime.frame = CGRectMake(self.view.bounds.size.width - 220, 15, 200, 20);
        
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
    return (CGSize){self.view.bounds.size.width,44};
}


#pragma mark ---- UICollectionViewDelegate

// 选中某item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (collectionView.allowsMultipleSelection) {
        LocalFile *file = self.dataArray[indexPath.section][indexPath.row];
        if (file.isCollected) {
            //            self.numberOfCollectedFiles++;
        }
        self.selectCount += 1;
        return;
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (LocalFile *file in self.fetchedReslutsController.fetchedObjects) {
        
        APKVideoPlayerLocalItem *item = [[APKVideoPlayerLocalItem alloc] init];
        item.file = file;
        item.asset = [self.assetInfo objectForKey:file.identifier];
        [items addObject:item];
    }
    
    APKVideoPlayer *videoPlayer = [self.storyboard instantiateViewControllerWithIdentifier:@"APKVideoPlayer"];
    [videoPlayer setupWithLocalItems:items currentIndex:indexPath.row];
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
            //            self.numberOfCollectedFiles--;
        }
        self.selectCount -= 1;
        return;
    }
}



#pragma mark - actions

- (IBAction)clickDeleteButton:(UIButton *)sender {
    
    self.haveRefreshLocalFiles = YES;
    
    NSArray *indexPaths = self.collectionView.indexPathsForSelectedItems;
    
    if (indexPaths.count == 0) return;
    
    NSMutableArray *fileArray = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in indexPaths) {
        
        [fileArray addObject:self.dataArray[indexPath.section][indexPath.row]];
    }
    
    [self delete:fileArray completionHandler:^(BOOL success) {
        
        if (success) {
            [self.refreshLocalFilesTool.context performBlock:^{
                
                for (LocalFile *file in fileArray) {
                    
                    [self.assetInfo removeObjectForKey:file.identifier];
                    [self.refreshLocalFilesTool.context deleteObject:file];
                }
                
                [self.refreshLocalFilesTool.context save:nil];
                
                [self refleshData:fileArray];
                [self.collectionView reloadData];
                
                
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
    
    if (indexPaths.count == 0) return;
    
    NSMutableArray *collectArray = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in indexPaths) {
        LocalFile *file = self.dataArray[indexPath.section][indexPath.row];
        [collectArray addObject:file];
        
    }
    
    [self.refreshLocalFilesTool.context performBlock:^{
        
        
        for (LocalFile *theFile in collectArray) {
            
            theFile.isCollected = !theFile.isCollected;
            
            [self.assetInfo removeObjectForKey:theFile.identifier];
        }
        
        [self.refreshLocalFilesTool.context save:nil];
        
        [self refleshData:collectArray];
        [self.collectionView reloadData];
        
        
        self.selectMode = NO;
        if (self.selectModeHandler) {
            self.selectModeHandler();
        }
    }];
}

- (IBAction)clickShareButton:(UIButton *)sender {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.parentViewController.view animated:YES];
    
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
    
    self.selectMode = NO;
    if (self.selectModeHandler) {
        self.selectModeHandler();
    }
}

@end
