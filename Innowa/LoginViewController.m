//
//  LoginViewController.m
//  Innowa
//
//  Created by Mac on 18/4/8.
//  Copyright © 2018年 APK. All rights reserved.
//

#import "LoginViewController.h"
#import "APKCommonTaskTool.h"
#import <SafariServices/SafariServices.h>
#import "AppDelegate.h"
#import "APKAlertTool.h"
@interface LoginViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailF;
@property (weak, nonatomic) IBOutlet UITextField *passwordF;
@property (weak, nonatomic) IBOutlet UIButton *rememberBt;
@property (nonatomic,retain) APKCommonTaskTool *taskTool;
@property (nonatomic,retain) NSString *tokenId;
@property (nonatomic,retain) UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *skipBtn;
@property (weak, nonatomic) IBOutlet UILabel *tipL;
@property (weak, nonatomic) IBOutlet UIButton *resignBtn;
@property (weak, nonatomic) IBOutlet UILabel *privacyDetailL;
@property (weak, nonatomic) IBOutlet UIButton *privacyBtn;
@property (weak, nonatomic) IBOutlet UILabel *rememberMeL;
@property (nonatomic,retain) NSMutableAttributedString *privacyStr;
@property (weak, nonatomic) IBOutlet UITextView *privacyTextView;
@property (nonatomic,assign) NSInteger numOfLoginTime;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    KWEAKSELF;
    [self executeRequestWithUrl:@"https://drive.innowa.jp/user/api_get_token" commonTaskCompleteHandler:^(NSDictionary *info) {
        
        weakSelf.tokenId = info[@"token_hash"];
    }];
    
//    self.tipL.text = NSLocalizedString(@"當使用此應用程式時，你會被視作已同意其私隱政策", nil);
//    self.tipL.attributedText = self.privacyStr;
    self.privacyTextView.attributedText = self.privacyStr;
    self.privacyTextView.editable = NO;
    self.privacyTextView.delegate = self;
    [self.privacyBtn setTitle:NSLocalizedString(@"私隱政策", nil) forState:UIControlStateNormal];
    [self.loginBtn setTitle:NSLocalizedString(@"登陆", nil) forState:UIControlStateNormal];
    [self.skipBtn setTitle:NSLocalizedString(@"跳过", nil) forState:UIControlStateNormal];
    [self.resignBtn setTitle:NSLocalizedString(@"注册", nil) forState:UIControlStateNormal];
    self.emailF.placeholder = NSLocalizedString(@"用户名", nil);
    self.passwordF.placeholder = NSLocalizedString(@"密码", nil);
    self.rememberMeL.text = NSLocalizedString(@"记住密码", nil);
    
    NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    if (user.length > 0) {
        self.emailF.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
        self.passwordF.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
        self.rememberBt.selected = YES;
    }
    
    // Do any additional setup after loading the view.
}

- (BOOL)textView:(UITextView*)textView shouldInteractWithURL:(NSURL*)URL inRange:(NSRange)characterRange {
    
    if ([[URL absoluteString] isEqualToString:@"privacyStr"])
    {
        [self performSegueWithIdentifier:@"pushPrivacyController" sender:nil];
    }
    return YES;
}

-(void)executeRequestWithUrl:(NSString *)url commonTaskCompleteHandler:(commonTaskCompleteHandler)completeHandler
{
    NSURL *U = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:U];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error == nil) {
            //6.解析服务器返回的数据
            //说明：（此处返回的数据是JSON格式的，因此使用NSJSONSerialization进行反序列化处理）
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            completeHandler(dict);
            NSLog(@"%@",dict);
        }
    }];
    
    //5.执行任务
    [dataTask resume];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
- (IBAction)signInAction:(UIButton *)sender {
    
//    KWEAKSELF;
//    NSString *body = [NSString stringWithFormat:@"api_token=%@&login=%@&password=%@&msg_format=%@",@"35bf926c8ba8eb82aa541fb667e1a152",@"Tanxl8988",self.passwordF.text,@"json"];
//    body = @"api_token=35bf926c8ba8eb82aa541fb667e1a152&login=tester6@connectized.com&contact_phone=17088748656&password=12345678&msg_format=json";
//    NSString *urlStr = [NSString stringWithFormat:@"https://drive.innowa.jp/user/login?msg_format=json&%@",body];
//    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    [self executeRequestWithUrl:urlStr commonTaskCompleteHandler:^(NSDictionary *info) {
//
//        NSString *infoStr = (NSString *)info;
//        if ([infoStr containsString:@"Success"]) {
//            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
//        }else{
//            [APKAlertTool showAlertInViewController:self title:nil message:NSLocalizedString(@"登陆失败", nil) handler:nil];
//        }
//    }];
    
    self.numOfLoginTime++;
    
    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];

    //2.根据会话对象创建task
    NSURL *url = [NSURL URLWithString:@"https://drive.innowa.jp/user/login?msg_format=json"];

    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    //4.修改请求方法为POST
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];//头部信息

//    NSString *body2 = @"api_token=35bf926c8ba8eb82aa541fb667e1a152&login=tester6@connectized.com&password=12345678&msg_format=json";
//    NSString *body3 = @"api_token=35bf926c8ba8eb82aa541fb667e1a152&login=793948988@qq.com&password=tanxl8988&msg_format=json";
    NSString *body4 = [NSString stringWithFormat:@"api_token=%@&login=%@&password=%@&msg_format=json",self.tokenId,self.emailF.text,self.passwordF.text];

    //5.设置请求体
    request.HTTPBody = [body4 dataUsingEncoding:NSUTF8StringEncoding];

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        //8.解析数据
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"%@",dict);
        if (dict != nil && [dict[@"status"]isEqualToString:@"Success"]){
            
//            [APKAlertTool showAlertInViewController:self message:NSLocalizedString(@"登陆成功",nil)];
//            [APKAlertTool showAlertInViewController:self title:nil message:NSLocalizedString(@"登陆成功",nil) handler:^(UIAlertAction *action) {
//
//
//            }];
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
        else{
            if (self.numOfLoginTime < 3) {//尝试2次连续登陆
                [self signInAction:sender];
            }else
                [APKAlertTool showAlertInViewController:self title:nil message:NSLocalizedString(@"登陆失败", nil) handler:nil];
        }

    }];

    //7.执行任务
    [dataTask resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)PrivacyAction:(UIButton *)sender {
    
}

- (IBAction)registerAction:(UIButton *)sender {
    
//      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://drive.innowa.jp/#register"]];
    
    NSURL *url = [NSURL URLWithString:@"http://drive.innowa.jp/user/register"];
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:url];
    [self showViewController:safariVC sender:nil];

}
- (IBAction)rememberAction:(UIButton *)sender{
    
    self.rememberBt.selected = !self.rememberBt.selected;
    if (self.rememberBt.selected == YES) {
        [[NSUserDefaults standardUserDefaults] setObject:self.emailF.text forKey:@"user"];
        [[NSUserDefaults standardUserDefaults] setObject:self.passwordF.text forKey:@"password"];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:self.emailF.text forKey:@""];
        [[NSUserDefaults standardUserDefaults] setObject:self.passwordF.text forKey:@""];
    }
        

}


- (APKCommonTaskTool *)taskTool{
    
    if (!_taskTool) {
        _taskTool = [[APKCommonTaskTool alloc] init];
    }
    return _taskTool;
}

- (UIWebView *)webView   {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webView.dataDetectorTypes = UIDataDetectorTypeAll;
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (NSMutableAttributedString *)privacyStr
{
    if (!_privacyStr) {
        
        NSArray *languageArry = [NSLocale preferredLanguages];
        NSString *currentLanguage = [languageArry objectAtIndex:0];
        if ([currentLanguage containsString:@"ja"]) {
            
            _privacyStr = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"當使用此應用程式時", nil)];
            NSMutableAttributedString *privacyStr = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"私隱政策", nil)];
            NSDictionary * dic = @{NSFontAttributeName :[UIFont systemFontOfSize:16]};
            [_privacyStr addAttributes:dic range:NSMakeRange(0, privacyStr.length)];
            NSDictionary * dic2 = @{NSFontAttributeName :[UIFont systemFontOfSize:16],NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle),NSLinkAttributeName:@"privacyStr"};
            [privacyStr addAttributes:dic2 range:NSMakeRange(0, privacyStr.length)];
            [_privacyStr appendAttributedString:privacyStr];
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"你會被視作已同意其", nil)];
            [_privacyStr appendAttributedString:str];
        }else
        {
            _privacyStr = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"當使用此應用程式時", nil)];
            NSMutableAttributedString *privacyStr = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"私隱政策", nil)];
//            NSDictionary * dic = @{NSFontAttributeName :[UIFont systemFontOfSize:16]};
//            [_privacyStr addAttributes:dic range:NSMakeRange(0, privacyStr.length)];
            NSDictionary * dic2 = @{NSFontAttributeName :[UIFont systemFontOfSize:16],NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle),NSLinkAttributeName:@"privacyStr"};
            [privacyStr addAttributes:dic2 range:NSMakeRange(0, privacyStr.length)];
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"你會被視作已同意其", nil)];
            [_privacyStr appendAttributedString:str];
            [_privacyStr appendAttributedString:privacyStr];
        }
        
    }
    return _privacyStr;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
