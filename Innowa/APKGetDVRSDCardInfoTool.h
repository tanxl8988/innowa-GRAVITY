//
//  APKGetDVRSDCardInfoTool.h
//  Innowa
//
//  Created by Mac on 17/5/24.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APKSDCardInfo : NSObject

@property (nonatomic,retain) NSString *totalSpace;
@property (assign) float totalPhotoSpace;
@property (assign) float freePhotoSpace;
@property (assign) float totalVideoSpace;
@property (assign) float freeVideoSpace;
@property (assign) float totalEventSpace;
@property (assign) float freeEventSpace;
@property (assign) float parkingEventTotalSpace;
@property (assign) float parkingEventfreeSpace;
@property (assign) float parkingTimeTotalSpace;
@property (assign) float parkingTimeFreeSpace;


@end

typedef void(^APKGetDVRSDCardInfoCompletionHandler)(BOOL success,APKSDCardInfo *sdCardInfo);

@interface APKGetDVRSDCardInfoTool : NSObject

- (void)getSDCardInfoWithCompletionHandler:(APKGetDVRSDCardInfoCompletionHandler)completionHandler;

@end
