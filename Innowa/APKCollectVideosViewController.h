//
//  APKCollectVideosViewController.h
//  Innowa
//
//  Created by Mac on 17/4/27.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKBaseViewController.h"
#import "APKRefreshLocalFilesTool.h"

@interface APKCollectVideosViewController : APKBaseViewController

@property (nonatomic) BOOL selectMode;
@property (nonatomic) BOOL checkAll;
@property (assign) BOOL haveRefreshLocalFiles;
@property (copy,nonatomic) void (^selectModeHandler)(void);
@property (nonatomic,retain) UIButton *selectButton;
@end
