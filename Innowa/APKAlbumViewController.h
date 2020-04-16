//
//  APKAlbumViewController.h
//  Innowa
//
//  Created by Mac on 17/3/28.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKBaseViewController.h"

@interface APKAlbumInfo : NSObject

@property (strong,nonatomic) NSString *info;
@property (strong,nonatomic) NSString *albumTitle;
@property (strong,nonatomic) NSString *coverImageName;
@property (assign) NSInteger fileType;
@property (assign) BOOL isRearCamera;
@property (strong,nonatomic) NSString *segueIdentifier;

@end

@interface APKAlbumViewController : APKBaseViewController

@end
