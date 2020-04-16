//
//  APKRefreshLocalFilesTool.h
//  Innowa
//
//  Created by Mac on 17/4/25.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define APKHaveRefreshLocalFilesNotification @"APKHaveRefreshLocalFilesNotification"

@interface APKRefreshLocalFilesTool : NSObject

@property (strong,nonatomic) NSManagedObjectContext *context;
@property (assign) BOOL enable;
@property (assign) NSInteger photoCount;
@property (assign) NSInteger videoCount;
@property (assign) NSInteger eventCount;
@property (assign) NSInteger rearPhotoCount;
@property (assign) NSInteger rearVideoCount;
@property (assign) NSInteger rearEventCount;
@property (assign) NSInteger collectCount;


+ (instancetype)sharedInstace;
- (void)updateAllFileCount;
- (void)updatePhotoCount;
- (void)updateVideoCount;
- (void)updateEventCount;


@end
