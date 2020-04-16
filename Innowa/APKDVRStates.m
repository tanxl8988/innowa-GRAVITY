//
//  APKDVRStates.m
//  AITBrain
//
//  Created by Mac on 17/3/21.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKDVRStates.h"
#import "APKDVRTaskId.h"

@implementation APKDVRStates

- (void)updateWithTaskId:(NSInteger)taskId rval:(NSInteger)rval{
    
    APKDVRState state = rval == 0 ? kAPKDVRStateSuccess : kAPKDVRStateFailure;
    
    if (taskId == RECORD_EVENT_ID)
        state = rval == 798 ? kAPKDVRStateSuccess : kAPKDVRStateFailure;
    
    switch (taskId) {
            
        case TAKE_PHOTO_ID:
            self.takePhoto = state;
            break;
        case GET_WIFI_INFO_ID:
            self.getWifiInfo = state;
            break;
        case GET_PHOTO_LIST_ID:
            self.getPhotoList = state;
            break;
        case GET_VIDEO_LIST_ID:
            self.getVideoList = state;
            break;
        case GET_EVENT_LIST_ID:
            self.getEventList = state;
            break;
        case GET_PARK_TIME_LIST:
            self.getParkTimeList = state;
            break;
        case GET_PARK_EVENT_LIST:
            self.getParkEventList = state;
            break;
        case GET_LIVE_INFO_ID:
            self.getLiveInfo = state;
            break;
        case DELETE_FILE_ID:
            self.deleteFile = state;
            break;
        case GET_SETTING_INFO_ID:
            self.getSettingInfo = state;
            break;
        case GET_RECORD_STATE_ID:
            self.getRecordState = state;
            break;
        case MODIFY_WIFI_ID:
            self.modifyWifi = state;
            break;
        case UPDATE_WIFI_ID:
            self.updateWifi = state;
            break;
        case FIND_ME_ID:
            self.findMe = state;
            break;
        case SET_DVR_ID:
            self.setDVR = state;
            break;
        case RECORD_EVENT_ID:
            self.recordEvent = state;
            break;
        case GET_DVR_ID:
            self.getDVR = state;
            break;
        case CHECK_REAR_CAMERA_ID:
            self.checkRearCamera = state;
            break;
        case SET_FONT_CAMERA_ID:
            self.setFontCamera = state;
            break;
        case SET_REAR_CAMERA_ID:
            self.setRearCamera = state;
            break;
        case TOGGLE_RECORED_STATE_ID:
            self.toggleRecordState = state;
            break;
        case GET_CAMERA_INFO:
            self.getCameraInfo = state;
            break;
    }
}

- (BOOL)updateWithTask:(APKDVRTask *)task{
    
    BOOL isUpdateSuccess = YES;
    
    switch (task.taskId) {
            
        case TAKE_PHOTO_ID:
            if (self.takePhoto == kAPKDVRStateExcuting){//excuting正在执行
                isUpdateSuccess = NO;
            }else{
                self.takePhoto = kAPKDVRStateExcuting;
            }
            break;
        case GET_WIFI_INFO_ID:
            if (self.getWifiInfo == kAPKDVRStateExcuting){
                isUpdateSuccess = NO;
            }else{
                self.getWifiInfo = kAPKDVRStateExcuting;
            }
            break;
        case GET_PHOTO_LIST_ID:
            if (self.getPhotoList == kAPKDVRStateExcuting){
                isUpdateSuccess = NO;
            }else{
                self.getPhotoList = kAPKDVRStateExcuting;
            }
            break;
        case GET_VIDEO_LIST_ID:
            if (self.getVideoList == kAPKDVRStateExcuting){
                isUpdateSuccess = NO;
            }else{
                self.getVideoList = kAPKDVRStateExcuting;
            }
            break;
        case GET_EVENT_LIST_ID:
            if (self.getEventList == kAPKDVRStateExcuting){
                isUpdateSuccess = NO;
            }else{
                self.getEventList = kAPKDVRStateExcuting;
            }
            break;
        case GET_LIVE_INFO_ID:
            if (self.getLiveInfo == kAPKDVRStateExcuting){
                isUpdateSuccess = NO;
            }else{
                self.getLiveInfo = kAPKDVRStateExcuting;
            }
            break;
        case DELETE_FILE_ID:
            if (self.deleteFile == kAPKDVRStateExcuting){
                isUpdateSuccess = NO;
            }else{
                self.deleteFile = kAPKDVRStateExcuting;
            }
            break;
        case GET_SETTING_INFO_ID:
            if (self.getSettingInfo == kAPKDVRStateExcuting){
                isUpdateSuccess = NO;
            }else{
                self.getSettingInfo = kAPKDVRStateExcuting;
            }
            break;
        case GET_RECORD_STATE_ID:
            if (self.getRecordState == kAPKDVRStateExcuting){
                isUpdateSuccess = NO;
            }else{
                self.getRecordState = kAPKDVRStateExcuting;
            }
            break;
        case MODIFY_WIFI_ID:
            if (self.modifyWifi == kAPKDVRStateExcuting){
                isUpdateSuccess = NO;
            }else{
                self.modifyWifi = kAPKDVRStateExcuting;
            }
            break;
        case UPDATE_WIFI_ID:
            if (self.updateWifi == kAPKDVRStateExcuting){
                isUpdateSuccess = NO;
            }else{
                self.updateWifi = kAPKDVRStateExcuting;
            }
            break;
        case FIND_ME_ID:
            if (self.findMe == kAPKDVRStateExcuting){
                isUpdateSuccess = NO;
            }else{
                self.findMe = kAPKDVRStateExcuting;
            }
            break;
        case SET_DVR_ID:
            if (self.setDVR == kAPKDVRStateExcuting){
                isUpdateSuccess = NO;
            }else{
                self.setDVR = kAPKDVRStateExcuting;
            }
            break;
        case RECORD_EVENT_ID:
            if (self.recordEvent == kAPKDVRStateExcuting){
                isUpdateSuccess = NO;
            }else{
                self.recordEvent = kAPKDVRStateExcuting;
            }
            break;
        case GET_DVR_ID:
            if (self.getDVR == kAPKDVRStateExcuting){
                isUpdateSuccess = NO;
            }else{
                self.getDVR = kAPKDVRStateExcuting;
            }
            break;
        case CHECK_REAR_CAMERA_ID:
            if (self.checkRearCamera == kAPKDVRStateExcuting){
                isUpdateSuccess = NO;
            }else{
                self.checkRearCamera = kAPKDVRStateExcuting;
            }
            break;
        case SET_REAR_CAMERA_ID:
            if (self.setRearCamera == kAPKDVRStateExcuting){
                isUpdateSuccess = NO;
            }else{
                self.setRearCamera = kAPKDVRStateExcuting;
            }
            break;
        case SET_FONT_CAMERA_ID:
            if (self.setFontCamera == kAPKDVRStateExcuting){
                isUpdateSuccess = NO;
            }else{
                self.setFontCamera = kAPKDVRStateExcuting;
            }
            break;
        case TOGGLE_RECORED_STATE_ID:
            if (self.toggleRecordState == kAPKDVRStateExcuting){
                isUpdateSuccess = NO;
            }else{
                self.toggleRecordState = kAPKDVRStateExcuting;
            }

            break;
    }
    
    return isUpdateSuccess;
}

@end
