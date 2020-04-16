//
//  APKDVRInfo.m
//  AITBrain
//
//  Created by Mac on 17/3/21.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKDVRInfo.h"
#import "APKDVRTaskId.h"
#import "GDataXMLNode.h"
#import "APKDVRFile.h"

static NSString *DEFAULT_RTSP_URL_AV1   = @"/liveRTSP/av1" ;
static NSString *DEFAULT_RTSP_URL_V1    = @"/liveRTSP/v1" ;
static NSString *DEFAULT_RTSP_URL_AV2    = @"/liveRTSP/av2" ;
static NSString *DEFAULT_RTSP_URL_AV4    = @"/liveRTSP/av4" ;
static NSString *DEFAULT_MJPEG_PUSH_URL = @"/cgi-bin/liveMJPEG" ;

@implementation APKDVRInfo

- (void)updateSettingInfoWithData:(NSData *)data{
    
#warning 有问题啊。。。
    
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *lines;
    NSCharacterSet *sep = [NSCharacterSet characterSetWithCharactersInString:@"."];
    lines = [msg componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        NSArray *properties = [line componentsSeparatedByString:@"="];
        if ([properties count] != 2)
            continue;
        NSRange rng = [[properties objectAtIndex:0] rangeOfCharacterFromSet:sep options:NSBackwardsSearch];
        if (rng.location == 0 || rng.length >= [[properties objectAtIndex:0] length])
            continue;
        rng.location++;
        rng.length = [[properties objectAtIndex:0] length] - rng.location;
        NSString *key = [[properties objectAtIndex:0] substringWithRange:rng];
        if ([properties count] != 2)
            continue;
        NSString* sz = [NSString alloc];
        sz = [properties objectAtIndex:1];
        
        if ([key caseInsensitiveCompare:@"VideoRes"] == NSOrderedSame){//录制时长
            
            NSArray *map = @[@"1080P27D5",@"720P27D5"];
            self.videoRes = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"VideoResR"] == NSOrderedSame){
            
            NSArray *map = @[@"1080P27D5"];
            self.videoResR = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"NormalRecordFileSave"] == NSOrderedSame){
            
            NSArray *map = @[@"All_Loop_Recording",@"Loop_Recording_Except_Event",@"No_Loop_Recording"];
            self.normalFileSave = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"ParkRecordFileSave"] == NSOrderedSame){
            
            NSArray *map = @[@"All_Loop_Recording",@"TLapse_Loop_Recording"];
            self.parkingFileSave = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"DefaultScreenDisplay"] == NSOrderedSame){
            
            NSArray *map = @[@"F_Main_R_PIP",@"R_Main_F_PIP",@"F_Only",@"R_Only"];
            self.defaultScreenDisplay = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"AutoHideButtonMenu"] == NSOrderedSame){
            
            NSArray *map = @[@"OFF",@"ON"];
            self.hideMenuBarAutomatically = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"RearCameraDisplay"] == NSOrderedSame){
            
            NSArray *map = @[@"Normal",@"Up_Side_Down",@"Mirrored"];
            self.rearCameraVideo = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"SDCardStatus"] == NSOrderedSame){
            
            self.spaceInfo = sz;
            
        }else if ([key caseInsensitiveCompare:@"MuteStatus"] == NSOrderedSame){
            
            NSArray *map = @[@"OFF",@"ON"];
            self.recordSound = [self getMenuId:sz MenuMap:map];

        }else if ([key caseInsensitiveCompare:@"LCDPower"] == NSOrderedSame){
            
            NSArray *map = @[@"ON",@"7SEC",@"1MIN",@"3MIN"];
            self.LCDPower = [self getMenuId:sz MenuMap:map];
           
        }else if ([key caseInsensitiveCompare:@"VideoClipTime"] == NSOrderedSame){
            
            NSArray *map = @[@"30SEC",@"1MIN"];
            self.VideoClipTime = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"EV"] == NSOrderedSame){
            
            NSArray *map = [NSArray arrayWithObjects:@"EVN200", @"EVN167", @"EVN133", @"EVN100", @"EVN067", @"EVN033", @"EV0", @"EVP033", @"EVP067", @"EVP100", @"EVP133", @"EVP167", @"EVP200", nil];
//            NSArray *map = [NSArray arrayWithObjects:@"EVN200", @"EVN100", @"EV0",  @"EVP100", @"EVP200", nil];
            self.EV = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"Flicker"] == NSOrderedSame){
            
            NSArray *map = @[@"50Hz",@"60Hz"];
            self.Flicker = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"ParkMode"] == NSOrderedSame){
            
            NSArray *map = @[@"OFF",@"GSR",@"MDT",@"GSR_MDT"];
            self.ParkMode = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"GSensor"] == NSOrderedSame){
            
            NSArray *map = @[@"LEVEL2",@"LEVEL3",@"LEVEL4",@"OFF"];
            self.GSensor = [self getMenuId:sz MenuMap:map];
            NSString *GSensorStr = sz;
            if (![GSensorStr containsString:@"#"]){
                if ([GSensorStr isEqualToString:@"LEVEL2"])
                    self.GSensorStr = @"1.0;1.0;1.0";
                else if ([GSensorStr isEqualToString:@"LEVEL3"])
                    self.GSensorStr = @"1.5;1.5;1.5";
                else
                    self.GSensorStr = @"2.5;2.5;2.5";
                
            }else
            {
                NSArray *GsensorArr = [GSensorStr componentsSeparatedByString:@"#"];
                int GSensor1 = [GsensorArr.firstObject intValue];
                int GSensor2 = [GsensorArr[1] intValue];
                int GSensor3 = [GsensorArr[2] intValue];
                self.GSensorStr = [NSString stringWithFormat:@"%.1f;%.1f;%.1f",GSensor1*0.1 + 0.5,GSensor2*0.1 + 0.5,GSensor3*0.1 + 0.5];
            }
            
        }else if ([key caseInsensitiveCompare:@"TimeStamp"] == NSOrderedSame){
            
            NSArray *map = @[@"OFF",@"ON"];
            self.TimeStamp = [self getMenuId:sz MenuMap:map];
            NSLog(@"");
        }else if ([key caseInsensitiveCompare:@"SoundIndicator"] == NSOrderedSame){
            
            NSArray *map = @[@"OFF",@"ON"];
            self.SoundIndicator = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"Volume"] == NSOrderedSame){
            
            NSArray *map = @[@"LV0",@"LV1",@"LV2",@"LV3",@"LV4",@"LV5",@"LV6",@"LV7",@"LV8",@"LV9",@"LV10"];
            self.Volume = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"Language"] == NSOrderedSame){
            
            
            NSArray *map = @[@"English",@"TChinese",@"Japanese"];
            self.Language = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"TimeZone"] == NSOrderedSame){
            
            NSArray *map = @[@"M12",@"M11",@"M10",@"M9",@"M8",@"M7",@"M6",@"M5",@"M4",@"M330",@"M3",@"M2",@"M1",@"GMT",@"P1",@"P2",@"P3",@"P330",@"P4",@"P430",@"P5",@"P530",@"P545",@"P6",@"P630",@"P7",@"P8",@"P9",@"P930",@"P10",@"P11",@"P12",@"P13"];
            self.TimeZone = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"SatelliteSync"] == NSOrderedSame){
            
            NSArray *map = @[@"OFF",@"ON"];
            self.SatelliteSync = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"SpeedUnit"] == NSOrderedSame){
            
            NSArray *map = @[@"KMH",@"MPH"];
            self.SpeedUnit = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"SpeedLimitAlert"] == NSOrderedSame){
            
            NSArray *map = @[@"OFF",@"50KMH",@"60KMH",@"70KMH",@"80KMH",@"90KMH",@"100KMH",@"110KMH",@"120KMH",@"130KMH",@"140KMH",@"150KMH",@"160KMH",@"170KMH",@"180KMH",@"190KMH",@"200KMH"];
            self.SpeedLimitAlert = [self getMenuId:sz MenuMap:map];
            
        }else if ([key caseInsensitiveCompare:@"FWversion"] == NSOrderedSame){
            
            self.FWversion = sz;
        }else if ([key caseInsensitiveCompare:@"KeyTone"] == NSOrderedSame){
            
            NSArray *map = @[@"OFF",@"ON"];
            self.SoundIndicator = [self getMenuId:sz MenuMap:map];
        }else if ([key caseInsensitiveCompare:@"ParkingModeTime"] == NSOrderedSame){
            
            NSArray *map = @[@"ON",@"0HOUR",@"30MIN",@"1HOUR",@"6HOUR",@"12HOUR"];
            self.parkingModeTime = [self getMenuId:sz MenuMap:map];
        }else if ([key caseInsensitiveCompare:@"MTD"] == NSOrderedSame){
            
            NSArray *map = @[@"LOW",@"MIDDLE",@"HIGH"];
            self.MTD = [self getMenuId:sz MenuMap:map];
        }
    }
    
    self.haveLoadSettingInfo = YES;
}

- (NSArray *)getFileListWithData:(NSData *)data{
    
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithXMLString:[result substringToIndex:[result rangeOfString:@">" options:NSBackwardsSearch].location + 1] options:0 error:nil];
    GDataXMLElement *dcimElement = doc.rootElement ;
    NSArray *dcimChildren = [dcimElement children] ;
    
    NSMutableArray *fileArray = [[NSMutableArray alloc] init];
    for (GDataXMLElement *dcimChild in dcimChildren) {
        
        APKDVRFile *file = [[APKDVRFile alloc] initWithElement:dcimChild];
        if (file){
            [fileArray addObject:file];
        }
    }
    return fileArray;
}

- (void)updateWifiInfoWithData:(NSData *)data{
    
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *arr = [str componentsSeparatedByString:@"\n"];
    for (NSString *element in arr) {
        
        if ([element containsString:@"SSID"]) {
            
            NSArray *infoArr = [element componentsSeparatedByString:@"="];
            self.ssid = infoArr.lastObject;
            
        }else if ([element containsString:@"CryptoKey"]){
            
            NSArray *infoArr = [element componentsSeparatedByString:@"="];
            self.encryptionKey = infoArr.lastObject;
        }
    }
}

- (void)updateLiveUrlWithData:(NSData *)data{
    
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    int             rtsp;
    NSDictionary    *dict;
    dict = [self buildResultDictionary:result];
    if (dict == nil) return;
    rtsp        = [[dict objectForKey:@"Camera.Preview.RTSP.av"] intValue];

    NSString *liveUrlString = nil;
    if (rtsp == 1) {
        liveUrlString = [NSString stringWithFormat:@"rtsp://192.72.1.1%@", DEFAULT_RTSP_URL_AV1];
    }else if (rtsp == 2) {
        liveUrlString = [NSString stringWithFormat:@"rtsp://192.72.1.1%@", DEFAULT_RTSP_URL_V1];
    }else if (rtsp == 3) {
        liveUrlString = [NSString stringWithFormat:@"rtsp://192.72.1.1%@", DEFAULT_RTSP_URL_AV2];
    }else if (rtsp == 4) {
        liveUrlString = [NSString stringWithFormat:@"rtsp://192.72.1.1%@", DEFAULT_RTSP_URL_AV4];
    }else {
        liveUrlString = [NSString stringWithFormat:@"http://192.72.1.1%@", DEFAULT_MJPEG_PUSH_URL];
    }
    self.liveUrl = [NSURL URLWithString:liveUrlString];
    
    float width = [[dict objectForKey:@"Camera.Preview.H264.w"] floatValue];
    float height = [[dict objectForKey:@"Camera.Preview.H264.h"] floatValue];
    self.liveWHRatio = width / height;
}

- (void)updateRecordStateWithData:(NSData *)data{
    
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *arr = [str componentsSeparatedByString:@"\n"];
    for (NSString *element in arr) {
        
        if ([element containsString:@"Camera.Preview.MJPEG.status.record"]) {
            
            NSArray *infoArr = [element componentsSeparatedByString:@"="];
            NSString *recordInfo = infoArr.lastObject;
            self.isRecording = [recordInfo isEqualToString:@"Recording"] ? YES : NO;
        }
    }
}

- (void)loadGetDVRResult:(NSData *)data{
    
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *arr = [str componentsSeparatedByString:@"\n"];
    for (NSString *element in arr) {
        
        if ([element containsString:@"Camera.Menu.SDPhotoSpace"] || [element containsString:@"Camera.Menu.SDNormalSpace"] || [element containsString:@"Camera.Menu.SDEventSpace"]) {
            
            NSString *spaceInfoStr = [element componentsSeparatedByString:@"="].lastObject;
            NSArray *spaceInfo = [spaceInfoStr componentsSeparatedByString:@"#"];
            self.freeSpace = spaceInfo.firstObject;
            self.totalSpace = spaceInfo.lastObject;
            
        }else if ([element containsString:@"Camera.Menu.SDTotalSpace"]) {
            
            NSString *spaceInfoStr = [element componentsSeparatedByString:@"="].lastObject;
            self.totalSpace = spaceInfoStr;
        }else if([element containsString:@"Camera.Menu.ParkingStatus"]){
            
            NSString *spaceInfoStr = [element componentsSeparatedByString:@"="].lastObject;
            self.parkingModeInfo = spaceInfoStr;
        }
    }
}

- (void)loadRearCameraType:(NSData *)data{

    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *arr = [str componentsSeparatedByString:@"\n"];
    for (NSString *element in arr) {
        
        if ([element containsString:@"Camera.Menu.RearCamType"]) {
            
            NSString *rearCameraType = [element componentsSeparatedByString:@"="].lastObject;
            self.haveRearCamera = [rearCameraType isEqualToString:@"NONE"] ? NO : YES;
        }
    }
}

#pragma mark - public method

- (void)updateWithTaskId:(NSInteger)taskId data:(NSData *)data{
    
    switch (taskId) {
        case GET_WIFI_INFO_ID:
            
            [self updateWifiInfoWithData:data];
            break;
            
        case GET_SETTING_INFO_ID:
            
            [self updateSettingInfoWithData:data];
            break;
            
        case GET_PHOTO_LIST_ID:
            
            self.photos = [self getFileListWithData:data];
            break;
            
        case GET_VIDEO_LIST_ID:
            
            self.videos = [self getFileListWithData:data];
            break;
            
        case GET_EVENT_LIST_ID:
            
            self.events = [self getFileListWithData:data];
            break;
        case GET_PARK_TIME_LIST:
            
            self.parkTime = [self getFileListWithData:data];
            break;
        case GET_PARK_EVENT_LIST:
            
            self.parkEvent = [self getFileListWithData:data];
            break;
        case GET_LIVE_INFO_ID:
            
            [self updateLiveUrlWithData:data];
            break;
        case GET_RECORD_STATE_ID:
            
            [self updateRecordStateWithData:data];
            break;
        case GET_DVR_ID:
            
            [self loadGetDVRResult:data];
            break;
        case CHECK_REAR_CAMERA_ID:
            
            [self loadRearCameraType:data];
            break;
        case TOGGLE_RECORED_STATE_ID:
            self.isRecording = !self.isRecording;
            break;
        case GET_CAMERA_INFO:
        {
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            self.isFrontCamera = [str containsString:@"rear"] == YES ? NO : YES;
            break;
        }
        default:
            break;
    }
}

#pragma mark - utilities

- (NSInteger)getMenuId:(NSString *)val MenuMap:(NSArray*)map{
    
    NSInteger     i;
    for (i = 0; i < [map count]; i++) {
        if ([val compare:map[i]] == NSOrderedSame)
            return i;
    }
    return 0;
}

- (NSDictionary*) buildResultDictionary:(NSString*)result{
    
    NSMutableArray *keyArray;
    NSMutableArray *valArray;
    NSArray *lines;
    
    keyArray = [[NSMutableArray alloc] init];
    valArray = [[NSMutableArray alloc] init];
    lines = [result componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        NSArray *state = [line componentsSeparatedByString:@"="];
        if ([state count] != 2)
            continue;
        [keyArray addObject:[[state objectAtIndex:0] copy]];
        [valArray addObject:[[state objectAtIndex:1] copy]];
    }
    if ([keyArray count] == 0)
        return nil;
    return [NSDictionary dictionaryWithObjects:valArray forKeys:keyArray];
}

@end
