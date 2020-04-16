//
//  APKCameraFile.h
//  AITDemo
//
//  Created by Mac on 16/9/5.
//  Copyright © 2016年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"

typedef enum : NSUInteger {
    kAPKDVRFileTypePhoto = 0,
    kAPKDVRFileTypeVideo,
    kAPKDVRFileTypeEvent,
    kAPKDVRFileTypeParkTime,
    kAPKDVRFileTypeParkEvent,
    kAPKDVRFileTypeVidioEdit
} APKDVRFileType;

@interface APKDVRFile : NSObject

@property (nonatomic) APKDVRFileType type;
@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSString *originalName;
@property (strong,nonatomic) NSString *format;
@property (strong,nonatomic) NSString *size;
@property (strong,nonatomic) NSString *attr;
@property (strong,nonatomic) NSString *time;
@property (strong,nonatomic) NSDate *date;
@property (strong,nonatomic) NSString *thumbnailDownloadPath;
@property (strong,nonatomic) NSString *fileDownloadPath;
@property (strong,nonatomic) NSString *thumbnailPath;
@property (strong,nonatomic) NSString *previewPath;
@property (nonatomic) BOOL isDownloaded;
@property (nonatomic) BOOL isRearCameraFile;

- (instancetype)initWithElement:(GDataXMLElement *)element;

@end
