//
//  APKSettingItemInfo.h
//  Innowa
//
//  Created by Mac on 17/5/3.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    
    APKSettingItemTypeNormal,
    APKSettingItemTypeSwitch,
    APKSettingItemTypeCheckBox,
    APKSettingItemTypeText,

} APKSettingItemType;

typedef enum : NSUInteger {
    
    //REC
    APKSettingItemOptionVideoResolution,
    APKSettingItemOptionVideoResolutionRear,
    APKSettingItemOptionVideoClipDuration,
    APKSettingItemOptionScreenSetting,//荧幕设定
    APKSettingItemOptionRecordSound,
    APKSettingItemOptionCollisionDetection,//碰撞侦测
    APKSettingItemOptionTimeMark,//时间标记
    APKSettingItemOptionParkingMode,//停车模式
    APKSettingItemOptionPowerFrequency,//电源频率
    APKSettingItemOptionParkingModeTime,
    APKSettingItemOptionExposureValue,//曝光值
    APKSettingItemLoopRecordingSetting,
    APKSettingItemParkingModeLoopRecording,
    APKSettingItemDefaultScreenDisPlay,
    APKSettingItemHideMenuBarAutomatically,
    APKSettingItemTypeRearCameraVideo,
    APKSettingItemTypeParkingModeSensitivity,

    //FILE
    APKSettingItemOptionFormat,
    APKSettingItemOptionSDCardInfo,

    //SET
    APKSettingItemOptionModifyWifi,
    APKSettingItemOptionTimeSetting,
    APKSettingItemOptionTimeZone,
    APKSettingItemOptionSatelliteTimeSync,//卫星时间同步
    APKSettingItemOptionSoundEffect,//音效设定
    APKSettingItemOptionVolume,
    APKSettingItemOptionLanguage,
    
    //ADV
    APKSettingItemOptionVelocityUnit,//速度单位
    APKSettingItemOptionCustomSpeedLimitTips,//自定限速提示
    APKSettingItemOptionFactoryReset,
    APKSettingItemOptionSoftwareVersion,
    APKSettingItemOptionHelp,
    APKSettingItemOptionAbout,
    APKSettingAppVersion,
    APKSettingAppUpdate
    
} APKSettingItemOptions;

@interface APKSettingItem : NSObject

@property (strong,nonatomic) NSString *title;
@property (assign) APKSettingItemType type;
@property (assign) NSInteger valueIndex;
@property (strong,nonatomic) NSString *textValue;
@property (nonatomic) APKSettingItemOptions option;
@property (strong,nonatomic) NSString *setProperty;
@property (strong,nonatomic) NSArray *setValues;
@property (strong,nonatomic) NSArray *setDisplayValues;

- (void)updateItemInfo;

@end


