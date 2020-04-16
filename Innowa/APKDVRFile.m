//
//  APKCameraFile.m
//  AITDemo
//
//  Created by Mac on 16/9/5.
//  Copyright © 2016年 APK. All rights reserved.
//

#import "APKDVRFile.h"
#import "APKDVR.h"

static NSString *TAG_DCIM = @"DCIM" ;
static NSString *TAG_file = @"file" ;
static NSString *TAG_name = @"name" ;
static NSString *TAG_format = @"format";
static NSString *TAG_size = @"size" ;
static NSString *TAG_attr = @"attr" ;
static NSString *TAG_time = @"time" ;
static NSString *TAG_amount = @"amount";

@implementation APKDVRFile

- (instancetype)initWithElement:(GDataXMLElement *)element{
    
    if (self = [super init]) {
        
        if (element.childCount != 5) return nil;
        
        NSString *originalName = [[self getFirstChild:element WithName:TAG_name] stringValue];
        originalName = [originalName stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        self.originalName =  originalName;
        [self loadFileInfoWithOriginName:self.originalName];
        self.format = [[self getFirstChild:element WithName:TAG_format] stringValue];
        self.attr = [[self getFirstChild:element WithName:TAG_attr] stringValue];

        //size
        int sizeCount = [[[self getFirstChild:element WithName:TAG_size] stringValue] intValue];
        NSString *sizeString = @"0" ;
        if (sizeCount < 1024) {
            sizeString = [NSString stringWithFormat:@"%u", sizeCount] ;
        } else {
            sizeCount /= 1024 ;
            if (sizeCount < 1024) {
                sizeString = [NSString stringWithFormat:@"%uK", sizeCount] ;
            } else {
                sizeCount /= 1024 ;
                sizeString = [NSString stringWithFormat:@"%uM", sizeCount] ;
            }
        }
        self.size = sizeString;
        
        //date
        NSString *timeString = [[self getFirstChild:element WithName:TAG_time] stringValue];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *filedate = [dateFormatter dateFromString:timeString];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        self.time = [dateFormatter stringFromDate:filedate];
        self.date = filedate;
    }
    return self;
}

#pragma mark - private method

- (void)loadFileInfoWithOriginName:(NSString *)originName{// /SD/Normal/FILE170101-012105F.MOV
    
    //file type
    if ([originName containsString:@"Normal"]) {
        self.type = kAPKDVRFileTypeVideo;
    }else if ([originName containsString:@"P_Event"]){
        self.type = kAPKDVRFileTypeParkEvent;
    }else if ([originName containsString:@"Snapshot"]){
        self.type = kAPKDVRFileTypePhoto;
    }else if ([originName containsString:@"P_Timelapse"]){
        self.type = kAPKDVRFileTypeParkTime;
    }else if ([originName containsString:@"Event"]){
        self.type = kAPKDVRFileTypeEvent;
    }
    
//    NSInteger type = [APKDVR sharedInstance].requestDataType;
//    switch (type) {
//        case kAPKDVRFileTypeVideo:
//            self.type = kAPKDVRFileTypeVideo;
//            break;
//        case kAPKDVRFileTypePhoto:
//            self.type = kAPKDVRFileTypePhoto;
//            break;
//        case kAPKDVRFileTypeEvent:
//            self.type = kAPKDVRFileTypeEvent;
//            break;
//        default:
//            break;
//    }
    
//    if ([originName containsString:@"Normal"]) {//new add file type
//        self.type = kAPKDVRFileTypeVideo;
//    }
    
    //file name
    self.name = [originName lastPathComponent];

    //file download path
    NSString *fileDownloadPath = [NSString stringWithFormat:@"http://192.72.1.1%@",originName];
    self.fileDownloadPath = fileDownloadPath;
    
    //thumbnail download path
    NSString *thumbnailSubPath = [originName componentsSeparatedByString:@"SD/"].lastObject;
    NSString *thumbnailDownloadPath = [NSString stringWithFormat:@"http://192.72.1.1/thumb/%@",thumbnailSubPath];
    self.thumbnailDownloadPath = thumbnailDownloadPath;
}

- (GDataXMLElement *)getFirstChild:(GDataXMLElement *)element WithName: (NSString*) name{
    
    NSArray *elements = [element elementsForName:name] ;
    if (elements.count > 0) {
        
        return (GDataXMLElement *) [elements objectAtIndex:0];
    }
    return nil ;
}

@end
