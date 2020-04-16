//
//  APKDVR.h
//  AITBrain
//
//  Created by Mac on 17/3/20.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APKDVRTask.h"
#import "APKDVRStates.h"
#import "APKDVRInfo.h"
@interface APKDVR : NSObject

@property (assign) BOOL isConnected;
@property (strong,nonatomic) APKDVRStates *states;
@property (strong,nonatomic) APKDVRInfo *info;
@property (nonatomic,assign) NSInteger requestDataType;//new add request files list data type

+ (instancetype)sharedInstance;
- (void)performTask:(APKDVRTask *)task;

@end

