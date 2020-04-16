//
//  APKDVRStates.h
//  AITBrain
//
//  Created by Mac on 17/3/21.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APKDVRTask.h"

typedef enum : NSUInteger {
    kAPKDVRStateNone,
    kAPKDVRStateExcuting,
    kAPKDVRStateSuccess,
    kAPKDVRStateFailure,
} APKDVRState;

@interface APKDVRStates : NSObject

@property (assign) APKDVRState getWifiInfo;
@property (assign) APKDVRState takePhoto;
@property (assign) APKDVRState getPhotoList;
@property (assign) APKDVRState getVideoList;
@property (assign) APKDVRState getEventList;
@property (assign) APKDVRState getParkTimeList;//新增
@property (assign) APKDVRState getParkEventList;
@property (assign) APKDVRState getLiveInfo;
@property (assign) APKDVRState deleteFile;
@property (assign) APKDVRState getSettingInfo;
@property (assign) APKDVRState getRecordState;
@property (assign) APKDVRState modifyWifi;
@property (assign) APKDVRState updateWifi;
@property (assign) APKDVRState findMe;
@property (assign) APKDVRState recordEvent;
@property (assign) APKDVRState setDVR;
@property (assign) APKDVRState getDVR;
@property (assign) APKDVRState checkRearCamera;
@property (assign) APKDVRState setRearCamera;
@property (assign) APKDVRState setFontCamera;
@property (assign) APKDVRState toggleRecordState;
@property (assign) APKDVRState getCameraInfo;

- (BOOL)updateWithTask:(APKDVRTask *)task;
- (void)updateWithTaskId:(NSInteger)taskId rval:(NSInteger)rval;

@end
