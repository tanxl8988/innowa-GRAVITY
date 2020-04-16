//
//  APKDeleteDVRFileTool.m
//  万能AIT
//
//  Created by Mac on 17/3/24.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKDeleteDVRFileTool.h"
#import "APKDVR.h"
#import "APKDVRTask.h"
#import "DVRFile.h"

@interface APKDeleteDVRFileTool ()

@property (copy,nonatomic) APKDeleteDVRFileCompletionHandler completionHandler;
@property (strong,nonatomic) NSMutableArray *taskArray;
@property (strong,nonatomic) NSManagedObjectContext *context;
@property (weak,nonatomic) APKDVRFile *targetFile;
@property (strong,nonatomic) NSMutableArray *failureTaskArray;

@end

@implementation APKDeleteDVRFileTool

#pragma mark - life circle

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)context{
    
    if (self = [super init]) {
        
        self.context = context;
        
        APKDVR *dvr = [APKDVR sharedInstance];
        [dvr addObserver:self forKeyPath:@"states.deleteFile" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    return self;
}

- (void)dealloc{
    
    NSLog(@"%s",__func__);
    APKDVR *dvr = [APKDVR sharedInstance];
    [dvr removeObserver:self forKeyPath:@"states.deleteFile"];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"states.deleteFile"]) {
        
        APKDVRState state = [change[@"new"] integerValue];
        if (state == kAPKDVRStateSuccess) {
            
            __weak typeof(self)weakSelf = self;
            [self.context performBlock:^{
                
                DVRFile *dvrFile = [DVRFile getDVRFileWithName:weakSelf.targetFile.name type:weakSelf.targetFile.type context:weakSelf.context];
                if (dvrFile) {
                    
                    [weakSelf.context deleteObject:dvrFile];
                    [weakSelf.context save:nil];
                }
            }];
            
            [self.taskArray removeObject:self.targetFile];
            [self performDeleteTask];
            
        }else if (state == kAPKDVRStateFailure){
            
            [self.failureTaskArray addObject:self.targetFile];
            [self.taskArray removeObject:self.targetFile];
            [self performDeleteTask];
        }
    }
}

#pragma mark - getter

- (NSMutableArray *)failureTaskArray{
    
    if (!_failureTaskArray) {
        _failureTaskArray = [[NSMutableArray alloc] init];
    }
    return _failureTaskArray;
}

- (NSMutableArray *)taskArray{
    
    if (!_taskArray) {
        _taskArray = [[NSMutableArray alloc] init];
    }
    return _taskArray;
}

#pragma mark - private method

- (void)performDeleteTask{
    
    if (self.taskArray.count == 0) {
        
        self.completionHandler(self.failureTaskArray);
        return;
    }
    
    self.targetFile = self.taskArray.firstObject;
    NSString *deleteName = [self.targetFile.originalName stringByReplacingOccurrencesOfString: @"/" withString:@"$"];
    APKDVRTask *task = [APKDVRTask deleteFileTaskWithFileName:deleteName];
    [[APKDVR sharedInstance] performTask:task];
}

#pragma mark - public method

- (void)deleteWithFileArray:(NSArray <APKDVRFile *> *)fileArray completionHandler:(APKDeleteDVRFileCompletionHandler)completionHandler{
    
    [self.failureTaskArray removeAllObjects];
    
    if (fileArray.count == 0) {//全部下载完毕
        
        completionHandler(self.failureTaskArray);
        return;
    }
    
    self.completionHandler = completionHandler;
    [self.taskArray setArray:fileArray];
    [self performDeleteTask];
}


@end
