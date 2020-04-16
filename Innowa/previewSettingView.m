//
//  previewSettingView.m
//  Innowa
//
//  Created by 李福池 on 2018/6/15.
//  Copyright © 2018年 APK. All rights reserved.
//

#import "previewSettingView.h"
#import "MBProgressHUD.h"
#import "APKAlertTool.h"
#import "APKDVRInfo.h"
#import "APKDVR.h"

@implementation previewSettingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.frontSlider addTarget:self action:@selector(frontSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [self.rearSlider addTarget:self action:@selector(rearSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    
    self.frontL.text = NSLocalizedString(@"前", nil);
    self.rearL.text = NSLocalizedString(@"后", nil);
    
    [self.sureButton setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    [self.cancelButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    
    [self refleshSliderValue];
}

-(void)refleshSliderValue
{
    NSArray *setArray = @[@"-2",@"-1.7",@"-1.3",@"-1",@"-0.7",@"-0.3",@"0",@"0.3",@"0.7",@"1",@"1.3",@"1.7",@"2"];;
    NSInteger DVREV = [APKDVR sharedInstance].info.EV;
    NSString *EVValue = [NSString stringWithFormat:@"%@",setArray[DVREV]];
    self.frontSlider.value = [EVValue floatValue];
}

-(void)frontSliderValueChange:(UISlider*)frontSlider
{
    [self setSliderValue:frontSlider];
}

-(void)rearSliderValueChange:(UISlider*)rearSlider
{
    [self setSliderValue:rearSlider];
}

-(void)setSliderValue:(UISlider*)slider
{
    float newFrontValue = slider.value;
    NSLog(@"%f",newFrontValue);
//    float num = slider.value > 0 ? 0.5 : - 0.5;
//    newFrontValue = (slider.value + num)/1;
//    slider.value = newFrontValue;
    if (newFrontValue > -2.0 && newFrontValue <= -1.85)
        slider.value = -2.0;
    else if (newFrontValue > -1.85 && newFrontValue <= -1.7)
        slider.value = -1.7;
    else if (newFrontValue > -1.7 && newFrontValue <= -1.5)
        slider.value = -1.7;
    else if (newFrontValue > -1.5 && newFrontValue <= -1.3)
        slider.value = -1.3;
    else if (newFrontValue > -1.3 && newFrontValue <= -1.15)
        slider.value = -1.3;
    else if (newFrontValue > -1.15 && newFrontValue <= -1.0)
        slider.value = -1.0;
    else if (newFrontValue > -1.0 && newFrontValue <= -0.85)
        slider.value = -1.0;
    else if (newFrontValue > -0.85 && newFrontValue <= -0.7)
        slider.value = -0.7;
    else if (newFrontValue > -0.7 && newFrontValue <= -0.5)
        slider.value = -0.7;
    else if (newFrontValue > -0.5 && newFrontValue <= -0.3)
        slider.value = -0.3;
    else if (newFrontValue > -0.3 && newFrontValue <= -0.15)
        slider.value = -0.3;
    else if (newFrontValue > -0.15 && newFrontValue <= 0)
        slider.value = 0;
    else if (newFrontValue > 0 && newFrontValue <= 0.15)
        slider.value = 0;
    else if (newFrontValue <= 0.3 && newFrontValue > 0.15)
        slider.value = 0.3;
    else if (newFrontValue <= 0.5 && newFrontValue > 0.3)
        slider.value = 0.3;
    else if (newFrontValue <= 0.7 && newFrontValue > 0.5)
        slider.value = 0.7;
    else if (newFrontValue <= 0.85 && newFrontValue > 0.7)
        slider.value = 0.7;
    else if (newFrontValue <= 1.0 && newFrontValue > 0.85)
        slider.value = 1.0;
    else if (newFrontValue <= 1.15 && newFrontValue > 1.0)
        slider.value = 1.0;
    else if (newFrontValue <= 1.3 && newFrontValue > 1.15)
        slider.value = 1.3;
    else if (newFrontValue <= 1.5 && newFrontValue > 1.3)
        slider.value = 1.3;
    else if (newFrontValue <= 1.7 && newFrontValue > 1.5)
        slider.value = 1.7;
    else if (newFrontValue <= 1.85 && newFrontValue > 1.7)
        slider.value = 1.7;
    else if(newFrontValue <= 2.0 && newFrontValue > 1.85)
        slider.value = 2.0;
}

- (IBAction)confirmButtonAction:(UIButton *)sender {
    
    if (sender.tag == 101) {
        [self removeFromSuperview];
        return;
    }

    NSDictionary *setDic = @{@"-2.0":@"EVN200", @"-1.7":@"EVN167", @"-1.3":@"EVN133", @"-1.0":@"EVN100",
                             @"-0.7":@"EVN067", @"-0.3":@"EVN033", @"0.0":@"EV0", @"0.3":@"EVP033", @"0.7":@"EVP067", @"1.0":@"EVP100", @"1.3":@"EVP133", @"1.7":@"EVP167", @"2.0":@"EVP200"};
    NSDictionary *infoDic = @{@"EVN200":@"0", @"EVN167":@"1", @"EVN133":@"2", @"EVN100":@"3", @"EVN067":@"4", @"EVN033":@"5", @"EV0":@"6", @"EVP033":@"7", @"EVP067":@"8", @"EVP100":@"9", @"EVP133":@"10", @"EVP167":@"11", @"EVP200":@"12"};

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.label.text = NSLocalizedString(@"设置正在更新中", nil);
    NSString *setString = setDic[[NSString stringWithFormat:@"%.1f",(float)self.frontSlider.value]];
    
    __weak typeof(self)weakSelf = self;
    [self.commonTaskTool setDVRWithProperty:@"EV" value:setString completionHandler:^(BOOL success) {
        
        if (success) {
            hud.mode = MBProgressHUDModeText;
            hud.label.text = NSLocalizedString(@"设置成功！", nil);
            [hud hideAnimated:YES afterDelay:1.f];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString *value = infoDic[setString];
                [APKDVR sharedInstance].info.EV = [value integerValue];
               [weakSelf removeFromSuperview];
            });
            
            
        }else{
            [hud hideAnimated:YES];
            [APKAlertTool showAlertInViewController:weakSelf.showInVC message:NSLocalizedString(@"设置失败！", nil)];
            [weakSelf removeFromSuperview];
        }
    }];
}

- (APKCommonTaskTool *)commonTaskTool{
    
    if (!_commonTaskTool) {
        _commonTaskTool = [[APKCommonTaskTool alloc] init];
    }
    return _commonTaskTool;
}



@end
