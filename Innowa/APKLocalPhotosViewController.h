//
//  APKLocalPhotosViewController.h
//  Innowa
//
//  Created by Mac on 17/4/27.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKBaseViewController.h"
#import "APKRefreshLocalFilesTool.h"

@interface APKLocalPhotosViewController : APKBaseViewController

@property (assign) BOOL isRearCameraFile;
@property (strong,nonatomic) NSString *albumTitle;

@end
