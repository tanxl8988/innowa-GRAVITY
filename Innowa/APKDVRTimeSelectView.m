//
//  APKDVRTimeSelectView.m
//  Innowa
//
//  Created by 李福池 on 2018/6/26.
//  Copyright © 2018年 APK. All rights reserved.
//

#import "APKDVRTimeSelectView.h"

@implementation APKDVRTimeSelectView

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.datePickerOne addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    [self.datePickerTwo addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    
    NSDate *date = [NSDate date];
    
    self.beginTimeL.text = NSLocalizedString(@"開始時間", nil);
    self.endTimeL.text = NSLocalizedString(@"結束時間", nil);
    [self.sureButton setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    [self.cancelButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];

//    NSString *dateStr = [self.formatter stringFromDate:date];
    
    _beginDate = date,_endDate = date;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)confirmButonClick:(UIButton *)sender {
    
    if (sender.tag == 100 && self.confirmTimeBlock) self.confirmTimeBlock(self.beginDate, self.endDate);
   
     [self removeFromSuperview];
}

-(void)valueChange:(UIDatePicker*)datePicker
{
//    NSString *dateStr = [self.formatter stringFromDate:datePicker.date];
    
    if (datePicker == self.datePickerOne)
    {
        self.beginDate = datePicker.date;
        return;
    }
    self.endDate = datePicker.date;
}

-(NSDateFormatter *)formatter
{
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    }
    return _formatter;
}

@end
