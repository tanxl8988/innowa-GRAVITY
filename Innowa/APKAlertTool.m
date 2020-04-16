//
//  APKAlertTool.m
//  Innowa
//
//  Created by Mac on 17/5/2.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKAlertTool.h"

@implementation APKAlertTool

+ (void)showAlertInViewController:(UIViewController *)viewController message:(NSString *)message{
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:cancel];
    [viewController presentViewController:alert animated:YES completion:^{
        
    }];
}

+ (UIAlertController *)showAlertInViewController:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message handler:(void (^)(UIAlertAction *action))handler{
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:handler];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:cancel];
    [alert addAction:confirm];
    [viewController presentViewController:alert animated:YES completion:^{
        
    }];
    
    return alert;
}

+ (void)showAlertInViewController:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message cancelHandler:(void (^)(UIAlertAction *))cancelHandler{
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleCancel handler:cancelHandler];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:cancel];
    [viewController presentViewController:alert animated:YES completion:^{
        
    }];
}


@end
