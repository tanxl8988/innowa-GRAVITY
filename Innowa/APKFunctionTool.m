//
//  APKFunctionTool.m
//  Innowa
//
//  Created by 李福池 on 2018/8/10.
//  Copyright © 2018年 APK. All rights reserved.
//

#import "APKFunctionTool.h"
#import "AFNetworking.h"

@implementation APKFunctionTool

+(void)combineAppVersion:(void (^)(BOOL isSameVersion))combineVersionBlock
{
    __block NSString *appStoreVersion = @"";
    __block NSString *xcodeVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *url = [[NSString alloc] initWithFormat:@"http://itunes.apple.com/lookup?id=%@",@"1263014143"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray *array = responseObject[@"results"];
        NSDictionary *dict = [array lastObject];
        appStoreVersion = dict[@"version"];
        
        if ([appStoreVersion isEqualToString:xcodeVersion]) {
            combineVersionBlock(YES);
            return;
        }
        combineVersionBlock(NO);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"");
    }];

}




@end
