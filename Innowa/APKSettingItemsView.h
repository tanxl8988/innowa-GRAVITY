//
//  APKSettingItemsView.h
//  Innowa
//
//  Created by Mac on 17/5/11.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APKSettingItemsView;

@protocol APKSettingItemsViewDelegate <NSObject>

- (NSString *)APKSettingItemsView:(APKSettingItemsView *)settingItemsView titleOfItemAtIndex:(NSInteger)index;
- (NSInteger)numberOfItemsInAPKSettingItemsView:(APKSettingItemsView *)settingItemsView;
- (void)APKSettingItemsView:(APKSettingItemsView *)settingItemsView didSelectItemAtIndex:(NSInteger)index;

@end

@interface APKSettingItemsView : UIView

@property (strong,nonatomic) UIFont *textFont;

+ (instancetype)showInViewController:(UIViewController *)viewController
                            delegate:(id<APKSettingItemsViewDelegate>)delegate
                     anchorViewFrame:(CGRect)anchorViewFrame
                        currentIndex:(NSInteger)currentIndex
                            topLimit:(CGFloat)topLimit
                         bottomLimit:(CGFloat)bottomLimit;
- (void)dismiss;

@end
