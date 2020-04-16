//
//  APKGetDVRConnectionInfo.h
//  Innowa
//
//  Created by Mac on 17/7/5.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^APKGetDVRConnectionInfoCompleteHandler)(BOOL success);


@interface APKGetDVRConnectionInfo : NSObject

- (void)execute:(APKGetDVRConnectionInfoCompleteHandler)completionHandler;

@end
