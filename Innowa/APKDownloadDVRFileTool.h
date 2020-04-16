//
//  APKDownloadDVRFileTool.h
//  万能AIT
//
//  Created by Mac on 17/3/23.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APKDVRFile.h"
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

typedef void(^APKDownloadDVRFileThumbnailCompletionHandler)(void);
typedef void(^APKDownloadPreviewPhotoCompletionHandler)(APKDVRFile *file);
typedef void(^APKDownloadDVRFileCompletionHandler)(NSArray *failureTaskArray);
typedef void(^APKDownloadDVRFileProgressHandler)(float progress,NSString *progressMsg);
typedef void(^APKDownloadDVRFileUpdateHandler)(APKDVRFile *targetFile);
typedef void(^APKCollectDVRFileCompletionHandler)(void);
typedef void(^APKDownloadShareFileCompletionHandler)(BOOL success,NSURL *url);

@interface APKDownloadDVRFileTool : NSObject

@property (copy,nonatomic) APKDownloadPreviewPhotoCompletionHandler downloadPreviewPhotoCompletionHandler;

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)context;
- (void)downloadThumbnailWithFileArray:(NSArray *)fileArray completionHandler:(APKDownloadDVRFileThumbnailCompletionHandler)completionHandler;
- (void)addPreviewPhotoTask:(APKDVRFile *)file;

//download
- (void)addDownloadTask:(NSArray *)fileArray isCollected:(BOOL)isCollected isRearCameraFile:(BOOL)isRearCameraFile updateHandler:(APKDownloadDVRFileUpdateHandler)updateHandler progressHandler:(APKDownloadDVRFileProgressHandler)progressHandler completionHandler:(APKDownloadDVRFileCompletionHandler)completionHandler;
- (void)cancelDownloadTask;
- (void)savePhoto:(APKDVRFile *)file image:(UIImage *)image isCollected:(BOOL)isCollected isRearCameraFile:(BOOL)isRearCameraFile completionHandler:(APKDownloadDVRFileCompletionHandler)completionHandler;
//- (void)collect:(NSArray *)fileArray completionHandler:(APKCollectDVRFileCompletionHandler)completionHandler;
- (void)downloadShareFile:(APKDVRFile *)file progressHandler:(APKDownloadDVRFileProgressHandler)progressHandler completionHandler:(APKDownloadShareFileCompletionHandler)completionHandler;
- (void)saveFile:(APKDVRFile *)file withUrl:(NSURL *)url isVidioEdit:(BOOL)isEdit;

@end
