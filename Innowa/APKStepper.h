//
//  APKStepper.h
//  Innowa
//
//  Created by Mac on 17/5/17.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APKStepper : UIView

@property (strong,nonatomic) NSString *value;

//如果是在storyboard中使用的话，configureWithMaxValue方法必须在viewDidAppear中调用
- (void)configureWithMaxValue:(NSInteger)maxValue minValue:(NSInteger)minValue currentValue:(NSInteger)currentValue;

@end
