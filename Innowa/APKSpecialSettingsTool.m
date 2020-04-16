
//
//  APKSpecialSettingsTool.m
//  Innowa
//
//  Created by Mac on 17/6/7.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKSpecialSettingsTool.h"
#import "APKCommonTaskTool.h"
#import "APKDVR.h"

@interface APKSpecialSettingsTool ()

@property (strong,nonatomic) APKCommonTaskTool *taskTool;

@end

@implementation APKSpecialSettingsTool

#pragma mark - getter

- (APKCommonTaskTool *)taskTool{
    
    if (!_taskTool) {
        _taskTool = [[APKCommonTaskTool alloc] init];
    }
    return _taskTool;
}

#pragma mark - private method

- (void)stopRecord:(APKSetCompletionHandler)completionHandler{
    
    __weak typeof(self)weakSelf = self;
    [self.taskTool getRecordState:^(BOOL success) {
       
        weakSelf.taskTool = nil;
        if (success) {
            APKDVR *dvr = [APKDVR sharedInstance];
            if (!dvr.info.isRecording) {
                completionHandler(YES);
            }else{
                [weakSelf.taskTool setDVRWithProperty:@"Video" value:@"record" completionHandler:^(BOOL success) {
                    weakSelf.taskTool = nil;
                    completionHandler(success);
                }];
            }
        }else{
            completionHandler(NO);
        }
    }];
}

#pragma mark - public method

- (void)setDVRWithProperty:(NSString *)property value:(NSString *)value completionHanlder:(APKSetCompletionHandler)completionHandler{
    
    [self stopRecord:^(BOOL success) {
        if (!success) {
            completionHandler(NO);
        }else{
            
            __weak typeof(self)weakSelf = self;
            [self.taskTool setDVRWithProperty:property value:value completionHandler:^(BOOL success) {
                weakSelf.taskTool = nil;
                BOOL result = success;
                if ([property isEqualToString:@"FactoryReset"] && result) {
                    [weakSelf.taskTool setDVRWithProperty:@"Video" value:@"record" completionHandler:^(BOOL success) {
                        weakSelf.taskTool = nil;
                    }];
                    completionHandler(result);
                }else{
                    [weakSelf.taskTool setDVRWithProperty:@"Video" value:@"record" completionHandler:^(BOOL success) {
                        weakSelf.taskTool = nil;
                        completionHandler(result);
                    }];
                }
            }];
        }
    }];
}

@end
