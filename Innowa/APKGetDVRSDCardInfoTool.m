//
//  APKGetDVRSDCardInfoTool.m
//  Innowa
//
//  Created by Mac on 17/5/24.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKGetDVRSDCardInfoTool.h"
#import "APKCommonTaskTool.h"
#import "APKDVR.h"

@implementation APKSDCardInfo

@end

@interface APKGetDVRSDCardInfoTool ()

@property (strong,nonatomic) APKCommonTaskTool *taskTool;
@property (strong,nonatomic) NSMutableArray *properties;
@property (copy,nonatomic) APKGetDVRSDCardInfoCompletionHandler completionHandler;
@property (strong,nonatomic) APKSDCardInfo *sdCardInfo;

@end

@implementation APKGetDVRSDCardInfoTool


- (APKSDCardInfo *)sdCardInfo{
    
    if (!_sdCardInfo) {
        _sdCardInfo = [[APKSDCardInfo alloc] init];
    }
    return _sdCardInfo;
}

- (APKCommonTaskTool *)taskTool{
    
    if (!_taskTool) {
        _taskTool = [[APKCommonTaskTool alloc] init];
    }
    return _taskTool;
}

- (void)getSDCardInfo{
    
    if (self.properties.count == 0) {
        
        self.completionHandler(YES,self.sdCardInfo);
        return;
    }
    
    NSString *property = self.properties.firstObject;
    __weak typeof(self)weakSelf = self;
    [self.taskTool getDVRWithProperty:property completionHandler:^(BOOL success) {
       
        if (success) {
            
            APKDVRInfo *info = [APKDVR sharedInstance].info;
            NSString *spaceStr = info.spaceInfo;
            NSArray *spaceArr = [spaceStr componentsSeparatedByString:@"#"];
            
            NSString *totalSpaceStr = spaceArr.firstObject;
            self.sdCardInfo.totalSpace = [totalSpaceStr componentsSeparatedByString:@":"][1];
//            self.sdCardInfo.totalSpace = [spaceArr.firstObject floatValue];
            
            NSString *normalvideoInfo = spaceArr[1];
            normalvideoInfo = [normalvideoInfo stringByReplacingOccurrencesOfString:@"N:" withString:@""];
            NSArray *normalVideoArr = [normalvideoInfo componentsSeparatedByString:@"/"];
            self.sdCardInfo.totalVideoSpace = [normalVideoArr.firstObject floatValue] + [normalVideoArr[1]intValue];
            self.sdCardInfo.freeVideoSpace = [normalVideoArr[1] intValue];
            
            NSString *eventVideoInfo = spaceArr[2];
            eventVideoInfo = [eventVideoInfo stringByReplacingOccurrencesOfString:@"E:" withString:@""];
            NSArray *normalEventArr = [eventVideoInfo componentsSeparatedByString:@"/"];
            self.sdCardInfo.totalEventSpace = [normalEventArr.firstObject floatValue] + [normalEventArr[1] intValue];
            self.sdCardInfo.freeEventSpace = [normalEventArr[1] intValue];
            
            NSString *parkingVideoInfo = spaceArr[3];
            parkingVideoInfo = [parkingVideoInfo stringByReplacingOccurrencesOfString:@"P:" withString:@""];
            NSArray *parikingArr = [parkingVideoInfo componentsSeparatedByString:@"/"];
            self.sdCardInfo.parkingEventTotalSpace = [parikingArr.firstObject floatValue] + [parikingArr[1] intValue];
            self.sdCardInfo.parkingEventfreeSpace = [parikingArr[1] intValue];
            
            NSString *parkingTimeVideoInfo = spaceArr[4];
            parkingTimeVideoInfo = [parkingTimeVideoInfo stringByReplacingOccurrencesOfString:@"P:" withString:@""];
            NSArray *parikingTimeArr = [parkingTimeVideoInfo componentsSeparatedByString:@"/"];
            self.sdCardInfo.parkingTimeTotalSpace = [parikingTimeArr.firstObject intValue] + [parikingTimeArr[1]floatValue];
            self.sdCardInfo.parkingTimeFreeSpace = [parikingTimeArr[1] intValue];
            
            NSString *pictureInfo = spaceArr[5];
            pictureInfo = [pictureInfo stringByReplacingOccurrencesOfString:@"P:" withString:@""];
            NSArray *pictureArr = [pictureInfo componentsSeparatedByString:@"/"];
            self.sdCardInfo.totalPhotoSpace = [pictureArr.firstObject floatValue] + [pictureArr[1] floatValue];
            self.sdCardInfo.freePhotoSpace = [pictureArr[1] floatValue];
            
            self.completionHandler(YES,self.sdCardInfo);
            return ;
            
            
            float totalSpace = 0;
            float freeSpace = 0;
            if (info.spaceInfo) {
                
                NSString *str = [info.totalSpace componentsSeparatedByString:@"G"].firstObject;
                totalSpace = [str floatValue];
            }
            if (info.freeSpace) {
                
                NSString *str = [info.freeSpace componentsSeparatedByString:@"G"].firstObject;
                freeSpace = [str floatValue];
            }
            if ([property isEqualToString:@"Camera.Menu.SDTotalSpace"]) {
//                weakSelf.sdCardInfo.totalSpace = totalSpace;
            }else if ([property isEqualToString:@"Camera.Menu.SDPhotoSpace"]) {
                weakSelf.sdCardInfo.totalPhotoSpace = totalSpace;
                weakSelf.sdCardInfo.freePhotoSpace = freeSpace;
            }else if ([property isEqualToString:@"Camera.Menu.SDNormalSpace"]) {
                weakSelf.sdCardInfo.totalVideoSpace = totalSpace;
                weakSelf.sdCardInfo.freeVideoSpace = freeSpace;
            }else if ([property isEqualToString:@"Camera.Menu.SDEventSpace"]) {
                weakSelf.sdCardInfo.totalEventSpace = totalSpace;
                weakSelf.sdCardInfo.freeEventSpace = freeSpace;
            }
            
            [weakSelf.properties removeObject:property];
            weakSelf.taskTool = nil;
            [weakSelf getSDCardInfo];

        }else{
            weakSelf.completionHandler(NO,nil);
        }
    }];
}

- (void)getSDCardInfoWithCompletionHandler:(APKGetDVRSDCardInfoCompletionHandler)completionHandler{
    
//    self.properties = [NSMutableArray arrayWithObjects:@"Camera.Menu.SDTotalSpace",@"Camera.Menu.SDPhotoSpace",@"Camera.Menu.SDNormalSpace",@"Camera.Menu.SDEventSpace", nil];
    self.properties = [NSMutableArray arrayWithObjects:@"Camera.Menu.SDCardStatus", nil];
    self.completionHandler = completionHandler;
    
    [self getSDCardInfo];
}


@end
