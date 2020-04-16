//
//  APKAdjustDVRTimeViewController.m
//  Innowa
//
//  Created by Mac on 17/5/12.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKAdjustDVRTimeViewController.h"
#import "APKStepper.h"
#import "APKAlertTool.h"
#import "APKCommonTaskTool.h"
#import "MBProgressHUD.h"

@interface APKAdjustDVRTimeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet APKStepper *yearStepper;
@property (weak, nonatomic) IBOutlet APKStepper *monthStepper;
@property (weak, nonatomic) IBOutlet APKStepper *dayStepper;
@property (weak, nonatomic) IBOutlet APKStepper *hourStepper;
@property (weak, nonatomic) IBOutlet APKStepper *minuteStepper;
@property (weak, nonatomic) IBOutlet UILabel *handMakeLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (strong,nonatomic) APKCommonTaskTool *taskTool;

@end

@implementation APKAdjustDVRTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = NSLocalizedString(@"设置", nil);
    self.subTitleLabel.text = NSLocalizedString(@"时间设定", nil);
    self.handMakeLabel.text = NSLocalizedString(@"手动设置", nil);
    [self.confirmButton setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    
    self.tipsLabel.text = NSLocalizedString(@"时间设定提示", nil);
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [self setupSteppers];
}

#pragma mark - getter

- (APKCommonTaskTool *)taskTool{
    
    if (!_taskTool) {
        _taskTool = [[APKCommonTaskTool alloc] init];
    }
    return _taskTool;
}

#pragma mark - private method

- (void)setupSteppers{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy$MM$dd$HH$mm"];
    NSDate *date = [NSDate date];
    NSString *str = [formatter stringFromDate:date];
    NSArray *arr = [str componentsSeparatedByString:@"$"];
    if (arr.count != 5) {
        return;
    }
    NSInteger year = [arr[0] integerValue];
    NSInteger month = [arr[1] integerValue];
    NSInteger day = [arr[2] integerValue];
    NSInteger hour = [arr[3] integerValue];
    NSInteger minute = [arr[4] integerValue];
    [self.yearStepper configureWithMaxValue:2100  minValue:1900 currentValue:year];
    [self.monthStepper configureWithMaxValue:12 minValue:1 currentValue:month];
    [self.dayStepper configureWithMaxValue:31 minValue:1 currentValue:day];
    [self.hourStepper configureWithMaxValue:23 minValue:0 currentValue:hour];
    [self.minuteStepper configureWithMaxValue:59 minValue:0 currentValue:minute];
}

#pragma mark - actions

- (IBAction)clickConfirmButton:(UIButton *)sender {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *value = [NSString stringWithFormat:@"%@$%@$%@$%@$%@$30",self.yearStepper.value,self.monthStepper.value,self.dayStepper.value,self.hourStepper.value,self.minuteStepper.value];
    NSLog(@"set value:%@",value);
    
    __weak typeof(self)weakSelf = self;
    [self.taskTool setDVRWithProperty:@"TimeSettings" value:value completionHandler:^(BOOL success) {
        
        [hud hideAnimated:YES];
        NSString *message = success ? NSLocalizedString(@"设置成功！", nil) : NSLocalizedString(@"设置失败！", nil);
        [APKAlertTool showAlertInViewController:weakSelf message:message];
    }];
}

- (IBAction)quit:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
