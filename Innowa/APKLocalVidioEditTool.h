//
//  APKLocalVidioEditTool.h
//  Innowa
//
//  Created by 李福池 on 2018/6/7.
//  Copyright © 2018年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "APKRefreshLocalFilesTool.h"
#import "APKDownloadDVRFileTool.h"

@interface APKLocalVidioEditTool : NSObject
@property (nonatomic,retain) AVAssetExportSession *exportSession;
@property (nonatomic,retain) APKRefreshLocalFilesTool *refreshLocalFilesTool;
@property (nonatomic,retain) APKDownloadDVRFileTool *downloadTool;

-(void)mergeVideoToOneVideo:(NSArray *)tArray toStorePath:(NSString *)storePath WithStoreName:(NSString *)storeName andIf3D:(BOOL)tbool success:(void (^)(NSURL *storePath))successBlock failure:(void (^)(void))failureBlcok;
-(AVMutableComposition *)mergeVideostoOnevideo:(NSArray*)array success:(void (^)(AVMutableComposition* composition))successBlock failure:(void (^)(void))failureBlcok;
+(void)getVideoShotWithFrame:(CGRect)frame resultBlock:(void (^)(UIImage *))resultBlock;
+(void)getCurrentVideoImageWithVideoOutPut:(AVPlayerItemVideoOutput*)videoOutPut andTime:(CMTime)time resultBlock:(void(^)(UIImage *image))resultBlock;
+(void)getVideoAndMapScreenShotWithVideoImage:(UIImage *)videoImage videoFrame:(CGRect)videoFrame andMapImage:(UIImage *)mapImage mapFrame:(CGRect)mapFrame resultBlock:(void (^)(UIImage *image))resultBlock;

@end
