//
//  APKDVRTask.h
//  AITBrain
//
//  Created by Mac on 17/3/21.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APKDVRTask : NSObject

@property (strong,nonatomic) NSString *url;
@property (assign) int taskId;

+ (instancetype)getWifiInfoTask;
+ (instancetype)updateWifiTask;
+ (instancetype)modifyWifiTaskWithSSID:(NSString *)ssid encryptionKey:(NSString *)encryptionKey;
+ (instancetype)deleteFileTaskWithFileName:(NSString *)fileName;
+ (instancetype)getLiveInfoTask;
+ (instancetype)getEventListTaskWithCount:(NSInteger)count fromIndex:(NSInteger)index isRearCameraFile:(BOOL)isRearCameraFile;
+ (instancetype)getVideoListTaskWithCount:(NSInteger)count fromIndex:(NSInteger)index isRearCameraFile:(BOOL)isRearCameraFile;
+ (instancetype)getPhotoListTaskWithCount:(NSInteger)count fromIndex:(NSInteger)index isRearCameraFile:(BOOL)isRearCameraFile;
+ (instancetype)getParkTimeListTaskWithCount:(NSInteger)count fromIndex:(NSInteger)index isRearCameraFile:(BOOL)isRearCameraFile;
+ (instancetype)getParkEventListTaskWithCount:(NSInteger)count fromIndex:(NSInteger)index isRearCameraFile:(BOOL)isRearCameraFile;
+ (instancetype)takePhotoTask;
+ (instancetype)recordEventTask;
+ (instancetype)getRecordStateTask;
+ (instancetype)getSettingInfoTask;
+ (instancetype)findMeTask;
+ (instancetype)setDVRTaskWithProperty:(NSString *)property value:(NSString *)value;
+ (instancetype)getDVRTaskWithProperty:(NSString *)property;
+ (instancetype)checkRearCameraTask;
+ (instancetype)setRearCameraTask;
+ (instancetype)setFontCameraTask;
+ (instancetype)toggleRecordStateTask;

+ (instancetype)getLoginTokenTask;
+ (instancetype)getCameraInfoTask;


@end
