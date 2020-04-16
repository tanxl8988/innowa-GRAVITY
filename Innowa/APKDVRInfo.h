//
//  APKDVRInfo.h
//  AITBrain
//
//  Created by Mac on 17/3/21.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APKDVRInfo : NSObject

//common
@property (strong,nonatomic) NSArray *photos;
@property (strong,nonatomic) NSArray *videos;
@property (strong,nonatomic) NSArray *events;
@property (strong,nonatomic) NSArray *parkTime;
@property (strong,nonatomic) NSArray *parkEvent;
@property (strong,nonatomic) NSURL *liveUrl;
@property (nonatomic) float liveWHRatio;
@property (strong,nonatomic) NSString *ssid;
@property (strong,nonatomic) NSString *encryptionKey;
@property (assign) BOOL isRecording;
@property (strong,nonatomic) NSString *totalSpace;
@property (strong,nonatomic) NSString *freeSpace;
@property (assign) BOOL haveRearCamera;
@property (nonatomic,retain) NSString *spaceInfo;
@property (nonatomic,assign) BOOL isFrontCamera;



//settings
@property (assign) BOOL haveLoadSettingInfo;
@property (assign) NSInteger videoRes;
@property (assign) NSInteger videoResR;
@property (assign) NSInteger recordSound;
@property (assign) NSInteger LCDPower;
@property (assign) NSInteger VideoClipTime;
@property (assign) NSInteger EV;
@property (assign) NSInteger Flicker;
@property (assign) NSInteger ParkMode;
@property (assign) NSInteger GSensor;
@property (nonatomic,retain) NSString *GSensorStr;
@property (assign) NSInteger TimeStamp;
@property (assign) NSInteger SoundIndicator;
@property (assign) NSInteger Volume;
@property (assign) NSInteger Language;
@property (assign) NSInteger TimeZone;
@property (assign) NSInteger SatelliteSync;
@property (assign) NSInteger SpeedUnit;
@property (assign) NSInteger SpeedLimitAlert;
@property (assign) NSInteger normalFileSave;
@property (assign) NSInteger parkingFileSave;
@property (assign) NSInteger defaultScreenDisplay;
@property (assign) NSInteger hideMenuBarAutomatically;
@property (assign) NSInteger rearCameraVideo;
@property (assign) NSInteger parkingModeTime;
@property (assign) NSInteger MTD;


@property (strong,nonatomic) NSString *FWversion;
@property (nonatomic ,retain) NSString *parkingModeInfo;


- (void)updateWithTaskId:(NSInteger)taskId data:(NSData *)data;

@end
