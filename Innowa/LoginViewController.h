//
//  LoginViewController.h
//  Innowa
//
//  Created by Mac on 18/4/8.
//  Copyright © 2018年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^commonTaskCompleteHandler)(NSDictionary *info);
@interface LoginViewController : UIViewController
@property (nonatomic,copy) commonTaskCompleteHandler commonTaskCompleteHandler;
-(void)executeRequestWithUrl:(NSString *)url commonTaskCompleteHandler:(commonTaskCompleteHandler)completeHandler;
@end
