//
//  APKFunctionTool.h
//  Innowa
//
//  Created by 李福池 on 2018/8/10.
//  Copyright © 2018年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APKFunctionTool : NSObject

+(void)combineAppVersion:(void (^)(BOOL isSameVersion))combineVersionBlock;

@end
