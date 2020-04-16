//
//  APKModifyWifiViewController.m
//  Innowa
//
//  Created by Mac on 17/4/6.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKModifyWifiViewController.h"
#import "APKDVR.h"
#import "APKDVRTask.h"
#import "MBProgressHUD.h"
#import "APKCommonTaskTool.h"
#import "APKAlertTool.h"

@interface APKModifyWifiViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *wifiNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *wifiPasswordLabel;
@property (weak, nonatomic) IBOutlet UITextField *wifiNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *wifiPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@property (strong,nonatomic) APKCommonTaskTool *commonTaskTool;

@end

@implementation APKModifyWifiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = NSLocalizedString(@"设置", nil);
    self.subTitleLabel.text = NSLocalizedString(@"Wi-Fi设置", nil);
    self.wifiNameLabel.text = NSLocalizedString(@"Wi-Fi名称", nil);
    self.wifiPasswordLabel.text = NSLocalizedString(@"Wi-Fi密码", nil);
    [self.confirmButton setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self)weakSelf = self;
    [self.commonTaskTool getWifiInfo:^(BOOL success) {
        
        [hud hideAnimated:YES];
        if (success) {
            
            APKDVR *dvr = [APKDVR sharedInstance];
            weakSelf.wifiNameTextField.text = dvr.info.ssid;
            weakSelf.wifiPasswordTextField.text = dvr.info.encryptionKey;
            
        }else{
            
            [APKAlertTool showAlertInViewController:self title:nil message:NSLocalizedString(@"获取Wi-Fi信息失败！", nil) cancelHandler:^(UIAlertAction *action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
    }];
}

#pragma mark - getter

- (APKCommonTaskTool *)commonTaskTool{
    
    if (!_commonTaskTool) {
        _commonTaskTool = [[APKCommonTaskTool alloc] init];
    }
    return _commonTaskTool;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    BOOL isShouldChangeCharacters = YES;
    
    if (![string isEqualToString:@""]) {
        
        char ch = [string characterAtIndex:0];
        if (!(ch >= '0' && ch <= '9') && !(ch >= 'a' && ch <= 'z') && !(ch >= 'A' && ch <= 'Z')) {
            
            isShouldChangeCharacters = NO;
        }
    }
    
    return isShouldChangeCharacters;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == self.wifiNameTextField) {
        [self.wifiPasswordTextField becomeFirstResponder];
    }else if (textField == self.wifiPasswordTextField){
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - actions

- (IBAction)clickConfirmButton:(UIButton *)sender {
    
    [self.view endEditing:YES];
    
    NSString *wifiName = self.wifiNameTextField.text,*wifiPassword = self.wifiPasswordTextField.text;
    APKDVR *dvr = [APKDVR sharedInstance];
    if ([dvr.info.ssid isEqualToString:wifiName] && [dvr.info.encryptionKey isEqualToString:wifiPassword]) {//与原来wifi一致
        return;
    }
    
    NSString *errorMsg;
    if (wifiName.length == 0 || wifiName.length > 27) {
        errorMsg = NSLocalizedString(@"Wi-Fi名称格式错误", nil);
    }
    else if (wifiPassword.length < 8 || wifiPassword.length > 16) {
        errorMsg = NSLocalizedString(@"Wi-Fi密码格式错误", nil);
    }
    if (errorMsg) {
        
        [APKAlertTool showAlertInViewController:self message:errorMsg];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self)weakSelf = self;
    [self.commonTaskTool updateWifiWithSSID:wifiName password:wifiPassword completionHandler:^(BOOL success) {
        
        [hud hideAnimated:YES];
        if (success) {
            [APKAlertTool showAlertInViewController:weakSelf title:NSLocalizedString(@"设置成功！", nil) message:NSLocalizedString(@"DVR将会重启Wi-Fi", nil) cancelHandler:^(UIAlertAction *action) {
                [APKDVR sharedInstance].isConnected = NO;
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        }else{
            [APKAlertTool showAlertInViewController:weakSelf message:NSLocalizedString(@"设置失败！", nil)];
        }
    }];
}

- (IBAction)clickBackButton:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
