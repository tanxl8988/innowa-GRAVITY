//
//  APKSpecialSettingsTool.h
//  Innowa
//
//  Created by Mac on 17/6/7.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^APKSetCompletionHandler)(BOOL success);

@interface APKSpecialSettingsTool : NSObject

- (void)setDVRWithProperty:(NSString *)property value:(NSString *)value completionHanlder:(APKSetCompletionHandler)completionHandler;

@end
