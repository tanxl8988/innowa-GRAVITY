//
//  AppDelegate.m
//  Innowa
//
//  Created by Mac on 17/3/28.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "AppDelegate.h"
#import "CoreDataStack.h"
#import "APKDVR.h"
#import "CoreDataStack.h"
#import "APKRefreshLocalFilesTool.h"
#import "APKAlertTool.h"
//#import "UMMobClick/MobClick.h"

@interface AppDelegate ()

@property (assign ,nonatomic) UIBackgroundTaskIdentifier backgroundUpdateTask;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //修复在实时预览的过程中直接按电源键锁屏导致的奔溃（signal SIGPIPE）
    signal(SIGPIPE, SIG_IGN);
    
    //core data stack
    [CoreDataStack generateCoreDataStack:^(NSManagedObjectContext *context) {
       
        self.managedObjectContext = context;
        [APKRefreshLocalFilesTool sharedInstace].context = context;
    }];
   
    //DVR
    [APKDVR sharedInstance];
    
    //集成友盟统计
    //友盟后台账号：yangzc@apical.com.cn 密码：yzc123456=
//    UMConfigInstance.appKey = @"59e5c9b5aed1797a4d0003f2";
//    [MobClick startWithConfigure:UMConfigInstance];//配置以上参数后调用此方法初始化SDK！
//    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    [MobClick setAppVersion:version];
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    [self initializeTheNotificationCenter];

    return YES;
}

void uncaughtExceptionHandler(NSException*exception) {
    
    NSLog(@"CRASH: %@", exception);
    
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    
    // Internal error reporting
    
}

#pragma mark    禁止横屏
- (UIInterfaceOrientationMask )application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (self.allowRotation) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;

}

- (void)initializeTheNotificationCenter
{
    //在进入需要全屏的界面里面发送允许横屏的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startFullScreen) name:@"startFullScreen" object:nil];//允许横屏
    
    //在退出允许横屏的界面里面发送退出横屏的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endFullScreen) name:@"endFullScreen" object:nil];//退出横屏
}

#pragma mark 允许横屏
-(void)startFullScreen
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = YES;
}


#pragma mark    退出横屏
-(void)endFullScreen
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = NO;
    
    //强制归正：
    if ([[UIDevice currentDevice]   respondsToSelector:@selector(setOrientation:)]) {
        SEL selector =     NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val =UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
//    [self beginBackgroundUpdateTask];
//    //在这里加上你需要长久运行的代码
//    [self endBackgroundUptateTask];

    
}

- (void)beginBackgroundUpdateTask{
    self.backgroundUpdateTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundUptateTask];
    }];
}
- (void)endBackgroundUptateTask{
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundUpdateTask];
    self.backgroundUpdateTask = UIBackgroundTaskInvalid;
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
