//
//  APKAlertTool.h
//  Innowa
//
//  Created by Mac on 17/5/2.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface APKAlertTool : NSObject

+ (void)showAlertInViewController:(UIViewController *)viewController message:(NSString *)message;
+ (UIAlertController *)showAlertInViewController:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message handler:(void (^)(UIAlertAction *action))handler;
+ (void)showAlertInViewController:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message cancelHandler:(void (^)(UIAlertAction *action))cancelHandler;

@end
