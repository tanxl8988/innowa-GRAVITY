//
//  APKLocalVideosViewController.h
//  Innowa
//
//  Created by Mac on 17/4/27.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKBaseViewController.h"
#import "APKRefreshLocalFilesTool.h"
#import "APKDVRFile.h"

@interface APKLocalVideosViewController : APKBaseViewController

@property (assign) APKDVRFileType fileType;
@property (assign) BOOL isRearCameraFile;
@property (strong,nonatomic) NSString *albumTitle;

@end
