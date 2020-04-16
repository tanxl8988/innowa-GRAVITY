//
//  APKDVRTimeSelectView.h
//  Innowa
//
//  Created by 李福池 on 2018/6/26.
//  Copyright © 2018年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APKDVRTimeSelectView : UIView
@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerOne;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerTwo;
@property (nonatomic,copy) void(^confirmTimeBlock)(NSDate *beginDate,NSDate *endDate);
@property (nonatomic,retain) NSDate *beginDate;
@property (nonatomic,retain) NSDate *endDate;
@property (nonatomic) NSDateFormatter *formatter;
@property (weak, nonatomic) IBOutlet UILabel *beginTimeL;
@property (weak, nonatomic) IBOutlet UILabel *endTimeL;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end
