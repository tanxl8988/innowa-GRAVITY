//
//  APKDVRVideoPlayer.h
//  Innowa
//
//  Created by 李福池 on 2018/6/25.
//  Copyright © 2018年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "LocalFile.h"
#import "APKDVRFile.h"
#import "APKDeleteDVRFileTool.h"
#import "APKDownloadDVRFileTool.h"

@interface APKPlayerLocalItem : NSObject

@property (strong,nonatomic) LocalFile *file;
@property (strong,nonatomic) PHAsset *asset;

@end

@interface APKPlayerView : UIView

@property (strong,nonatomic) AVPlayer *player;

@end

@class APKDVRVideoPlayer;
@protocol APKPlayerDelegate <NSObject>

- (void)APKVideoPlayer:(APKDVRVideoPlayer *)videoPlayer deleteFileArr:(NSMutableArray *)deleteFileArr;
- (void)APKVideoPlayer:(APKDVRVideoPlayer *)videoPlayer didDownloadFile:(APKDVRFile *)file;

@end

@interface APKDVRVideoPlayer : UIViewController

- (void)setupWithLocalItems:(NSArray<APKPlayerLocalItem *> *)localItems currentIndex:(NSInteger)currentIndex;
- (void)setupWithDvrItems:(NSArray<APKDVRFile *> *)dvrItems delegate:(id<APKPlayerDelegate>)delegate downloadTool:(APKDownloadDVRFileTool *)downloadTool deleteTool:(APKDeleteDVRFileTool *)deleteTool currentIndex:(NSInteger)currentIndex;

@end
