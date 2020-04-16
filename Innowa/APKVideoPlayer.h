//
//  APKLocalVideoPlayerVC.h
//  第三版云智汇
//
//  Created by Mac on 16/8/10.
//  Copyright © 2016年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "LocalFile.h"
#import "APKDVRFile.h"
#import "APKDeleteDVRFileTool.h"
#import "APKDownloadDVRFileTool.h"

@interface APKVideoPlayerLocalItem : NSObject

@property (strong,nonatomic) LocalFile *file;
@property (strong,nonatomic) PHAsset *asset;

@end

@interface APKAVPlayerView : UIView

@property (strong,nonatomic) AVPlayer *player;

@end

@class APKVideoPlayer;
@protocol APKVideoPlayerDelegate <NSObject>

- (void)APKVideoPlayer:(APKVideoPlayer *)videoPlayer didDeleteFileArr:(NSMutableArray *)deleteFileArr;
- (void)APKVideoPlayer:(APKVideoPlayer *)videoPlayer didDownloadFile:(APKDVRFile *)file;

@end

@interface APKVideoPlayer : UIViewController
@property (nonatomic,copy) void (^mergeVidioBlock)(NSIndexPath *indexPath);
@property (nonatomic,assign) NSIndexPath *indexPath;
-(void)vidioPlayerWithIndexPath:(NSIndexPath*)indexPath andMergeVidioBlock:(void (^)(NSIndexPath *indexPath))mergeVidioBlock;
- (void)setupWithLocalItems:(NSArray<APKVideoPlayerLocalItem *> *)localItems currentIndex:(NSInteger)currentIndex;
- (void)setupWithDvrItems:(NSArray<APKDVRFile *> *)dvrItems delegate:(id<APKVideoPlayerDelegate>)delegate downloadTool:(APKDownloadDVRFileTool *)downloadTool deleteTool:(APKDeleteDVRFileTool *)deleteTool currentIndex:(NSInteger)currentIndex;



@end
