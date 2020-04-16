//
//  JYJAnimateViewController.h
//  JYJSlideMenuController
//
//  Created by JYJ on 2017/6/16.
//  Copyright © 2017年 baobeikeji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APKCustomTabBarController.h"

@interface JYJAnimateViewController : UIViewController
/** rootVc */
@property (nonatomic, strong) UIViewController *rootViewController;

@property (nonatomic,retain) APKCustomTabBarController *tabVC;

/** hideStatusBar */
@property (nonatomic, assign) BOOL hideStatusBar;

- (void)closeAnimation;

@end
