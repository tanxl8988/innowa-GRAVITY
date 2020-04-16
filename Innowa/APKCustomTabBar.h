//
//  APKCustomTabBar.h
//  Innowa
//
//  Created by Mac on 17/3/28.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^APKCustomTabBarUpdateIndexBlock)(NSInteger index);

@interface APKCustomTabBar : UIView

@property (copy,nonatomic) APKCustomTabBarUpdateIndexBlock updateIndexBlock;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *middleButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *middleLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;

- (void)selectButtonWithIndex:(NSInteger)index;

@end
