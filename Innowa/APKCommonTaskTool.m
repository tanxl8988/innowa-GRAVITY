//
//  APKCommonTaskTool.m
//  微米
//
//  Created by Mac on 17/4/21.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKCommonTaskTool.h"
#import "APKDVR.h"
#import "APKDVRTask.h"

@interface APKCommonTaskTool ()

@property (copy,nonatomic) APKCommonTaskCompleteHandler takePhotoHandler;
@property (copy,nonatomic) APKCommonTaskCompleteHandler modifyWifiHandler;
@property (copy,nonatomic) APKCommonTaskCompleteHandler rebotWifiHandler;
@property (copy,nonatomic) APKCommonTaskCompleteHandler updateWifiHandler;
@property (copy,nonatomic) APKCommonTaskCompleteHandler getLiveInfoHandler;
@property (copy,nonatomic) APKCommonTaskCompleteHandler getWifiInfoHandler;
@property (copy,nonatomic) APKCommonTaskCompleteHandler getSettingsInfoHandler;
@property (copy,nonatomic) APKCommonTaskCompleteHandler getRecordStateHandler;
@property (copy,nonatomic) APKCommonTaskCompleteHandler findDVRHandler;
@property (copy,nonatomic) APKCommonTaskCompleteHandler setDVRHandler;
@property (copy,nonatomic) APKCommonTaskCompleteHandler recordEventHandler;
@property (copy,nonatomic) APKCommonTaskCompleteHandler getDVRHandler;
@property (copy,nonatomic) APKCommonTaskCompleteHandler setRearCameraHandler;
@property (copy,nonatomic) APKCommonTaskCompleteHandler setFontCameraHandler;
@property (copy,nonatomic) APKCommonTaskCompleteHandler toggleRecordStateHandler;
@property (copy,nonatomic) APKCommonTaskCompleteHandler getCameraInfoHandler;


@property (strong,nonatomic) NSString *ssid;
@property (strong,nonatomic) NSString *password;

@end

@implementation APKCommonTaskTool

#pragma mark - life circle

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        APKDVR *dvr = [APKDVR sharedInstance];
        [dvr addObserver:self forKeyPath:@"states.takePhoto" options:NSKeyValueObservingOptionNew context:nil];
        [dvr addObserver:self forKeyPath:@"states.modifyWifi" options:NSKeyValueObservingOptionNew context:nil];
        [dvr addObserver:self forKeyPath:@"states.updateWifi" options:NSKeyValueObservingOptionNew context:nil];
        [dvr addObserver:self forKeyPath:@"states.getLiveInfo" options:NSKeyValueObservingOptionNew context:nil];
        [dvr addObserver:self forKeyPath:@"states.getSettingInfo" options:NSKeyValueObservingOptionNew context:nil];
        [dvr addObserver:self forKeyPath:@"states.getRecordState" options:NSKeyValueObservingOptionNew context:nil];
        [dvr addObserver:self forKeyPath:@"states.getWifiInfo" options:NSKeyValueObservingOptionNew context:nil];
        [dvr addObserver:self forKeyPath:@"states.findMe" options:NSKeyValueObservingOptionNew context:nil];
        [dvr addObserver:self forKeyPath:@"states.setDVR" options:NSKeyValueObservingOptionNew context:nil];
        [dvr addObserver:self forKeyPath:@"states.recordEvent" options:NSKeyValueObservingOptionNew context:nil];
        [dvr addObserver:self forKeyPath:@"states.getDVR" options:NSKeyValueObservingOptionNew context:nil];
        [dvr addObserver:self forKeyPath:@"states.setRearCamera" options:NSKeyValueObservingOptionNew context:nil];
        [dvr addObserver:self forKeyPath:@"states.setFontCamera" options:NSKeyValueObservingOptionNew context:nil];
        [dvr addObserver:self forKeyPath:@"states.toggleRecordState" options:NSKeyValueObservingOptionNew context:nil];
        [dvr addObserver:self forKeyPath:@"states.getCameraInfo" options:NSKeyValueObservingOptionNew context:nil];

    }
    return self;
}

- (void)dealloc
{
    APKDVR *dvr = [APKDVR sharedInstance];
    [dvr removeObserver:self forKeyPath:@"states.takePhoto"];
    [dvr removeObserver:self forKeyPath:@"states.modifyWifi"];
    [dvr removeObserver:self forKeyPath:@"states.updateWifi"];
    [dvr removeObserver:self forKeyPath:@"states.getLiveInfo"];
    [dvr removeObserver:self forKeyPath:@"states.getSettingInfo"];
    [dvr removeObserver:self forKeyPath:@"states.getRecordState"];
    [dvr removeObserver:self forKeyPath:@"states.getWifiInfo"];
    [dvr removeObserver:self forKeyPath:@"states.findMe"];
    [dvr removeObserver:self forKeyPath:@"states.setDVR"];
    [dvr removeObserver:self forKeyPath:@"states.recordEvent"];
    [dvr removeObserver:self forKeyPath:@"states.getDVR"];
    [dvr removeObserver:self forKeyPath:@"states.setRearCamera"];
    [dvr removeObserver:self forKeyPath:@"states.setFontCamera"];
    [dvr removeObserver:self forKeyPath:@"states.toggleRecordState"];
    [dvr removeObserver:self forKeyPath:@"states.getCameraInfo"];
    NSLog(@"%s",__func__);
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([keyPath isEqualToString:@"states.takePhoto"]) {
            
            if (!self.takePhotoHandler) {
                return;
            }
            
            APKDVRState state = [change[@"new"] integerValue];
            if (state == kAPKDVRStateFailure) {
                self.takePhotoHandler(NO);
                self.takePhotoHandler = nil;
            }else if (state == kAPKDVRStateSuccess){
                self.takePhotoHandler(YES);
                self.takePhotoHandler = nil;
            }
            
        }else if([keyPath isEqualToString:@"states.modifyWifi"]){
            
            if (!self.modifyWifiHandler) {
                return;
            }
            
            APKDVRState state = [change[@"new"] integerValue];
            if (state == kAPKDVRStateFailure) {
                self.modifyWifiHandler(NO);
                self.modifyWifiHandler = nil;
            }else if (state == kAPKDVRStateSuccess){
                [APKDVR sharedInstance].info.ssid = self.ssid;
                [APKDVR sharedInstance].info.encryptionKey = self.password;
                self.modifyWifiHandler(YES);
                self.modifyWifiHandler = nil;
            }
            
        }else if([keyPath isEqualToString:@"states.updateWifi"]){
            
            if (!self.rebotWifiHandler) {
                return;
            }
            
            APKDVRState state = [change[@"new"] integerValue];
            if (state == kAPKDVRStateFailure) {
                self.rebotWifiHandler(NO);
                self.rebotWifiHandler = nil;
            }else if (state == kAPKDVRStateSuccess){
                self.rebotWifiHandler(YES);
                self.rebotWifiHandler = nil;
            }
            
        }else if([keyPath isEqualToString:@"states.getLiveInfo"]){
            
            if (!self.getLiveInfoHandler) {
                return;
            }
            
            APKDVRState state = [change[@"new"] integerValue];
            if (state == kAPKDVRStateFailure) {
                self.getLiveInfoHandler(NO);
                self.getLiveInfoHandler = nil;
            }else if (state == kAPKDVRStateSuccess){
                self.getLiveInfoHandler(YES);
                self.getLiveInfoHandler = nil;
            }
            
        }else if([keyPath isEqualToString:@"states.getSettingInfo"]){
            
            if (!self.getSettingsInfoHandler) {
                return;
            }
            
            APKDVRState state = [change[@"new"] integerValue];
            if (state == kAPKDVRStateFailure) {
                self.getSettingsInfoHandler(NO);
                self.getSettingsInfoHandler = nil;
            }else if (state == kAPKDVRStateSuccess){
                self.getSettingsInfoHandler(YES);
                self.getSettingsInfoHandler = nil;
            }
            
        }else if([keyPath isEqualToString:@"states.getRecordState"]){
            
            if (!self.getRecordStateHandler) {
                return;
            }
            
            APKDVRState state = [change[@"new"] integerValue];
            if (state == kAPKDVRStateFailure) {
                self.getRecordStateHandler(NO);
                self.getRecordStateHandler = nil;
            }else if (state == kAPKDVRStateSuccess){
                self.getRecordStateHandler(YES);
                self.getRecordStateHandler = nil;
            }
            
        }else if([keyPath isEqualToString:@"states.getWifiInfo"]){
            
            if (!self.getWifiInfoHandler) {
                return;
            }
            
            APKDVRState state = [change[@"new"] integerValue];
            if (state == kAPKDVRStateFailure) {
                self.getWifiInfoHandler(NO);
                self.getWifiInfoHandler = nil;
            }else if (state == kAPKDVRStateSuccess){
                self.getWifiInfoHandler(YES);
                self.getWifiInfoHandler = nil;
            }
            
        }else if([keyPath isEqualToString:@"states.findMe"]){
            
            if (!self.findDVRHandler) {
                return;
            }
            
            APKDVRState state = [change[@"new"] integerValue];
            if (state == kAPKDVRStateFailure) {
                self.findDVRHandler(NO);
                self.findDVRHandler = nil;
            }else if (state == kAPKDVRStateSuccess){
                self.findDVRHandler(YES);
                self.findDVRHandler = nil;
            }
            
        }else if ([keyPath isEqualToString:@"states.setDVR"]){
            
            if (!self.setDVRHandler) {
                return;
            }
            
            APKDVRState state = [change[@"new"] integerValue];
            if (state == kAPKDVRStateFailure) {
                self.setDVRHandler(NO);
                self.setDVRHandler = nil;
            }else if (state == kAPKDVRStateSuccess){
                self.setDVRHandler(YES);
                self.setDVRHandler = nil;
            }
            
        }else if ([keyPath isEqualToString:@"states.recordEvent"]){
            
            if (!self.recordEventHandler) {
                return;
            }
            
            APKDVRState state = [change[@"new"] integerValue];
            if (state == kAPKDVRStateFailure) {
                self.recordEventHandler(NO);
                self.recordEventHandler = nil;
            }else if (state == kAPKDVRStateSuccess){
                self.recordEventHandler(YES);
                self.recordEventHandler = nil;
            }
            
        }else if ([keyPath isEqualToString:@"states.getDVR"]){
            
            if (!self.getDVRHandler) {
                return;
            }
            
            APKDVRState state = [change[@"new"] integerValue];
            if (state == kAPKDVRStateFailure) {
                self.getDVRHandler(NO);
                self.getDVRHandler = nil;
            }else if (state == kAPKDVRStateSuccess){
                self.getDVRHandler(YES);
                self.getDVRHandler = nil;
            }
            
        }else if ([keyPath isEqualToString:@"states.setRearCamera"]){
            
            if (!self.setRearCameraHandler) {
                return;
            }
            
            APKDVRState state = [change[@"new"] integerValue];
            if (state == kAPKDVRStateFailure) {
                self.setRearCameraHandler(NO);
                self.setRearCameraHandler = nil;
            }else if (state == kAPKDVRStateSuccess){
                self.setRearCameraHandler(YES);
                self.setRearCameraHandler = nil;
            }
            
        }else if ([keyPath isEqualToString:@"states.setFontCamera"]){
            
            if (!self.setFontCameraHandler) {
                return;
            }
            
            APKDVRState state = [change[@"new"] integerValue];
            if (state == kAPKDVRStateFailure) {
                self.setFontCameraHandler(NO);
                self.setFontCameraHandler = nil;
            }else if (state == kAPKDVRStateSuccess){
                self.setFontCameraHandler(YES);
                self.setFontCameraHandler = nil;
            }
            
        }else if ([keyPath isEqualToString:@"states.toggleRecordState"]){
            
            if (!self.toggleRecordStateHandler) {
                return;
            }
            
            APKDVRState state = [change[@"new"] integerValue];
            if (state == kAPKDVRStateFailure) {
                self.toggleRecordStateHandler(NO);
                self.toggleRecordStateHandler = nil;
            }else if (state == kAPKDVRStateSuccess){
                self.toggleRecordStateHandler(YES);
                self.toggleRecordStateHandler = nil;
            }
            
        }else if([keyPath isEqualToString:@"states.getCameraInfo"])
        {
            if (!self.getCameraInfoHandler) {
                return;
            }
            
            APKDVRState state = [change[@"new"] integerValue];
            if (state == kAPKDVRStateFailure) {
                self.getCameraInfoHandler(NO);
                self.getCameraInfoHandler = nil;
            }else if (state == kAPKDVRStateSuccess){
                self.getCameraInfoHandler(YES);
                self.getCameraInfoHandler = nil;
            }
        }
    });
}

#pragma mark - public method

- (void)toggleRecordState:(APKCommonTaskCompleteHandler)completionHandler{
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected || dvr.states.getDVR == kAPKDVRStateExcuting) {
        
        completionHandler(NO);
        return;
    }
    
    self.toggleRecordStateHandler = completionHandler;
    APKDVRTask *task = [APKDVRTask toggleRecordStateTask];
    [dvr performTask:task];

}

- (void)setRearCamera:(APKCommonTaskCompleteHandler)completionHandler{
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected || dvr.states.getDVR == kAPKDVRStateExcuting) {
        
        completionHandler(NO);
        return;
    }
    
    self.setRearCameraHandler = completionHandler;
    APKDVRTask *task = [APKDVRTask setRearCameraTask];
    [dvr performTask:task];
}


- (void)setFontCamera:(APKCommonTaskCompleteHandler)completionHandler{
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected || dvr.states.getDVR == kAPKDVRStateExcuting) {
        
        completionHandler(NO);
        return;
    }
    
    self.setFontCameraHandler = completionHandler;
    APKDVRTask *task = [APKDVRTask setFontCameraTask];
    [dvr performTask:task];
}

- (void)getDVRWithProperty:(NSString *)property completionHandler:(APKCommonTaskCompleteHandler)completionHandler{
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected || dvr.states.getDVR == kAPKDVRStateExcuting) {
        
        completionHandler(NO);
        return;
    }
    
    self.getDVRHandler = completionHandler;
    APKDVRTask *task = [APKDVRTask getDVRTaskWithProperty:property];
    [dvr performTask:task];
}

- (void)getParkingModeInfo:(APKCommonTaskCompleteHandler)completionHandler
{
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected || dvr.states.getDVR == kAPKDVRStateExcuting) {
        
        completionHandler(NO);
        return;
    }
    
    self.getDVRHandler = completionHandler;
    APKDVRTask *task = [APKDVRTask getDVRTaskWithProperty:@"Camera.Menu.ParkingStatus"];
    [dvr performTask:task];
}

- (void)getLoginToken:(APKCommonTaskCompleteHandler)completionHandler{
    
    APKDVR *dvr = [APKDVR sharedInstance];
//    if (!dvr.isConnected || dvr.states.getDVR == kAPKDVRStateExcuting) {
//
//        completionHandler(NO);
//        return;
//    }
    
    self.getDVRHandler = completionHandler;
    APKDVRTask *task = [APKDVRTask getLoginTokenTask];
    [dvr performTask:task];
}


- (void)setDVRWithProperty:(NSString *)property value:(NSString *)value completionHandler:(APKCommonTaskCompleteHandler)completionHandler{
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected || dvr.states.setDVR == kAPKDVRStateExcuting) {
        
        completionHandler(NO);
        return;
    }
    
    self.setDVRHandler = completionHandler;
    
    APKDVRTask *task = [APKDVRTask setDVRTaskWithProperty:property value:value];
    [dvr performTask:task];
}

- (void)getRecordState:(APKCommonTaskCompleteHandler)completionHandler{
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected || dvr.states.getRecordState == kAPKDVRStateExcuting) {
        
        completionHandler(NO);
        return;
    }
    
    self.getRecordStateHandler = completionHandler;
    [dvr performTask:[APKDVRTask getRecordStateTask]];
}

- (void)modifyWifiWithSSID:(NSString *)ssid password:(NSString *)password completionHandler:(APKCommonTaskCompleteHandler)completionHandler{
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected || dvr.states.modifyWifi == kAPKDVRStateExcuting) {
        
        completionHandler(NO);
        return;
    }
    
    self.modifyWifiHandler = completionHandler;
    self.ssid = ssid;
    self.password = password;
    [dvr performTask:[APKDVRTask modifyWifiTaskWithSSID:ssid encryptionKey:password]];
}

- (void)rebotWifi:(APKCommonTaskCompleteHandler)completionHandler{
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected || dvr.states.updateWifi == kAPKDVRStateExcuting) {
        
        completionHandler(NO);
        return;
    }
    
    self.rebotWifiHandler = completionHandler;
    [dvr performTask:[APKDVRTask updateWifiTask]];
}

- (void)updateWifiWithSSID:(NSString *)ssid password:(NSString *)password completionHandler:(APKCommonTaskCompleteHandler)completionHandler{
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected || dvr.states.modifyWifi == kAPKDVRStateExcuting || dvr.states.updateWifi == kAPKDVRStateExcuting) {
        
        completionHandler(NO);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self modifyWifiWithSSID:ssid password:password completionHandler:^(BOOL success) {
        
        if (success) {
            
            [weakSelf rebotWifi:^(BOOL success) {
                
                completionHandler(YES);
            }];
            
        }else{
            
            completionHandler(NO);
        }
    }];
}

- (void)getSettingsInfo:(APKCommonTaskCompleteHandler)completionHandler{
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected || dvr.states.getSettingInfo == kAPKDVRStateExcuting) {
        
        completionHandler(NO);
        return;
    }
    
    self.getSettingsInfoHandler = completionHandler;
    [dvr performTask:[APKDVRTask getSettingInfoTask]];
    
}

- (void)getWifiInfo:(APKCommonTaskCompleteHandler)completionHandler{
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected || dvr.states.getWifiInfo == kAPKDVRStateExcuting) {
        
        completionHandler(NO);
        return;
    }
    
    self.getWifiInfoHandler = completionHandler;
    [dvr performTask:[APKDVRTask getWifiInfoTask]];
}

- (void)getCameraInfo:(APKCommonTaskCompleteHandler)completionHandler{
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected || dvr.states.getCameraInfo == kAPKDVRStateExcuting) {
        
        completionHandler(NO);
        return;
    }
    
    self.getCameraInfoHandler = completionHandler;
    [dvr performTask:[APKDVRTask getCameraInfoTask]];
}


- (void)findDVR:(APKCommonTaskCompleteHandler)completionHandler{
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected || dvr.states.findMe == kAPKDVRStateExcuting) {
        
        completionHandler(NO);
        return;
    }
    
    self.findDVRHandler = completionHandler;
    [dvr performTask:[APKDVRTask findMeTask]];
}

- (void)getLiveInfo:(APKCommonTaskCompleteHandler)completionHandler{
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected || dvr.states.getLiveInfo == kAPKDVRStateExcuting) {
        
        completionHandler(NO);
        return;
    }
    
    self.getLiveInfoHandler = completionHandler;
    [dvr performTask:[APKDVRTask getLiveInfoTask]];
}

- (void)takePhoto:(APKCommonTaskCompleteHandler)completionHandler{
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected || dvr.states.takePhoto == kAPKDVRStateExcuting) {
        
        completionHandler(NO);
        return;
    }
    
    self.takePhotoHandler = completionHandler;
    [dvr performTask:[APKDVRTask takePhotoTask]];
}

- (void)recordEvent:(APKCommonTaskCompleteHandler)completionHandler{
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected || dvr.states.recordEvent == kAPKDVRStateExcuting) {
        
        completionHandler(NO);
        return;
    }
    
    self.recordEventHandler = completionHandler;
    [dvr performTask:[APKDVRTask recordEventTask]];
}


@end
