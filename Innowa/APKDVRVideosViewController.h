//
//  APKDVRVideosViewController.h
//  Innowa
//
//  Created by Mac on 17/4/26.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKBaseViewController.h"
#import "APKRefreshLocalFilesTool.h"
#import "APKDVRFile.h"
typedef enum
{
    APKRecentType,
    APkGroupType,
    APkAllType,
    APkCustomType
}selectType;

@interface APKDVRVideosViewController : APKBaseViewController

@property (assign) APKDVRFileType fileType;
@property (assign) BOOL isRearCameraFile;
@property (strong,nonatomic) NSString *albumTitle;
@property (nonatomic,assign) selectType selectType;

@end
