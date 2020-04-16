//
//  APKRequestDVRFileTool.m
//  万能AIT
//
//  Created by Mac on 17/3/23.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKRequestDVRFileTool.h"
#import "APKDVR.h"
#import "APKDVRTask.h"
#import "DVRFile.h"
#import "LocalFile.h"
#import "APKDownloadDVRFileTool.h"
#import "APKGetFileListTool.h"

@interface APKRequestDVRFileTool ()

@property (copy,nonatomic) APKRequestDVRFileSuccessBlock successBlock;
@property (copy,nonatomic) APKRequestDVRFileFailureBlock failureBlock;
@property (assign) APKDVRFileType fileType;
@property (assign) BOOL isRearCameraFile;
@property (strong,nonatomic) NSMutableArray *fileArray;
@property (strong,nonatomic) NSManagedObjectContext *context;
@property (strong,nonatomic) APKDownloadDVRFileTool *downloadTool;
@property (strong,nonatomic) APKGetFileListTool *getFileListTool;
@property (nonatomic) NSInteger fromIndex;
@property (nonatomic) NSInteger count;

@end

@implementation APKRequestDVRFileTool

#pragma mark - life circle

- (instancetype)initWithFileType:(APKDVRFileType)fileType isRearCameraFile:(BOOL)isRearCameraFile managedObjectContext:(NSManagedObjectContext *)context{
    
    if (self = [super init]) {
        
        self.fileType = fileType;
        self.isRearCameraFile = isRearCameraFile;
        self.context = context;
    }
    
    return self;
}

- (void)dealloc{
    
    NSLog(@"%s",__func__);
}

#pragma mark - getter

- (APKGetFileListTool *)getFileListTool{//获取fileArray数据
    
    if (!_getFileListTool) {
        __weak typeof(self)weakSelf = self;
        _getFileListTool = [APKGetFileListTool toolWithFileType:self.fileType isRearCameraFile:self.isRearCameraFile context:self.context completionHandler:^(BOOL success, NSArray *fileArray) {
        
            _getFileListTool = nil;
            if (success) {
                
                weakSelf.fileArray = [fileArray mutableCopy];
                
                if (self.isRequestAll) {
                    
                    [weakSelf getThumbnailWithFileArray:weakSelf.fileArray];
                    return;
                }
                
                if (weakSelf.fromIndex >= weakSelf.fileArray.count) {
                    
                    weakSelf.successBlock(@[]);
                    
                }else if (weakSelf.fromIndex + weakSelf.count <= weakSelf.fileArray.count) {
                    
                    NSRange range = NSMakeRange(weakSelf.fromIndex, weakSelf.count);
                    NSArray *arr = [weakSelf.fileArray subarrayWithRange:range];
                    [weakSelf getThumbnailWithFileArray:arr];
                    
                }else{
                    
                    int newCount = weakSelf.fileArray.count - weakSelf.fromIndex;
                    NSRange range = NSMakeRange(weakSelf.fromIndex, newCount);
                    NSArray *arr = [weakSelf.fileArray subarrayWithRange:range];
                    [weakSelf getThumbnailWithFileArray:arr];
                }

            }else{
                
                weakSelf.failureBlock();
            }
        }];
    }
    
    return _getFileListTool;
}

- (APKDownloadDVRFileTool *)downloadTool{
    
    if (!_downloadTool) {
        
        _downloadTool = [[APKDownloadDVRFileTool alloc] initWithManagedObjectContext:self.context];
    }
    return _downloadTool;
}

#pragma mark - private method

- (void)getThumbnailWithFileArray:(NSArray *)fileArray{
    
    if (self.context) {
        
        __weak typeof(self)weakSelf = self;
        [self.context performBlock:^{
            
            NSMutableArray *thumbnailTaskArray = [[NSMutableArray alloc] init];
            for (APKDVRFile *APKFile in fileArray) {
                
                DVRFile *dvrFile = [DVRFile getDVRFileWithName:APKFile.name type:APKFile.type context:weakSelf.context];
                if (dvrFile) {
                    if (dvrFile.localFile) {
                        APKFile.isDownloaded = YES;
                    }
                    if (dvrFile.thumbnailPath) {
                        
                        if (![[NSFileManager defaultManager] fileExistsAtPath:dvrFile.thumbnailPath]) {
                            dvrFile.thumbnailPath = nil;
                        }
                    }
                    APKFile.thumbnailPath = dvrFile.thumbnailPath;
                }
                
                if (!APKFile.thumbnailPath) {//本地不存在就下载
                    [thumbnailTaskArray addObject:APKFile];
                }
            }
            
            [weakSelf.context save:nil];
            [weakSelf.downloadTool downloadThumbnailWithFileArray:thumbnailTaskArray completionHandler:^{
                
                weakSelf.successBlock(fileArray);
            }];
        }];
        
    }else{
        
        self.successBlock(fileArray);
    }
}

#pragma mark - public method

- (void)requestDVRFileWithCount:(NSInteger)count fromIndex:(NSInteger)index successBlock:(APKRequestDVRFileSuccessBlock)successBlock failureBlock:(APKRequestDVRFileFailureBlock)failureBlock{
    
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    self.fromIndex = index;
    self.count = count;
    
    if (index == 0) {//刚进入页面
        
        [self.fileArray removeAllObjects];
        [self.getFileListTool getFileList];
        
    }else{
        
        if (index >= self.fileArray.count) {
            
            self.successBlock(@[]);
            
        }else if (index + count <= self.fileArray.count) {
            
            NSRange range = NSMakeRange(index, count);
            NSArray *arr = [self.fileArray subarrayWithRange:range];
            [self getThumbnailWithFileArray:arr];//下载缩略图
            
        }else{
            
            NSInteger newCount = self.fileArray.count - self.fromIndex;
            NSRange range = NSMakeRange(index, newCount);
            NSArray *arr = [self.fileArray subarrayWithRange:range];
            [self getThumbnailWithFileArray:arr];
        }
    }
}

@end
