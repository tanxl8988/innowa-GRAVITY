//
//  APKGetDVRConnectionInfo.m
//  Innowa
//
//  Created by Mac on 17/7/5.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKGetDVRConnectionInfo.h"
#import "APKDVR.h"


@interface APKGetDVRConnectionInfo ()

@property (copy,nonatomic) APKGetDVRConnectionInfoCompleteHandler completionHandler;

@end

@implementation APKGetDVRConnectionInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        APKDVR *dvr = [APKDVR sharedInstance];
        [dvr addObserver:self forKeyPath:@"states.getSettingInfo" options:NSKeyValueObservingOptionNew context:nil];
        [dvr addObserver:self forKeyPath:@"states.getRecordState" options:NSKeyValueObservingOptionNew context:nil];
        [dvr addObserver:self forKeyPath:@"states.checkRearCamera" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc
{
    APKDVR *dvr = [APKDVR sharedInstance];
    [dvr removeObserver:self forKeyPath:@"states.getSettingInfo"];
    [dvr removeObserver:self forKeyPath:@"states.getRecordState"];
    [dvr removeObserver:self forKeyPath:@"states.checkRearCamera"];
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"states.getSettingInfo"]) {
        
        APKDVRState state = [change[@"new"] integerValue];
        if (state == kAPKDVRStateSuccess) {
            
            APKDVRTask *task = [APKDVRTask getRecordStateTask];
            [[APKDVR sharedInstance] performTask:task];
            
        }else if (state == kAPKDVRStateFailure){
            
            self.completionHandler(NO);
        }
        
    }else if([keyPath isEqualToString:@"states.getRecordState"]){
        
        APKDVRState state = [change[@"new"] integerValue];
        if (state == kAPKDVRStateSuccess) {
            
            APKDVRTask *task = [APKDVRTask checkRearCameraTask];
            [[APKDVR sharedInstance] performTask:task];
            
        }else if (state == kAPKDVRStateFailure){
            
            self.completionHandler(NO);
        }
        
    }else if([keyPath isEqualToString:@"states.checkRearCamera"]){
        
        APKDVRState state = [change[@"new"] integerValue];
        if (state == kAPKDVRStateSuccess) {
            
            self.completionHandler(YES);
            
        }else if (state == kAPKDVRStateFailure){
            
            self.completionHandler(YES);//new add(临时解决)
        }
    }
}

#pragma mark - public method

- (void)execute:(APKGetDVRConnectionInfoCompleteHandler)completionHandler{
    
    self.completionHandler = completionHandler;
    APKDVRTask *task = [APKDVRTask getSettingInfoTask];
    [[APKDVR sharedInstance] performTask:task];
}

@end
