//
//  APKRefreshLocalFilesTool.m
//  Innowa
//
//  Created by Mac on 17/4/25.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKRefreshLocalFilesTool.h"
#import "LocalFile.h"
#import <Photos/Photos.h>
#import "APKDVRFile.h"

@interface APKRefreshLocalFilesTool ()

@end

@implementation APKRefreshLocalFilesTool

static APKRefreshLocalFilesTool *instance = nil;
+ (instancetype)sharedInstace{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[APKRefreshLocalFilesTool alloc] init];
    });
    return instance;
}

#pragma mark - setter

- (void)setContext:(NSManagedObjectContext *)context{
    
    _context = context;
    
    [self validateLocalFiles];
}

#pragma mark - public method

- (void)updatePhotoCount{
    
    [self.context performBlock:^{
       
        BOOL refresh = NO;
        
        NSArray *fileArray = [LocalFile getLocalFilesWithType:kAPKDVRFileTypePhoto isFromRearCamera:NO context:self.context];
        if (fileArray.count != self.photoCount) {
            self.photoCount = fileArray.count;
            refresh = YES;
        }
        
        NSArray *rearFileArray = [LocalFile getLocalFilesWithType:kAPKDVRFileTypePhoto isFromRearCamera:YES context:self.context];
        if (rearFileArray.count != self.rearPhotoCount) {
            self.rearPhotoCount = rearFileArray.count;
            refresh = YES;
        }
        
        NSArray *collectArray = [LocalFile getCollectFilesWithContext:self.context];
        if (collectArray.count != self.collectCount) {
            self.collectCount = collectArray.count;
            refresh = YES;
        }
        
        if (refresh) {
            [[NSNotificationCenter defaultCenter] postNotificationName:APKHaveRefreshLocalFilesNotification object:nil];
        }
    }];
}

- (void)updateVideoCount{
    
    [self.context performBlock:^{
        
        BOOL refresh = NO;

        NSArray *fileArray = [LocalFile getLocalFilesWithType:kAPKDVRFileTypeVideo isFromRearCamera:NO context:self.context];
        if (fileArray.count != self.videoCount) {
            
            self.videoCount = fileArray.count;
            refresh = YES;
        }
        
        NSArray *rearFileArray = [LocalFile getLocalFilesWithType:kAPKDVRFileTypeVideo isFromRearCamera:YES context:self.context];
        if (rearFileArray.count != self.rearVideoCount) {
            
            self.rearVideoCount = rearFileArray.count;
            refresh = YES;
        }
        
        NSArray *collectArray = [LocalFile getCollectFilesWithContext:self.context];
        if (collectArray.count != self.collectCount) {
            self.collectCount = collectArray.count;
            refresh = YES;
        }
        
        if (refresh) {
            [[NSNotificationCenter defaultCenter] postNotificationName:APKHaveRefreshLocalFilesNotification object:nil];
        }
    }];
}

- (void)updateEventCount{
    
    [self.context performBlock:^{
        
        BOOL refresh = NO;

        NSArray *fileArray = [LocalFile getLocalFilesWithType:kAPKDVRFileTypeEvent isFromRearCamera:NO context:self.context];
        if (fileArray.count != self.eventCount) {
            
            self.eventCount = fileArray.count;
            refresh = YES;
        }
        
        NSArray *rearFileArray = [LocalFile getLocalFilesWithType:kAPKDVRFileTypeEvent isFromRearCamera:YES context:self.context];
        if (rearFileArray.count != self.rearEventCount) {
            
            self.rearEventCount = rearFileArray.count;
            refresh = YES;
        }
        
        NSArray *collectArray = [LocalFile getCollectFilesWithContext:self.context];
        if (collectArray.count != self.collectCount) {
            self.collectCount = collectArray.count;
            refresh = YES;
        }
        
        if (refresh) {
            [[NSNotificationCenter defaultCenter] postNotificationName:APKHaveRefreshLocalFilesNotification object:nil];
        }
    }];
}

- (void)updateAllFileCount{
    
    [self.context performBlock:^{
        
        BOOL refresh = NO;
        
        NSArray *photoArray = [LocalFile getLocalFilesWithType:kAPKDVRFileTypePhoto isFromRearCamera:NO context:self.context];
        if (photoArray.count != self.photoCount) {
            self.photoCount = photoArray.count;
            refresh = YES;
        }
        NSArray *rearFileArray = [LocalFile getLocalFilesWithType:kAPKDVRFileTypePhoto isFromRearCamera:YES context:self.context];
        if (rearFileArray.count != self.rearPhotoCount) {
            self.rearPhotoCount = rearFileArray.count;
            refresh = YES;
        }
        
        NSArray *videoArray = [LocalFile getLocalFilesWithType:kAPKDVRFileTypeVideo isFromRearCamera:NO context:self.context];
        if (videoArray.count != self.videoCount) {
            
            self.videoCount = videoArray.count;
            refresh = YES;
        }
        rearFileArray = [LocalFile getLocalFilesWithType:kAPKDVRFileTypeVideo isFromRearCamera:YES context:self.context];
        if (rearFileArray.count != self.rearVideoCount) {
            
            self.rearVideoCount = rearFileArray.count;
            refresh = YES;
        }

        NSArray *eventArray = [LocalFile getLocalFilesWithType:kAPKDVRFileTypeEvent isFromRearCamera:NO context:self.context];
        if (eventArray.count != self.eventCount) {
            
            self.eventCount = eventArray.count;
            refresh = YES;
        }
        rearFileArray = [LocalFile getLocalFilesWithType:kAPKDVRFileTypeEvent isFromRearCamera:YES context:self.context];
        if (rearFileArray.count != self.rearEventCount) {
            
            self.rearEventCount = rearFileArray.count;
            refresh = YES;
        }

        NSArray *collectArray = [LocalFile getCollectFilesWithContext:self.context];
        if (collectArray.count != self.collectCount) {
            
            self.collectCount = collectArray.count;
            refresh = YES;
        }
        
        if (refresh) {
            [[NSNotificationCenter defaultCenter] postNotificationName:APKHaveRefreshLocalFilesNotification object:nil];
        }
    }];
}

#pragma mark - private method

- (void)validateLocalFiles{
    
    NSManagedObjectContext *private = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [private setParentContext:self.context];
    [private performBlock:^{
        
        self.photoCount = 0;
        self.videoCount = 0;
        self.eventCount = 0;
        self.rearPhotoCount = 0;
        self.rearVideoCount = 0;
        self.rearEventCount = 0;
        self.collectCount = 0;
        
        NSArray *fileArray = [LocalFile getAllLocalFilesWithContext:private];
        for (LocalFile *file in fileArray) {
            
            PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[file.identifier] options:nil];
            if (result.count == 0) {
                
                NSLog(@"delete local file: %@",file.name);
                [private deleteObject:file];
                
            }else{
                
                switch (file.type) {
                    case kAPKDVRFileTypePhoto:
                        if (file.isFromRearCamera) {
                            self.rearPhotoCount += 1;
                        }else{
                            self.photoCount += 1;
                        }
                        break;
                    case kAPKDVRFileTypeVideo:
                        if (file.isFromRearCamera) {
                            self.rearVideoCount += 1;
                        }else{
                            self.videoCount += 1;
                        }
                        break;
                    case kAPKDVRFileTypeEvent:
                        if (file.isFromRearCamera) {
                            self.rearEventCount += 1;
                        }else{
                            self.eventCount += 1;
                        }
                        break;
                }
                
                if (file.isCollected) {
                    self.collectCount += 1;
                }
            }
        }
        
        NSError *error = nil;
        if (![private save:&error]) {
            NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
            abort();
        }
        
        [self.context performBlockAndWait:^{
            
            NSError *error = nil;
            if (![self.context save:&error]) {
                NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
                abort();
            }
            
            self.enable = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:APKHaveRefreshLocalFilesNotification object:nil];
            NSLog(@"✅完成local file的验证");
        }];
    }];
}

@end
