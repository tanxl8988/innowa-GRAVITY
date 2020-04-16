//
//  APKGetFileListTool.m
//  Innowa
//
//  Created by Mac on 17/7/4.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKGetFileListTool.h"
#import "APKDVR.h"

@interface APKGetFileListTool ()

@property (copy,nonatomic) APKGetFileListCompletionHandler completionHandler;
@property (nonatomic)APKDVRFileType fileType;
@property (nonatomic) BOOL isRearCameraFile;
@property (strong,nonatomic) NSManagedObjectContext *context;
@property (strong,nonatomic) NSString *taskKey;
@property (strong,nonatomic) NSMutableArray *fileArray;

@end

@implementation APKGetFileListTool

+ (id)toolWithFileType:(APKDVRFileType)fileType isRearCameraFile:(BOOL)isRearCameraFile context:(NSManagedObjectContext *)context completionHandler:(APKGetFileListCompletionHandler)completionHandler{
    
    APKGetFileListTool *tool = [[APKGetFileListTool alloc] init];
    tool.fileType = fileType;
    tool.isRearCameraFile = isRearCameraFile;
    tool.context = context;
    tool.completionHandler = completionHandler;
    if (fileType == kAPKDVRFileTypePhoto) {
        tool.taskKey = @"states.getPhotoList";
    }else if (fileType == kAPKDVRFileTypeVideo){
        tool.taskKey = @"states.getVideoList";
    }else if (fileType == kAPKDVRFileTypeEvent){
        tool.taskKey = @"states.getEventList";
    }else if(fileType == kAPKDVRFileTypeParkTime)
    {
        tool.taskKey = @"states.getParkTimeList";
    }else if(fileType == kAPKDVRFileTypeParkEvent)
    {
        tool.taskKey = @"states.getParkEventList";
    }
    
    [[APKDVR sharedInstance] addObserver:tool forKeyPath:tool.taskKey options:NSKeyValueObservingOptionNew context:nil];

    return tool;
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
    [[APKDVR sharedInstance] removeObserver:self forKeyPath:self.taskKey];
}

#pragma mark - KVO（相同的值也会监听）

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    APKDVRState state = [change[@"new"]integerValue];
    if (state == kAPKDVRStateSuccess) {
        
        NSArray *fileArray = nil;
        if (self.fileType == kAPKDVRFileTypePhoto) {
            fileArray = [APKDVR sharedInstance].info.photos;
        }else if (self.fileType == kAPKDVRFileTypeVideo){
            fileArray = [APKDVR sharedInstance].info.videos;
        }else if (self.fileType == kAPKDVRFileTypeEvent){
            fileArray = [APKDVR sharedInstance].info.events;
        }else if (self.fileType == kAPKDVRFileTypeParkTime){
            fileArray = [APKDVR sharedInstance].info.parkTime;
        }else if (self.fileType == kAPKDVRFileTypeParkEvent){
            fileArray = [APKDVR sharedInstance].info.parkEvent;
        }
        if (fileArray.count == 0) {//全部获取完成
            
            [self sortFileArray];
            self.completionHandler(YES,self.fileArray);
            
        }else{
            
            [self.fileArray addObjectsFromArray:fileArray];
            [self getFileList];//递归获取
        }
        
    }else if (state == kAPKDVRStateFailure){
        
        self.completionHandler(NO,nil);
    }else if (state == kAPKDVRStateExcuting){
        
        
    }
}

#pragma mark - private method

- (void)getFileList{
    
    APKDVRTask *task = nil;
    NSInteger count = 16;
    if (self.fileType == kAPKDVRFileTypePhoto) {
        task = [APKDVRTask getPhotoListTaskWithCount:count fromIndex:self.fileArray.count isRearCameraFile:self.isRearCameraFile];
    }else if (self.fileType == kAPKDVRFileTypeVideo){
        task = [APKDVRTask getVideoListTaskWithCount:count fromIndex:self.fileArray.count isRearCameraFile:self.isRearCameraFile];
    }else if (self.fileType == kAPKDVRFileTypeEvent){
        task = [APKDVRTask getEventListTaskWithCount:count fromIndex:self.fileArray.count isRearCameraFile:self.isRearCameraFile];
    }else if (self.fileType == kAPKDVRFileTypeParkTime){
        task = [APKDVRTask getParkTimeListTaskWithCount:count fromIndex:self.fileArray.count isRearCameraFile:self.isRearCameraFile];
    }
    else if (self.fileType == kAPKDVRFileTypeParkEvent){
        task = [APKDVRTask getParkEventListTaskWithCount:count fromIndex:self.fileArray.count isRearCameraFile:self.isRearCameraFile];
    }
    [[APKDVR sharedInstance] performTask:task];
}

#pragma mark - getter

- (void)sortFileArray{
    
    NSComparator cmptr = ^(id obj1, id obj2){
        
        APKDVRFile *file1 = obj1;
        APKDVRFile *file2 = obj2;
        return [file2.date compare:file1.date];
    };
    NSArray *array = [self.fileArray sortedArrayUsingComparator:cmptr];
    [self.fileArray setArray:array];
}

- (NSMutableArray *)fileArray{
    
    if (!_fileArray) {
        
        _fileArray = [[NSMutableArray alloc] init];
    }
    
    return _fileArray;
}

@end
