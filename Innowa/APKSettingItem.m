//
//  APKSettingItemInfo.m
//  Innowa
//
//  Created by Mac on 17/5/3.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKSettingItem.h"
#import "APKDVR.h"

@implementation APKSettingItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.title = nil;
        self.type = APKSettingItemTypeNormal;
        self.valueIndex = 0;
        self.textValue = nil;
    }
    return self;
}

- (void)setOption:(APKSettingItemOptions)option{
    
    _option = option;
    
    [self updateItemInfo];
}

- (void)updateItemInfo{
    
    APKDVRInfo *info = [APKDVR sharedInstance].info;
    switch (self.option) {
            //RECVideoResR
        case APKSettingItemOptionVideoResolution:
            
            self.title = NSLocalizedString(@"影像解析度", nil);
            self.type = APKSettingItemTypeCheckBox;
            self.valueIndex = info.videoRes;
            self.setProperty = @"Videores";
            self.setValues = @[@"1080P27D5",@"720P27D5"];
            self.setDisplayValues = @[@"1080P 27.5fps",@"720P 27.5fps"];
            
            break;
        case APKSettingItemTypeParkingModeSensitivity:
               
               self.title = NSLocalizedString(@"移動偵測靈敏度", nil);
               self.type = APKSettingItemTypeCheckBox;
               self.valueIndex = info.MTD;
               self.setProperty = @"MTD";
               self.setValues = @[@"LOW",@"MIDDLE",@"HIGH"];
               self.setDisplayValues = @[@"一般",@"高",@"非常高"];
               
               break;
        case APKSettingItemOptionVideoResolutionRear:
            
            self.title = NSLocalizedString(@"后置影像解析度", nil);
            self.type = APKSettingItemTypeCheckBox;
            self.valueIndex = info.videoResR;
            self.setProperty = @"VideoresR";
            self.setValues = @[@"1080P27D5"];
            self.setDisplayValues = @[@"1080P 27.5fps"];
            
            break;
        case APKSettingItemOptionRecordSound:
            
            self.title = NSLocalizedString(@"声音记录", nil);
            self.type = APKSettingItemTypeSwitch;
            self.valueIndex = info.recordSound;
            self.setProperty = @"Video";
            self.setValues = @[@"mute",@"unmute"];
            self.setDisplayValues = @[@(NO),@(YES)];
            break;
            
        case APKSettingItemOptionScreenSetting:
            
            self.title = NSLocalizedString(@"荧幕设定", nil);
            self.type = APKSettingItemTypeCheckBox;
            self.valueIndex = info.LCDPower;
            self.setProperty = @"LCDPowerSave";
            self.setValues = @[@"ON",@"7SEC",@"1MIN",@"3MIN"];
            self.setDisplayValues = @[@"开",@"7秒后关闭",@"1分钟后关闭",@"3分钟后关闭"];
            break;
        case APKSettingItemOptionVideoClipDuration:
            
            self.title = NSLocalizedString(@"录影间隔", nil);
            self.type = APKSettingItemTypeCheckBox;
            self.valueIndex = info.VideoClipTime;
            self.setProperty = @"VideoClipTime";
            self.setValues = @[@"30SEC",@"1MIN"];
            self.setDisplayValues = @[@"30秒钟",@"1分钟"];
            break;
        case APKSettingItemOptionParkingModeTime:
            
            self.title = NSLocalizedString(@"泊車模式長度", nil);
            self.type = APKSettingItemTypeCheckBox;
            self.valueIndex = info.parkingModeTime;
            self.setProperty = @"ParkingModeTime";
            self.setValues = @[@"ON",@"0HOUR",@"30MIN",@"1HOUR",@"6HOUR",@"12HOUR"];
            self.setDisplayValues = @[@"時常開啟",@"0小時",@"30分鐘",@"1小時",@"6小時",@"12小時"];
            break;
        case APKSettingItemOptionExposureValue:
            
            self.title = NSLocalizedString(@"曝光值", nil);
            self.type = APKSettingItemTypeCheckBox;
            self.valueIndex = info.EV;
            self.setProperty = @"EV";
            self.setValues = [NSArray arrayWithObjects:@"EVN200", @"EVN167", @"EVN133", @"EVN100", @"EVN067", @"EVN033", @"EV0", @"EVP033", @"EVP067", @"EVP100", @"EVP133", @"EVP167", @"EVP200", nil];
//            self.setValues = [NSArray arrayWithObjects:@"EVN200", @"EVN100", @"EV0", @"EVP100",  @"EVP200", nil];

            self.setDisplayValues = @[@"-2      ",@"-1.7      ",@"-1.3     ",@"-1      ",@"-0.7      ",@"-0.3     ",@"0       ",@"0.3        ",@"0.7        ",@"1       ",@"1.3       ",@"1.7       ",@"2     "];
//            self.setDisplayValues = @[@"-2      ",@"-1      ",@"0       ",@"1       ",@"2     "];
            break;
        case APKSettingItemOptionPowerFrequency:
            
            self.title = NSLocalizedString(@"电源频率", nil);
            self.type = APKSettingItemTypeCheckBox;
            self.valueIndex = info.Flicker;
            self.setProperty = @"Flicker";
            self.setValues = @[@"50Hz",@"60Hz"];
            self.setDisplayValues = @[@"50Hz",@"60Hz"];
            break;
        case APKSettingItemLoopRecordingSetting:
            self.title = NSLocalizedString(@"循环录影模式", nil);
            self.type = APKSettingItemTypeCheckBox;
            self.valueIndex = info.normalFileSave;
            self.setProperty = @"NormalRecordFileSave";
            self.setValues = @[@"All_Loop_Recording",@"Loop_Recording_Except_Event",@"No_Loop_Recording"];
            self.setDisplayValues = @[@"循環錄影所有檔案",@"禁止事件檔案循環錄影",@"禁止所有檔案循環錄影"];
            break;
        case APKSettingItemParkingModeLoopRecording:
            self.title = NSLocalizedString(@"泊车模式档案保存", nil);
            self.type = APKSettingItemTypeCheckBox;
            self.valueIndex = info.parkingFileSave;
            self.setProperty = @"ParkRecordFileSave";
            self.setValues = @[@"All_Loop_Recording",@"TLapse_Loop_Recording"];
            self.setDisplayValues = @[@"循環錄影所有檔案 ",@"禁止事件檔案循環錄影 "];
            break;
        case APKSettingItemDefaultScreenDisPlay:
            self.title = NSLocalizedString(@"预设屏幕显示", nil);
            self.type = APKSettingItemTypeCheckBox;
            self.valueIndex = info.defaultScreenDisplay;
            self.setProperty = @"DefaultScreenDisplay";
            self.setValues = @[@"F_Main_R_PIP",@"R_Main_F_PIP",@"F_Only",@"R_Only"];
            self.setDisplayValues = @[@"前鏡頭為主",@"後鏡頭為主",@"只顯示前鏡",@"只顯示後鏡"];
            break;
        case APKSettingItemHideMenuBarAutomatically:
            self.title = NSLocalizedString(@"自动隐藏下方显示列", nil);
            self.type = APKSettingItemTypeSwitch;
            self.valueIndex = info.hideMenuBarAutomatically;
            self.setProperty = @"AutoHideButtonMenu";
            self.setValues = @[@"OFF",@"ON"];
            self.setDisplayValues = @[@(NO),@(YES)];
            break;
        case APKSettingItemTypeRearCameraVideo:
            self.title = NSLocalizedString(@"后镜头录像", nil);
            self.type = APKSettingItemTypeCheckBox;
            self.valueIndex = info.rearCameraVideo;
            self.setProperty = @"RearCameraDisplay";
            self.setValues = @[@"Normal",@"Up_Side_Down",@"Mirrored"];
            self.setDisplayValues = @[@"正常",@"上下倒轉",@"鏡像"];
            break;
        case APKSettingItemOptionParkingMode:
            
            self.title = NSLocalizedString(@"停车模式", nil);
            self.type = APKSettingItemTypeCheckBox;
            self.valueIndex = info.ParkMode;
            self.setProperty = @"ParkMode";
//            self.setValues = @[@"OFF",@"GSR",@"MDT",@"GSR_MDT"];
            self.setValues = info.ParkMode != 0 ?  @[@"OFF",@"GSR",@"MDT",@"GSR_MDT"] : @[@"OFF"];
            self.setDisplayValues = info.ParkMode != 0 ? @[@"关",@"震动侦测",@"移动侦测",@"自动侦测"] : @[@"关"];

//            self.setDisplayValues = @[@"关",@"震动侦测",@"移动侦测",@"自动侦测"];
            break;
        case APKSettingItemOptionCollisionDetection:
        {
            self.title = NSLocalizedString(@"碰撞侦测", nil);
            self.type = APKSettingItemTypeCheckBox;
            
            if ([info.GSensorStr isEqualToString:@"1.0;1.0;1.0"])
                self.valueIndex = 0;
            else if ([info.GSensorStr isEqualToString:@"1.5;1.5;1.5"])
                self.valueIndex = 1;
            else if ([info.GSensorStr isEqualToString:@"2.5;2.5;2.5"])
                self.valueIndex = 2;
            else
                self.valueIndex = 3;
//            self.valueIndex = info.GSensor;
            self.setProperty = @"GSensor";
//            self.setValues = @[@"OFF",@"LEVEL0",@"LEVEL2",@"LEVEL4"];
            self.setValues = @[@"LEVEL2",@"LEVEL3",@"LEVEL4",@"GSensorOFF"];

            NSString *customGsensorStr = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"自定义:", nil),info.GSensorStr];
//            self.setDisplayValues = @[customGsensorStr,@"低灵敏度",@"中灵敏度",@"高灵敏度"];
            self.setDisplayValues = @[@"高灵敏度",@"中灵敏度",@"低灵敏度",customGsensorStr];

            break;
        }
        case APKSettingItemOptionTimeMark:
            
            self.title = NSLocalizedString(@"时间标记", nil);
            self.type = APKSettingItemTypeSwitch;
            self.valueIndex = info.TimeStamp;
            self.setProperty = @"TimeStamp";
            self.setValues = @[@"OFF",@"ON"];
            self.setDisplayValues = @[@(NO),@(YES)];
            break;
            //SET
        case APKSettingItemOptionTimeSetting:
            
            self.title = NSLocalizedString(@"时间设定", nil);
            self.type = APKSettingItemTypeNormal;
            break;
        case APKSettingItemOptionSoundEffect:
            
            self.title = NSLocalizedString(@"音效设定", nil);
            self.type = APKSettingItemTypeSwitch;
            self.valueIndex = info.SoundIndicator;
            self.setProperty = @"KeyTone";
            self.setValues = @[@"OFF",@"ON"];
            self.setDisplayValues = @[@(NO),@(YES)];
            break;
        case APKSettingItemOptionVolume:
            
            self.title = NSLocalizedString(@"音量", nil);
            self.type = APKSettingItemTypeCheckBox;
            self.valueIndex = info.Volume;
            self.setProperty = @"Volume";
            self.setValues = @[@"LV0",@"LV1",@"LV2",@"LV3",@"LV4",@"LV5",@"LV6",@"LV7",@"LV8",@"LV9",@"LV10"];
            self.setDisplayValues = @[@"LV0     ",@"LV1     ",@"LV2     ",@"LV3     ",@"LV4     ",@"LV5     ",@"LV6     ",@"LV7     ",@"LV8     ",@"LV9     ",@"LV10    "];
            break;
        case APKSettingItemOptionLanguage:
            
            self.title = NSLocalizedString(@"语言设定", nil);
            self.type = APKSettingItemTypeCheckBox;
            self.valueIndex = info.Language;
            self.setProperty = @"Language";
            //这个语言顺序改了的话，需要顺便改一下设置语言的地方。。。
            self.setValues = @[@"ENGLISH",@"TCHINESE",@"JAPANESE"];
            self.setDisplayValues = @[@"英",@"繁中",@"日"];
            break;
        case APKSettingItemOptionTimeZone:
            
            self.title = NSLocalizedString(@"设定时区", nil);
            self.type = APKSettingItemTypeCheckBox;
            self.valueIndex = info.TimeZone;
            self.setProperty = @"TimeZone";
            self.setValues = @[@"M12",@"M11",@"M10",@"M9",@"M8",@"M7",@"M6",@"M5",@"M4",@"M330",@"M3",@"M2",@"M1",@"GMT",@"P1",@"P2",@"P3",@"P330",@"P4",@"P430",@"P5",@"P530",@"P545",@"P6",@"P630",@"P7",@"P8",@"P9",@"P930",@"P10",@"P11",@"P12",@"P13"];
            self.setDisplayValues = @[@"GMT -12:00",@"GMT -11:00",@"GMT -10:00",@"GMT -09:00",@"GMT -08:00",@"GMT -07:00",@"GMT -06:00",@"GMT -05:00",@"GMT -04:00",@"GMT -03:30",@"GMT -03:00",@"GMT -02:00",@"GMT -01:00",@"GMT  00:00",@"GMT +01:00",@"GMT +02:00",@"GMT +03:00",@"GMT +03:30",@"GMT +04:00",@"GMT +04:30",@"GMT +05:00",@"GMT +05:30",@"GMT +05:45",@"GMT +06:00",@"GMT +06:30",@"GMT +07:00",@"GMT +08:00",@"GMT +09:00",@"GMT +09:30",@"GMT +10:00",@"GMT +11:00",@"GMT +12:00",@"GMT +13:00"];
            
            break;
        case APKSettingItemOptionSatelliteTimeSync:
            
            self.title = NSLocalizedString(@"卫星时间同步", nil);
            self.type = APKSettingItemTypeSwitch;
            self.valueIndex = info.SatelliteSync;
            self.setProperty = @"SatelliteSync";
            self.setValues = @[@"OFF",@"ON"];
            self.setDisplayValues = @[@(NO),@(YES)];
            
            break;
        case APKSettingItemOptionModifyWifi:
            
            self.title = NSLocalizedString(@"Wi-Fi设置", nil);
            self.type = APKSettingItemTypeNormal;
            break;
            
            //FILE
        case APKSettingItemOptionFormat:
            
            self.title = NSLocalizedString(@"格式化", nil);
            self.type = APKSettingItemTypeNormal;
            self.setProperty = @"SD0";
            self.setValues = @[@"format"];
            self.setDisplayValues = @[@"format"];
            
            break;
        case APKSettingItemOptionSDCardInfo:
            
            self.title = NSLocalizedString(@"SD卡状态", nil);
            self.type = APKSettingItemTypeNormal;
            break;
            
            //ADV
        case APKSettingItemOptionFactoryReset:
            
            self.title = NSLocalizedString(@"恢复出厂设置", nil);
            self.type = APKSettingItemTypeNormal;
            self.setProperty = @"FactoryReset";
            self.setValues = @[@"Camera"];
            self.setDisplayValues = @[@"Camera"];
            
            break;
        case APKSettingItemOptionSoftwareVersion:
            
            self.title = NSLocalizedString(@"软件版本", nil);
            self.type = APKSettingItemTypeText;
            self.textValue = info.FWversion;
            
            break;
        case APKSettingAppVersion:
            self.title = NSLocalizedString(@"APP版本号", nil);
            self.type = APKSettingItemTypeText;
            self.textValue = @"1.8";
            break;
        case APKSettingAppUpdate:
            self.title = NSLocalizedString(@"APP更新", nil);
            self.type = APKSettingItemTypeNormal;
            break;
        case APKSettingItemOptionVelocityUnit:
            
            self.title = NSLocalizedString(@"速度单位", nil);
            self.type = APKSettingItemTypeCheckBox;
            self.valueIndex = info.SpeedUnit;
            self.setProperty = @"SpeedUnit";
            self.setValues = @[@"KMH",@"MPH"];
            self.setDisplayValues = @[@"Km/h",@"Mph"];
            
            break;
        case APKSettingItemOptionCustomSpeedLimitTips:
            
            self.title = NSLocalizedString(@"自定限速提示", nil);
            self.type = APKSettingItemTypeCheckBox;
            self.valueIndex = info.SpeedLimitAlert;
            self.setProperty = @"SpeedLimitAlert";
            self.setValues = @[@"OFF",@"50KMH",@"60KMH",@"70KMH",@"80KMH",@"90KMH",@"100KMH",@"110KMH",@"120KMH",@"130KMH",@"140KMH",@"150KMH",@"160KMH",@"170KMH",@"180KMH",@"190KMH",@"200KMH"];
            if (info.SpeedUnit == 0) {
                
                self.setDisplayValues = @[@"关",@"50km/h",@"60km/h",@"70km/h",@"80km/h",@"90km/h",@"100km/h",@"110km/h",@"120km/h",@"130km/h",@"140km/h",@"150km/h",@"160km/h",@"170km/h",@"180km/h",@"190km/h",@"200km/h"];

            }else if (info.SpeedUnit == 1){
                
                self.setDisplayValues = @[@"关",@"30Mph",@"35Mph",@"40Mph",@"50Mph",@"55Mph",@"60Mph",@"65Mph",@"75Mph",@"80Mph",@"85Mph",@"90Mph",@"100Mph",@"105Mph",@"110Mph",@"115Mph",@"125Mph"];
            }
            
            break;
        case APKSettingItemOptionHelp:
            
            self.title = NSLocalizedString(@"帮助", nil);
            self.type = APKSettingItemTypeNormal;
            break;
            
        case APKSettingItemOptionAbout:
            
            self.title = NSLocalizedString(@"关于innowa", nil);
            self.type = APKSettingItemTypeNormal;
            break;
    }
}

@end
