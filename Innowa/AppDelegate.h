//
//  AppDelegate.h
//  Innowa
//
//  Created by Mac on 17/3/28.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,assign) BOOL allowRotation;


@end

