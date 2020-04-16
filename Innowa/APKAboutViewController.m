//
//  APKAboutViewController.m
//  Innowa
//
//  Created by Mac on 17/10/10.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKAboutViewController.h"
#import "APKAboutContentController.h"

@interface APKAboutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@property (strong,nonatomic) APKAboutContentController *content;

@end

@implementation APKAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = NSLocalizedString(@"设置", nil);
    self.subTitleLabel.text = NSLocalizedString(@"关于innowa", nil);
    
    self.content.aboutLabel.text = NSLocalizedString(@"innowa简介", nil);
    self.content.logoLabel.text = NSLocalizedString(@"联系我们及支援", nil);
    self.content.connectLabel.text = NSLocalizedString(@"关注我们", nil);
    
    [self.content.logoButton addTarget:self action:@selector(clickLogoButton) forControlEvents:UIControlEventTouchUpInside];
    [self.content.youtubeButton addTarget:self action:@selector(clickYoutubeButton) forControlEvents:UIControlEventTouchUpInside];
    [self.content.facebookButton addTarget:self action:@selector(clickFacebookButton) forControlEvents:UIControlEventTouchUpInside];
    [self.content.instagramButton addTarget:self action:@selector(clickInstagramButton) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - event response

- (IBAction)quit:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickInstagramButton{
    
    NSString *stringURL = @"https://www.instagram.com/innowa.jp/";
    NSURL *url = [NSURL URLWithString:stringURL];
    
    NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
    NSInteger iosVersionNumber = [[[iosVersion componentsSeparatedByString:@"."] firstObject] integerValue];
    if (iosVersionNumber >= 10) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) { /*do nothing*/ }];
    }
    else{
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)clickFacebookButton{
    
    NSString *stringURL = @"https://www.facebook.com/innowa.jp";
    NSURL *url = [NSURL URLWithString:stringURL];
    
    NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
    NSInteger iosVersionNumber = [[[iosVersion componentsSeparatedByString:@"."] firstObject] integerValue];
    if (iosVersionNumber >= 10) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) { /*do nothing*/ }];
    }
    else{
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)clickYoutubeButton{
    
    NSString *stringURL = @"https://www.youtube.com/channel/UCPVkb-P9wQ1zTQTYcGrw7Ug";
    NSURL *url = [NSURL URLWithString:stringURL];
    
    NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
    NSInteger iosVersionNumber = [[[iosVersion componentsSeparatedByString:@"."] firstObject] integerValue];
    if (iosVersionNumber >= 10) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) { /*do nothing*/ }];
    }
    else{
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)clickLogoButton{
    
    NSString *stringURL = @"https://www.innowa.jp/";
    NSURL *url = [NSURL URLWithString:stringURL];
    
    NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
    NSInteger iosVersionNumber = [[[iosVersion componentsSeparatedByString:@"."] firstObject] integerValue];
    if (iosVersionNumber >= 10) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) { /*do nothing*/ }];
    }
    else{
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - getter

- (APKAboutContentController *)content{
    
    if (!_content) {
        
        for (UIViewController *vc in self.childViewControllers) {
            if ([vc isKindOfClass:[APKAboutContentController class]]) {
                
                _content = (APKAboutContentController *)vc;
                break;
            }
        }
    }
    return _content;
}

@end
