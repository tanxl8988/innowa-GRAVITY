//
//  APKLocalVidioEditTool.m
//  Innowa
//
//  Created by 李福池 on 2018/6/7.
//  Copyright © 2018年 APK. All rights reserved.
//

#import "APKLocalVidioEditTool.h"

@implementation APKLocalVidioEditTool

-(void)mergeVideoToOneVideo:(NSArray *)tArray toStorePath:(NSString *)storePath WithStoreName:(NSString *)storeName andIf3D:(BOOL)tbool success:(void (^)(NSURL *storePath))successBlock failure:(void (^)(void))failureBlcok
{
    __weak typeof(self)weakSelf = self;
    AVMutableComposition *mixComposition = [self mergeVideostoOnevideo:tArray success:^(AVMutableComposition* composition){
        
        NSURL *outputFileUrl = [weakSelf joinStorePaht:storePath togetherStoreName:storeName];
        [weakSelf storeAVMutableComposition:composition withStoreUrl:outputFileUrl andVideoUrl:[tArray objectAtIndex:0] WihtName:storeName andIf3D:tbool success:successBlock failure:failureBlcok];
        
    } failure:^{
        NSLog(@"失败了");
        
    }];
    
}

-(AVMutableComposition *)mergeVideostoOnevideo:(NSArray*)array success:(void (^)(AVMutableComposition* composition))successBlock failure:(void (^)(void))failureBlcok
{
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    //合成视频轨道
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    Float64 tmpDuration =0.0f;
    
    NSError *error;
    
    for (NSInteger i=0; i<array.count; i++)
    {
        
        NSString *url = [NSString stringWithFormat:@"file://%@",array[i]];//本地文件加个file：//
        AVAsset *videoAsset = [AVAsset assetWithURL:[NSURL URLWithString:url]];
        
        CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
        
        BOOL tbool = [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject atTime:CMTimeMakeWithSeconds(tmpDuration, 0) error:&error];
        tmpDuration += CMTimeGetSeconds(videoAsset.duration);
        
    }
    
    if (error == nil) {
        if (successBlock) {
            successBlock(mixComposition);
        }
    }
    else {
        if (failureBlcok) {
            failureBlcok();
        }
    }
    
    return mixComposition;
}

/**
 *  拼接url地址
 *
 *  @param sPath 沙盒文件夹名
 *  @param sName 文件名称
 *
 *  @return 返回拼接好的url地址
 */
-(NSURL *)joinStorePaht:(NSString *)sPath togetherStoreName:(NSString *)sName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *storePath = [documentPath stringByAppendingPathComponent:sPath];
    BOOL isExist = [fileManager fileExistsAtPath:storePath];
    if(!isExist){
        [fileManager createDirectoryAtPath:storePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *realName = [NSString stringWithFormat:@"%@.mov", sName];
    storePath = [storePath stringByAppendingPathComponent:realName];
    NSURL *outputFileUrl = [NSURL fileURLWithPath:storePath];
    return outputFileUrl;
}
/**
 *  存储合成的视频，以及转mp4格式带压缩
 *
 *  @param mixComposition mixComposition参数 （ 当其是AVURLAsset类时——仅转码压缩，，AVMutableComposition类时——合并视频,进行的转码压缩同时导出操作 ）
 *  @param storeUrl       存储的路径 (完整的url路径)
 *  @param successBlock   successBlock
 *  @param failureBlcok   failureBlcok
 */
-(void)storeAVMutableComposition:(id)mixComposition withStoreUrl:(NSURL *)storeUrl andVideoUrl:(NSURL *)videoUrl WihtName:(NSString *)aName andIf3D:(BOOL)tbool success:(void (^)(NSURL *storePath))successBlock failure:(void (^)(void))failureBlcok
{
    NSLog(@"操作类型%@", [mixComposition class]);
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
                                           initWithAsset:mixComposition
                                           presetName:AVAssetExportPresetMediumQuality];
    self.exportSession = exportSession;
    
    exportSession.outputURL = storeUrl;
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeMPEG4;
    dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
    //        [self showHudInView:self.view hint:@"正在压缩"];
    //        __weak typeof(self) weakSelf = self;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        //            [weakSelf hideHud];
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed: {
                NSLog(@"failed, error:%@.", exportSession.error);
                if (failureBlcok) {
                    failureBlcok();
                }
            } break;
            case AVAssetExportSessionStatusCancelled: {
                NSLog(@"cancelled.");
            } break;
            case AVAssetExportSessionStatusCompleted: {
                NSLog(@"completed.");
//                NSLog(@"%@-%f",self.progressLabel.text,self.hud.progress);
                if (successBlock) {
                    successBlock(storeUrl);
                }
                
            } break;
            case AVAssetExportSessionStatusExporting: {
                NSLog(@"Exporting");
            }
                break;
            default: {
                NSLog(@"others.");
            } break;
        }
        dispatch_semaphore_signal(wait);
    }];
    long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
    if (timeout) {
        NSLog(@"timeout.");
    }
    if (wait) {
        //dispatch_release(wait);
        wait = nil;
    }
}

+(void)getVideoShotWithFrame:(CGRect)frame resultBlock:(void (^)(UIImage * image))resultBlock
{
    UIWindow *screenWindow = [[UIApplication sharedApplication] keyWindow];
    
    UIGraphicsBeginImageContext(screenWindow.frame.size);//全屏截图，包括window
    
    [screenWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    
    UIImage *viewImage =UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImage * image = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([viewImage CGImage], frame)];
    resultBlock(image);
}

+(void)getCurrentVideoImageWithVideoOutPut:(AVPlayerItemVideoOutput*)videoOutPut andTime:(CMTime)time resultBlock:(void(^)(UIImage *image))resultBlock
{
    CMTime itemTime = time;
    CVPixelBufferRef pixelBuffer = [videoOutPut copyPixelBufferForItemTime:itemTime itemTimeForDisplay:nil];
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext
                             createCGImage:ciImage
                             fromRect:CGRectMake(0, 0,
                                                 CVPixelBufferGetWidth(pixelBuffer),
                                                 CVPixelBufferGetHeight(pixelBuffer))];
    
    //当前帧的画面
    UIImage *currentImage = [UIImage imageWithCGImage:videoImage];
    resultBlock(currentImage);
    
}

+(void)getVideoAndMapScreenShotWithVideoImage:(UIImage *)videoImage videoFrame:(CGRect)videoFrame andMapImage:(UIImage *)mapImage mapFrame:(CGRect)mapFrame resultBlock:(void (^)(UIImage *image))resultBlock
{
    UIView *backgoundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    backgoundView.backgroundColor = [UIColor blackColor];
    UIImageView *videoImageView = [[UIImageView alloc] initWithFrame:videoFrame];
    videoImageView.image = videoImage;
    [backgoundView addSubview:videoImageView];
    
    UIImageView *mapView = [[UIImageView alloc] initWithFrame:mapFrame];
    mapView.image = mapImage;
    [backgoundView addSubview:mapView];
    
    [APKLocalVidioEditTool getBackgoundViewScreenShotImageWithBackgoundView:backgoundView resultBlock:^(UIImage *image) {
        
        resultBlock(image);
    }];
    

    
}

+(void)getBackgoundViewScreenShotImageWithBackgoundView:(UIView *)backgoundView resultBlock:(void (^)(UIImage *image))resultBlock
{
    CGSize s = backgoundView.bounds.size;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    [backgoundView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    resultBlock(image);
}

- (APKRefreshLocalFilesTool *)refreshLocalFilesTool{
    
    if (!_refreshLocalFilesTool) {
        _refreshLocalFilesTool = [APKRefreshLocalFilesTool sharedInstace];
    }
    return _refreshLocalFilesTool;
}

- (APKDownloadDVRFileTool *)downloadTool{
    
    if (!_downloadTool) {
        
        _downloadTool = [[APKDownloadDVRFileTool alloc] initWithManagedObjectContext:self.refreshLocalFilesTool.context];
    }
    
    return _downloadTool;
}

@end
