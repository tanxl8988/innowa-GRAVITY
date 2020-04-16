//
//  LocalFile.h
//  万能AIT
//
//  Created by Mac on 17/3/23.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "APKDVRFile.h"

@class DVRFile;

@interface LocalFile : NSManagedObject

@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSString *identifier;
@property (strong,nonatomic) NSDate *saveDate;//用作排序，本来是用下载的日期排序的，后来换做用文件录制的日期排序
@property (assign) int16_t type;
@property (assign) BOOL isCollected;//收藏
@property (strong,nonatomic) DVRFile *dvrFile;
@property (assign) BOOL isFromRearCamera;
@property (nonatomic,retain) NSString *gpsDataStr;

+ (LocalFile *)createWithFile:(DVRFile *)dvrFile fileDate:(NSDate *)fileDate identifier:(NSString *)identifier isCollected:(BOOL)isCollected isRearCameraFile:(BOOL)isRearCameraFile gpsData:(NSArray*)gpsArray context:(NSManagedObjectContext *)context;
+ (LocalFile *)getLocalFileWithName:(NSString *)name context:(NSManagedObjectContext *)context;
+ (NSArray *)getAllLocalFilesWithContext:(NSManagedObjectContext *)context;
//+ (NSArray *)getLocalFilesWithType:(APKDVRFileType)type context:(NSManagedObjectContext *)context;
+ (NSArray *)getLocalFilesWithType:(APKDVRFileType)type isFromRearCamera:(BOOL)isFromRearCamera context:(NSManagedObjectContext *)context;

+ (NSArray *)getCollectFilesWithContext:(NSManagedObjectContext *)context;

@end
