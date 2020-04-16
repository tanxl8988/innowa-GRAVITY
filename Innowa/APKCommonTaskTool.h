//
//  APKCommonTaskTool.h
//  微米
//
//  Created by Mac on 17/4/21.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^APKCommonTaskCompleteHandler)(BOOL success);

@interface APKCommonTaskTool : NSObject

//normal
- (void)getWifiInfo:(APKCommonTaskCompleteHandler)completionHandler;
- (void)modifyWifiWithSSID:(NSString *)ssid password:(NSString *)password completionHandler:(APKCommonTaskCompleteHandler)completionHandler;
- (void)rebotWifi:(APKCommonTaskCompleteHandler)completionHandler;
- (void)updateWifiWithSSID:(NSString *)ssid password:(NSString *)password completionHandler:(APKCommonTaskCompleteHandler)completionHandler;
- (void)getSettingsInfo:(APKCommonTaskCompleteHandler)completionHandler;
- (void)getRecordState:(APKCommonTaskCompleteHandler)completionHandler;
- (void)takePhoto:(APKCommonTaskCompleteHandler)completionHandler;
- (void)recordEvent:(APKCommonTaskCompleteHandler)completionHandler;
- (void)getLiveInfo:(APKCommonTaskCompleteHandler)completionHandler;
- (void)findDVR:(APKCommonTaskCompleteHandler)completionHandler;
- (void)setRearCamera:(APKCommonTaskCompleteHandler)completionHandler;
- (void)setFontCamera:(APKCommonTaskCompleteHandler)completionHandler;
- (void)toggleRecordState:(APKCommonTaskCompleteHandler)completionHandler;
- (void)getParkingModeInfo:(APKCommonTaskCompleteHandler)completionHandler;
- (void)getCameraInfo:(APKCommonTaskCompleteHandler)completionHandler;

- (void)getLoginToken:(APKCommonTaskCompleteHandler)completionHandler;

//settings
- (void)setDVRWithProperty:(NSString *)property value:(NSString *)value completionHandler:(APKCommonTaskCompleteHandler)completionHandler;
- (void)getDVRWithProperty:(NSString *)property completionHandler:(APKCommonTaskCompleteHandler)completionHandler;

@end
