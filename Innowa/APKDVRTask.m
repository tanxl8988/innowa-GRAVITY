//
//  APKDVRTask.m
//  AITBrain
//
//  Created by Mac on 17/3/21.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKDVRTask.h"
#import "APKDVRTaskId.h"

@implementation APKDVRTask

+ (instancetype)toggleRecordStateTask{
    
    APKDVRTask *task = [[APKDVRTask alloc] init];
    task.taskId = TOGGLE_RECORED_STATE_ID;
    NSString *msg = @"http://192.72.1.1/cgi-bin/Config.cgi?action=set&property=Video&value=record";
    task.url = msg;
    return task;
}

+ (instancetype)setRearCameraTask{
    
    APKDVRTask *task = [[APKDVRTask alloc] init];
    task.taskId = SET_REAR_CAMERA_ID;
    NSString *msg = @"http://192.72.1.1/cgi-bin/Config.cgi?action=setcamid&property=Camera.Preview.Source.1.Camid&value=rear";
    task.url = msg;
    return task;
}

+ (instancetype)setFontCameraTask{
    
    APKDVRTask *task = [[APKDVRTask alloc] init];
    task.taskId = SET_FONT_CAMERA_ID;
    NSString *msg = @"http://192.72.1.1/cgi-bin/Config.cgi?action=setcamid&property=Camera.Preview.Source.1.Camid&value=front";
    task.url = msg;
    return task;
}

+ (instancetype)checkRearCameraTask{
    
    APKDVRTask *task = [[APKDVRTask alloc] init];
    task.taskId = CHECK_REAR_CAMERA_ID;
    NSString *msg = @"http://192.72.1.1/cgi-bin/Config.cgi?action=get&property=Camera.Menu.RearCamType";
    task.url = msg;
    return task;
}

+ (instancetype)findMeTask{
    
    NSString *msg = @"http://192.72.1.1/cgi-bin/Config.cgi?action=set&property=Net&value=findme";
    APKDVRTask *task = [[APKDVRTask alloc] init];
    task.taskId = FIND_ME_ID;
    task.url = msg;
    return task;
}

+ (instancetype)updateWifiTask{
    
    APKDVRTask *task = [[APKDVRTask alloc] init];
    task.taskId = UPDATE_WIFI_ID;
    NSString *msg = @"http://192.72.1.1/cgi-bin/Config.cgi?action=set&property=Net&value=reset";
    task.url = msg;
    return task;
}

+ (instancetype)modifyWifiTaskWithSSID:(NSString *)ssid encryptionKey:(NSString *)encryptionKey{
    
    APKDVRTask *task = [[APKDVRTask alloc] init];
    task.taskId = MODIFY_WIFI_ID;
    NSString *msg = [NSString stringWithFormat:@"http://192.72.1.1/cgi-bin/Config.cgi?action=set&property=Net.WIFI_AP.SSID&value=%@&property=Net.WIFI_AP.CryptoKey&value=%@",ssid,encryptionKey];
    task.url = msg;
    return task;
}

+ (instancetype)getRecordStateTask{
    
    APKDVRTask *task = [[APKDVRTask alloc] init];
    task.taskId = GET_RECORD_STATE_ID;
    NSString *msg = @"http://192.72.1.1/cgi-bin/Config.cgi?action=get&property=Camera.Preview.MJPEG.status.record";
    task.url = msg;
    
    task.taskId = CHECK_REAR_CAMERA_ID;
    msg = @"http://192.72.1.1/cgi-bin/Config.cgi?action=get&property=Camera.Menu.RearCamType";
    task.url = msg;
    
    return task;
}

+ (instancetype)getSettingInfoTask{
    
    APKDVRTask *task = [[APKDVRTask alloc] init];
    task.taskId = GET_SETTING_INFO_ID;
    NSString *msg = @"http://192.72.1.1/cgi-bin/Config.cgi?action=get&property=Camera.Menu.";
    task.url = msg;
    
    return task;
}

+ (instancetype)deleteFileTaskWithFileName:(NSString *)fileName{
    
    APKDVRTask *task = [[APKDVRTask alloc] init];
    task.taskId = DELETE_FILE_ID;
    NSString *msg = [NSString stringWithFormat:@"http://192.72.1.1/cgi-bin/Config.cgi?action=del&property=%@",fileName];
    task.url = msg;
    return task;
}

+ (instancetype)getLiveInfoTask{
    
    APKDVRTask *task = [[APKDVRTask alloc] init];
    task.taskId = GET_LIVE_INFO_ID;
    NSString *msg = @"http://192.72.1.1/cgi-bin/Config.cgi?action=get&property=Camera.Preview.*";
    task.url = msg;
    return task;
}

+ (instancetype)getPhotoListTaskWithCount:(NSInteger)count fromIndex:(NSInteger)index isRearCameraFile:(BOOL)isRearCameraFile{
    
    APKDVRTask *task = [[APKDVRTask alloc] init];
    task.taskId = GET_PHOTO_LIST_ID;
    NSString *action = isRearCameraFile ? @"reardir" : @"dir";
    NSString *msg = [NSString stringWithFormat:@"http://192.72.1.1/cgi-bin/Config.cgi?action=%@&property=Snapshot&format=all&count=%d&from=%d",action,(int)count,(int)index];
    task.url = msg;
    return task;
}

+ (instancetype)getEventListTaskWithCount:(NSInteger)count fromIndex:(NSInteger)index isRearCameraFile:(BOOL)isRearCameraFile{
    
    APKDVRTask *task = [[APKDVRTask alloc] init];
    task.taskId = GET_EVENT_LIST_ID;
    NSString *action = isRearCameraFile ? @"reardir" : @"dir";
    NSString *msg = [NSString stringWithFormat:@"http://192.72.1.1/cgi-bin/Config.cgi?action=%@&property=Event&format=all&count=%d&from=%d",action,(int)count,(int)index];

    task.url = msg;
    return task;
}

+ (instancetype)getParkTimeListTaskWithCount:(NSInteger)count fromIndex:(NSInteger)index isRearCameraFile:(BOOL)isRearCameraFile{
    
    APKDVRTask *task = [[APKDVRTask alloc] init];
    task.taskId = GET_PARK_TIME_LIST;
    NSString *action = isRearCameraFile ? @"reardir" : @"dir";
    NSString *msg = [NSString stringWithFormat:@"http://192.72.1.1/cgi-bin/Config.cgi?action=%@&property=P_Timelapse&format=all&count=%d&from=%d",action,(int)count,(int)index];
    
    task.url = msg;
    return task;
}

+ (instancetype)getParkEventListTaskWithCount:(NSInteger)count fromIndex:(NSInteger)index isRearCameraFile:(BOOL)isRearCameraFile{
    
    APKDVRTask *task = [[APKDVRTask alloc] init];
    task.taskId = GET_PARK_EVENT_LIST;
    NSString *action = isRearCameraFile ? @"reardir" : @"dir";
    NSString *msg = [NSString stringWithFormat:@"http://192.72.1.1/cgi-bin/Config.cgi?action=%@&property=P_Event&format=all&count=%d&from=%d",action,(int)count,(int)index];
    
    task.url = msg;
    return task;
}

+ (instancetype)getVideoListTaskWithCount:(NSInteger)count fromIndex:(NSInteger)index isRearCameraFile:(BOOL)isRearCameraFile{
    
    APKDVRTask *task = [[APKDVRTask alloc] init];
    task.taskId = GET_VIDEO_LIST_ID;
    NSString *action = isRearCameraFile ? @"reardir" : @"dir";
    NSString *msg = [NSString stringWithFormat:@"http://192.72.1.1/cgi-bin/Config.cgi?action=%@&property=Normal&format=all&count=%d&from=%d",action,(int)count,(int)index];
    task.url = msg;
    return task;
}

+ (instancetype)takePhotoTask{
    
    APKDVRTask *task = [[APKDVRTask alloc] init];
    task.taskId = TAKE_PHOTO_ID;
    NSString *msg = @"http://192.72.1.1/cgi-bin/Config.cgi?action=set&property=Video&value=capture";
    task.url = msg;
    return task;
}

+ (instancetype)recordEventTask{
    
    APKDVRTask *task = [[APKDVRTask alloc] init];
    task.taskId = RECORD_EVENT_ID;
    NSString *msg = @"http://192.72.1.1/cgi-bin/Config.cgi?action=set&property=Video&value=rec_emer";
    task.url = msg;
    return task;
}

+ (instancetype)getLoginTokenTask{
    
    APKDVRTask *task = [[APKDVRTask alloc] init];
    task.taskId = GET_LOGIN_TOKEN;
    NSString *msg = @"https://drive.innowa.jp/user/api_get_token";
    task.url = msg;
    return task;
    
}

+ (instancetype)getWifiInfoTask{
    
    APKDVRTask *task = [[APKDVRTask alloc] init];
    task.taskId = GET_WIFI_INFO_ID;
    NSString *msg = @"http://192.72.1.1/cgi-bin/Config.cgi?action=get&property=Net.WIFI_AP.SSID&property=Net.WIFI_AP.CryptoKey";
    task.url = msg;
    return task;
}

+ (instancetype)getCameraInfoTask{
    
    APKDVRTask *task = [[APKDVRTask alloc] init];
    task.taskId = GET_CAMERA_INFO;
    NSString *msg = @"http://192.72.1.1/cgi-bin/Config.cgi?action=get&property=Camera.Preview.Source.1.Camid";
    task.url = msg;
    return task;
}


#pragma mark - settings

+ (instancetype)setDVRTaskWithProperty:(NSString *)property value:(NSString *)value{
    
    NSString *url = [NSString stringWithFormat:@"http://192.72.1.1/cgi-bin/Config.cgi?action=set&property=%@&value=%@",property,value];
    APKDVRTask *task = [[APKDVRTask alloc] init];
    task.taskId = SET_DVR_ID;
    task.url = url;
    return task;
}

#pragma mark - getter

+ (instancetype)getDVRTaskWithProperty:(NSString *)property{
    
    NSString *msg = [NSString stringWithFormat:@"http://192.72.1.1/cgi-bin/Config.cgi?action=get&property=%@",property];
    APKDVRTask *task = [[APKDVRTask alloc] init];
    task.taskId = GET_DVR_ID;
    task.url = msg;
    return task;
}


@end
