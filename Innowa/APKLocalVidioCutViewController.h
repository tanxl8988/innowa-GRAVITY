//
//  APKLocalVidioCutViewController.h
//  Innowa
//
//  Created by 李福池 on 2018/6/7.
//  Copyright © 2018年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalFile.h"

@interface APKLocalVidioCutViewController : UIViewController
@property (nonatomic,retain) NSString *fileUrl;
@property (nonatomic,retain) LocalFile *localFile;

@end
