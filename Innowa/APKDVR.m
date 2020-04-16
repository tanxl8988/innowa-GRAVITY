//
//  APKDVR.m
//  AITBrain
//
//  Created by Mac on 17/3/20.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKDVR.h"
#import "APKDVRTaskId.h"
#import "APKWifiTool.h"
#import "AFNetworking.h"
#import "APKGetDVRConnectionInfo.h"
#import "APKCommonTaskTool.h"

#define requestHaveError  -1000
#define requestTimeout 10

@interface APKDVR ()<NSURLSessionDataDelegate>

@property (strong,nonatomic) AFHTTPSessionManager *httpManager;
@property (strong,nonatomic) APKGetDVRConnectionInfo *getConnectionInfo;

@end

@implementation APKDVR

#pragma mark - init

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.states = [[APKDVRStates alloc] init];
        self.info = [[APKDVRInfo alloc] init];
        self.isConnected = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationState:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationState:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

static APKDVR *instance = nil;
+ (instancetype)sharedInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[APKDVR alloc] init];
    });
    
    return instance;
}

#pragma mark - getter

- (AFHTTPSessionManager *)httpManager{
    
    if (!_httpManager) {
        _httpManager = [AFHTTPSessionManager manager];
        _httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSSet *contentTypes = [NSSet setWithObjects:@"text/plain",@"text/xml", nil];
        _httpManager.responseSerializer.acceptableContentTypes = contentTypes;
        _httpManager.requestSerializer.timeoutInterval = requestTimeout;
    }
    return _httpManager;
}

#pragma mark - public method

- (void)performTask:(APKDVRTask *)task{
    
    if ([self.states updateWithTask:task]) {
        
        __weak typeof(self)weakSelf = self;
        NSURLSessionDataTask *dataTask = [self.httpManager GET:task.url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSInteger taskId = [task.taskDescription integerValue];
            NSInteger rval = [weakSelf getReturnValueWithTaskId:taskId receieveData:responseObject];
            
            if (taskId == GET_LOGIN_TOKEN) {
                
                NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSLog(@"");
            }
            
            if (taskId == RECORD_EVENT_ID && rval == 798)
                [weakSelf.info updateWithTaskId:taskId data:responseObject];//info处理数据
            else if (rval == 0)
                [weakSelf.info updateWithTaskId:taskId data:responseObject];//info处理数据

            [weakSelf.states updateWithTaskId:taskId rval:rval];//刷新对应taskId的states状态
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            NSInteger taskId = [task.taskDescription integerValue];
            [weakSelf.states updateWithTaskId:taskId rval:requestHaveError];
            if (![APKWifiTool isConnectedAITCameraWifi]) {
                weakSelf.isConnected = NO;
            }
            NSLog(@"%@",error.localizedDescription);
        }];
        
        dataTask.taskDescription = [NSString stringWithFormat:@"%d",task.taskId];
        NSLog(@"执行>>>\n%@失败",task.url);
    }
}

#pragma mark - private method

- (void)handleApplicationState:(NSNotification *)notification{
    
    if ([notification.name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
    
        if (self.getConnectionInfo || ![APKWifiTool isConnectedAITCameraWifi]) {
            
            return;
        }
        
        self.getConnectionInfo = [[APKGetDVRConnectionInfo alloc] init];
        __weak typeof(self)weakSelf = self;
        [self.getConnectionInfo execute:^(BOOL success) {
            weakSelf.getConnectionInfo = nil;
            if (success) {
                weakSelf.isConnected = YES;
                [weakSelf startHeartbeat];
            }
        }];
        
    }else if([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]){
        self.isConnected = NO;
    }
}

-(void)startHeartbeat
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timeChange) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)timeChange
{
    [[[APKCommonTaskTool alloc] init] getLiveInfo:^(BOOL success) {
        NSLog(@"Heatbeat is going on !");
    }];
}

- (NSInteger)getReturnValueWithTaskId:(NSInteger)taskId receieveData:(NSData *)data{
    
    NSInteger rval;
    if (taskId == GET_PHOTO_LIST_ID || taskId == GET_VIDEO_LIST_ID || taskId == GET_EVENT_LIST_ID) {

        //获取文件列表返回结果没有返回值，所以默认请求成功
        rval = 0;
        
    }else{
        
        NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"返回<<<\n%@",msg);
        NSArray *arr = [msg componentsSeparatedByString:@"\n"];
        if (arr.count > 0) {
            rval = [arr.firstObject integerValue];
        }
    }
    
    return rval;
}

@end
