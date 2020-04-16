//
//  APKperformDownloadTaskTool.m
//  万能AIT
//
//  Created by Mac on 17/3/23.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKDownloadDVRFileTool.h"
#import "AFNetworking.h"
#import "DVRFile.h"
#import "APKPhotosTool.h"
#import "LocalFile.h"
#import "APKHandleGpsInfoTool.h"

typedef enum : NSUInteger {
    kAPKDownloadTaskTypeNone,
    kAPKDownloadTaskTypeNormal,
    kAPKDownloadTaskTypeThumbnail,
    kAPKDownloadTaskTypePreviewPhoto,
    kAPKDownloadTaskTypeShare,
} APKDownloadTaskType;

@interface APKDownloadDVRFileTool ()

@property (copy,nonatomic) APKDownloadDVRFileThumbnailCompletionHandler thumbnailTaskCompletionHandler;
@property (copy,nonatomic) APKDownloadDVRFileCompletionHandler normalTaskCompletionHandler;
@property (copy,nonatomic) APKDownloadDVRFileProgressHandler normalTaskProgressHandler;
@property (copy,nonatomic) APKDownloadDVRFileUpdateHandler normalTaskUpdateHandler;
@property (copy,nonatomic) APKDownloadShareFileCompletionHandler shareTaskCompletionHandler;
@property (copy,nonatomic) APKDownloadDVRFileProgressHandler shareTaskProgressHandler;

@property (strong,nonatomic) NSString *thumbnailsDirectory;
@property (strong,nonatomic) NSMutableArray *failureNormalTaskArray;
@property (strong,nonatomic) NSMutableArray *normalTaskArray;
@property (strong,nonatomic) NSMutableArray *previewPhotoTaskArray;
@property (strong,nonatomic) NSMutableArray *thumbnailTaskArray;
@property (strong,nonatomic) NSMutableArray *successThumbnailTaskArray;
@property (strong,nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (assign) APKDownloadTaskType  downloadType;
@property (strong,nonatomic) AFURLSessionManager *sessionManager;
@property (strong,nonatomic) NSManagedObjectContext *context;
@property (assign) BOOL isCollected;
@property (assign) BOOL isRearCameraFile;
@property (assign) BOOL isCancelled;
@property (strong,nonatomic) APKDVRFile *shareFile;
@property (assign,nonatomic) BOOL isDownloadGpsInfo;
@property (nonatomic,retain) LocalFile *localFile;
@property (nonatomic,retain) NSMutableArray *gpsDataArray;
@property (nonatomic,retain) NSString *gpsInfoDownloadUrl;
@property (nonatomic,retain) NSMutableArray *downloadDvrFileDataArr;
@property (nonatomic,retain) APKHandleGpsInfoTool *handleGpsInfoTool;

@end

@implementation APKDownloadDVRFileTool

#pragma mark - life circle

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)context{
    
    self = [super init];
    if (self) {
        
        self.context = context;
        
        //确保沙盒里有存放缩略图的文件夹
        NSFileManager *fileManager = [NSFileManager defaultManager];
        self.thumbnailsDirectory = [NSString stringWithFormat:@"%@/Documents/thumbnails",NSHomeDirectory()];
        if(![fileManager fileExistsAtPath:self.thumbnailsDirectory]){//如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
            [fileManager createDirectoryAtPath:self.thumbnailsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

#pragma mark - getter

-(APKHandleGpsInfoTool *)handleGpsInfoTool
{
    if (!_handleGpsInfoTool) {
        _handleGpsInfoTool = [APKHandleGpsInfoTool new];
    }
    return _handleGpsInfoTool;
}

- (AFURLSessionManager *)sessionManager{
    
    if (!_sessionManager) {
        
        _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    
    return _sessionManager;
}

- (NSMutableArray *)failureNormalTaskArray{
    
    if (!_failureNormalTaskArray) {
        _failureNormalTaskArray = [[NSMutableArray alloc] init];
    }
    return _failureNormalTaskArray;
}

- (NSMutableArray *)previewPhotoTaskArray{
    
    if (!_previewPhotoTaskArray) {
        _previewPhotoTaskArray = [[NSMutableArray alloc] initWithCapacity:3];
    }
    return _previewPhotoTaskArray;
}

- (NSMutableArray *)normalTaskArray{
    
    if (!_normalTaskArray) {
        _normalTaskArray = [[NSMutableArray alloc] init];
    }
    return _normalTaskArray;
}

- (NSMutableArray *)successThumbnailTaskArray{
    
    if (!_successThumbnailTaskArray) {
        
        _successThumbnailTaskArray = [[NSMutableArray alloc] init];
    }
    return _successThumbnailTaskArray;
}

- (NSMutableArray *)thumbnailTaskArray{
    
    if (!_thumbnailTaskArray) {
        _thumbnailTaskArray = [[NSMutableArray alloc] init];
    }
    return _thumbnailTaskArray;
}

-(NSMutableArray *)downloadDvrFileDataArr
{
    if (!_downloadDvrFileDataArr) {
        
        _downloadDvrFileDataArr = [NSMutableArray array];
    }
    return _downloadDvrFileDataArr;
}

#pragma mark - private method

- (void)saveFile:(APKDVRFile *)file withUrl:(NSURL *)url isVidioEdit:(BOOL)isEdit{
    
    PHAssetMediaType type = file.type == kAPKDVRFileTypePhoto ? PHAssetMediaTypeImage : PHAssetMediaTypeVideo;
    __weak typeof(self)weakSelf = self;
    
    if ([file.originalName containsString:@"MOV"] && !weakSelf.isDownloadGpsInfo) {//new add download NMEA file
        
        [self downloadGpsInfoUrl:file.originalName];
        self.downloadDvrFileDataArr = [NSMutableArray arrayWithArray:@[file,url,@(isEdit)]];
        return;
    }
    
    [APKPhotosTool addFileWithUrl:url fileType:type successBlock:^(NSString *identifier) {//先加到系统相册，后续从相册里面读取
        
        [weakSelf.context performBlock:^{

            DVRFile *dvrFile = dvrFile = [DVRFile getDVRFileWithName:file.name type:file.type context:weakSelf.context];
            if (!dvrFile) {
                dvrFile = [DVRFile createDVRFileWithFile:file context:weakSelf.context];
            }
            [LocalFile createWithFile:dvrFile fileDate:file.date identifier:identifier isCollected:weakSelf.isCollected isRearCameraFile:weakSelf.isRearCameraFile gpsData:weakSelf.gpsDataArray context:weakSelf.context];
            [weakSelf.context save:nil];
            file.isDownloaded = YES;
            
            [[NSFileManager defaultManager] removeItemAtURL:url error:nil];//移除临时保存文件
            
            if (isEdit) return;
            
            [weakSelf.normalTaskArray removeObject:file];//下载完成一个 删除一个 循环下载
            if (weakSelf.normalTaskArray.count == 0) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    weakSelf.normalTaskCompletionHandler(weakSelf.failureNormalTaskArray);
                });
            }
            [weakSelf removeLastDownloadFileData];
            
            [weakSelf performDownloadTask];
        }];
        
    } failureBlock:^(NSError *error) {
        
        [[NSFileManager defaultManager] removeItemAtURL:url error:nil];//移除临时文件
        [weakSelf.normalTaskArray removeObject:file];
        if (weakSelf.normalTaskArray.count == 0) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                weakSelf.normalTaskCompletionHandler(weakSelf.failureNormalTaskArray);
            });
        }
        [weakSelf performDownloadTask];
    }];
}

-(void)removeLastDownloadFileData
{
    [self.downloadDvrFileDataArr removeAllObjects];
    [self.gpsDataArray removeAllObjects];
    self.isDownloadGpsInfo = NO;
}

-(void)downloadGpsInfoUrl:(NSString*)url
{
    KWEAKSELF;
    weakSelf.gpsInfoDownloadUrl = url;
    weakSelf.isDownloadGpsInfo = YES;
    [weakSelf performDownloadTask];
}

- (void)handleDownloadResultWithFilePath:(NSURL *)filePath error:(NSError *)error{
    
    NSString *url = [filePath absoluteString];//new add ??
    if ([url containsString:@"NMEA"]) {
        return;
    }
    
    if (self.downloadType == kAPKDownloadTaskTypeShare) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error) {
                self.shareTaskCompletionHandler(NO,nil);
            }else{
                self.shareTaskCompletionHandler(YES,filePath);
            } 
        });
        self.shareFile = nil;
        
    }else if (self.downloadType == kAPKDownloadTaskTypeNormal) {
        
        APKDVRFile *file = self.normalTaskArray.firstObject;
        if (error) {
            
            if (self.isCancelled) {
                
                [self.failureNormalTaskArray addObjectsFromArray:self.normalTaskArray];
                [self.normalTaskArray removeAllObjects];
                
            }else{
                
                [self.failureNormalTaskArray addObject:file];
            }
            
        }else{
            
            [self saveFile:file withUrl:filePath isVidioEdit:NO];
            return;
        }
        
        [self.normalTaskArray removeObject:file];
        if (self.normalTaskArray.count == 0) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.normalTaskCompletionHandler(self.failureNormalTaskArray);
            });
        }
        
    }else if (self.downloadType == kAPKDownloadTaskTypeThumbnail){
        
        APKDVRFile *file = self.thumbnailTaskArray.firstObject;
        if (!error) {
            
            file.thumbnailPath = filePath.path;
            [self.successThumbnailTaskArray addObject:file];
        }
        
//        UIImage *image = [UIImage imageWithContentsOfFile:filePath.path];
//        NSLog(@"thumbnail size:%f,%f",image.size.width,image.size.height);
        
        [self.thumbnailTaskArray removeObject:file];
        
        if (self.thumbnailTaskArray.count == 0) {//全部下载完成
            
            //save to CoreData
            __weak typeof(self)weakSelf = self;
            [self.context performBlock:^{
                
                for (APKDVRFile *file in weakSelf.successThumbnailTaskArray) {
                    
                    DVRFile *dvrFile = [DVRFile getDVRFileWithName:file.name type:file.type context:weakSelf.context];
                    if (dvrFile) {
                        dvrFile.thumbnailPath = file.thumbnailPath;
                    }else{
                        [DVRFile createDVRFileWithFile:file context:weakSelf.context];
                    }
                }
                [weakSelf.context save:nil];
                weakSelf.thumbnailTaskCompletionHandler();
            }];
        }
        
    }else if (self.downloadType == kAPKDownloadTaskTypePreviewPhoto){
        
        APKDVRFile *file = self.previewPhotoTaskArray.firstObject;
        if (!error) {
            
            file.previewPath = filePath.path;
        }
        
        self.downloadPreviewPhotoCompletionHandler(file);
        [self.previewPhotoTaskArray removeObject:file];
    }
    
    [self performDownloadTask];
}

- (void)handleDownloadProgress:(NSProgress *)downloadProgress{
    
    if (self.downloadType != kAPKDownloadTaskTypeNormal && self.downloadType != kAPKDownloadTaskTypeShare) return;
    
    float progress = (float)downloadProgress.completedUnitCount / (float)downloadProgress.totalUnitCount;
    NSString *progressMsg = nil;
    if (downloadProgress.totalUnitCount >= 1000000) {
        
        progressMsg = [NSString stringWithFormat:@"%.2fM/%.2fM",(CGFloat)downloadProgress.completedUnitCount/1000000,(CGFloat)downloadProgress.totalUnitCount/1000000];
        
    }else{
        
        progressMsg = [NSString stringWithFormat:@"%.fk/%.fk",(CGFloat)downloadProgress.completedUnitCount/1000,(CGFloat)downloadProgress.totalUnitCount/1000];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.downloadType == kAPKDownloadTaskTypeNormal) {
            self.normalTaskProgressHandler(progress,progressMsg);
        }else if (self.downloadType == kAPKDownloadTaskTypeShare){
            self.shareTaskProgressHandler(progress,progressMsg);
        }
    });
}

- (NSURL *)downloadSavePathWithResponse:(NSURLResponse *)response{
    
    NSString *filePath = nil;
    if (self.downloadType == kAPKDownloadTaskTypeThumbnail){
        
        filePath = [self.thumbnailsDirectory stringByAppendingPathComponent:response.suggestedFilename];
        
    }else{
        
        filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:response.suggestedFilename];
    }
    
    return [NSURL fileURLWithPath:filePath];
}

- (void)performDownloadTask{
    
    NSURL *url = nil;
    if (self.isDownloadGpsInfo) {//new add
        
        self.gpsInfoDownloadUrl = [self replaceRWithF:self.gpsInfoDownloadUrl];
        NSString *urlStr = [NSString stringWithFormat:@"http://192.72.1.1%@",self.gpsInfoDownloadUrl];
        urlStr = [urlStr stringByReplacingOccurrencesOfString:@"MOV" withString:@"NMEA"];
//        urlStr = [urlStr stringByReplacingOccurrencesOfString:@"R" withString:@"F"];
//        urlStr = [self replaceRWithF:urlStr];
        NSLog(@"gps download url : %@",urlStr);
        url = [NSURL URLWithString:urlStr];
    }
    else if (self.shareFile) {//分享优先
        
        url = [NSURL URLWithString:self.shareFile.fileDownloadPath];
        self.downloadType = kAPKDownloadTaskTypeShare;
        
    }else if (self.normalTaskArray.count > 0) {
        
        APKDVRFile *file = self.normalTaskArray.firstObject;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.normalTaskUpdateHandler(file);
        });
        url = [NSURL URLWithString:file.fileDownloadPath];
        self.downloadType = kAPKDownloadTaskTypeNormal;
        
    }else if (self.previewPhotoTaskArray.count > 0) {
        
        APKDVRFile *file = self.previewPhotoTaskArray.firstObject;
        url = [NSURL URLWithString:file.fileDownloadPath];
        self.downloadType = kAPKDownloadTaskTypePreviewPhoto;
        
    }else if (self.thumbnailTaskArray.count > 0) {
        
        APKDVRFile *file = self.thumbnailTaskArray.firstObject;
        url = [NSURL URLWithString:file.thumbnailDownloadPath];
        self.downloadType = kAPKDownloadTaskTypeThumbnail;
    }
    
    if (!url) {
        
        self.downloadType = kAPKDownloadTaskTypeNone;
        return;
    }
    
    NSTimeInterval timeout = 15.0;
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:timeout];
    __weak typeof(self)weakSelf = self;
    NSURLSessionDownloadTask *task = [self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        if (!self.isDownloadGpsInfo) {
            [weakSelf handleDownloadProgress:downloadProgress];
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        return [weakSelf downloadSavePathWithResponse:response];//返回路径
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        //new add
        if (weakSelf.isDownloadGpsInfo) {
            
            NSString *gpsInfo = [NSString stringWithContentsOfURL:filePath encoding:NSUTF8StringEncoding error:nil];
            
            [weakSelf.handleGpsInfoTool handleGpsInfoData:gpsInfo andCompleteBlock:^(NSArray * _Nonnull gpsDataArray) {
                
                weakSelf.gpsDataArray = [NSMutableArray arrayWithArray:gpsDataArray];
                [weakSelf saveFile:weakSelf.downloadDvrFileDataArr[0] withUrl:weakSelf.downloadDvrFileDataArr[1] isVidioEdit:[weakSelf.downloadDvrFileDataArr[2] boolValue]];
            }];
            
        }else
        {
            [weakSelf handleDownloadResultWithFilePath:filePath error:error];
        }
    }];
    
    [task resume];
    self.downloadTask = task;
}


-(NSString *)replaceRWithF:(NSString*)RString
{
    NSString *returnStr = @"";
    NSArray *arr = [RString componentsSeparatedByString:@"/"];
    
    NSString *ArrLastStr = arr.lastObject;
    NSString *str1 = [ArrLastStr substringToIndex:12];
    NSString *str2 = [ArrLastStr substringFromIndex:12];
    NSString *str3 = [str2 stringByReplacingOccurrencesOfString:@"R" withString:@"F"];
    NSString *lastStr = [NSString stringWithFormat:@"%@%@",str1,str3];
    
    returnStr = [NSString stringWithFormat:@"/%@/%@/F/%@",arr[1],arr[2],lastStr];
    
    return returnStr;
}

#pragma mark - public method

- (void)downloadShareFile:(APKDVRFile *)file progressHandler:(APKDownloadDVRFileProgressHandler)progressHandler completionHandler:(APKDownloadShareFileCompletionHandler)completionHandler{
    
    self.shareFile = file;
    self.shareTaskCompletionHandler = completionHandler;
    self.shareTaskProgressHandler = progressHandler;
    
    if (self.downloadType == kAPKDownloadTaskTypeNone) {
        
        [self performDownloadTask];
    }
}

- (void)savePhoto:(APKDVRFile *)file image:(UIImage *)image isCollected:(BOOL)isCollected isRearCameraFile:(BOOL)isRearCameraFile completionHandler:(APKDownloadDVRFileCompletionHandler)completionHandler{
    
    __weak typeof(self)weakSelf = self;
    [APKPhotosTool saveImage:image successBlock:^(NSString *identifier) {
        
        [weakSelf.context performBlock:^{
            
            DVRFile *dvrFile = dvrFile = [DVRFile getDVRFileWithName:file.name type:file.type context:weakSelf.context];
            if (!dvrFile) {
                dvrFile = [DVRFile createDVRFileWithFile:file context:weakSelf.context];
            }
            [LocalFile createWithFile:dvrFile fileDate:file.date identifier:identifier isCollected:isCollected isRearCameraFile:isRearCameraFile gpsData:@[] context:weakSelf.context];
            [weakSelf.context save:nil];
            file.isDownloaded = YES;
            completionHandler(@[]);
        }];
        
    } failureBlock:^(NSError *error) {
       
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(@[file]);
        });
    }];
}

- (void)cancelDownloadTask{
    
    self.isCancelled = YES;
    [self.downloadTask cancel];
}

- (void)addDownloadTask:(NSArray *)fileArray isCollected:(BOOL)isCollected isRearCameraFile:(BOOL)isRearCameraFile updateHandler:(APKDownloadDVRFileUpdateHandler)updateHandler progressHandler:(APKDownloadDVRFileProgressHandler)progressHandler completionHandler:(APKDownloadDVRFileCompletionHandler)completionHandler{
    
    [self.failureNormalTaskArray removeAllObjects];
    if (fileArray.count == 0) {
        completionHandler(self.failureNormalTaskArray);
    }
    
    [self.normalTaskArray setArray:fileArray];
    self.isCollected = isCollected;
    self.isCancelled = NO;
    self.isRearCameraFile = isRearCameraFile;
    self.normalTaskUpdateHandler = updateHandler;
    self.normalTaskProgressHandler = progressHandler;
    self.normalTaskCompletionHandler = completionHandler;
    
    if (self.downloadType == kAPKDownloadTaskTypeNone) {
        
        [self performDownloadTask];
    }
}

- (void)addPreviewPhotoTask:(APKDVRFile *)file{
    
    NSAssert(self.downloadPreviewPhotoCompletionHandler, @"未设置下载预览照片成功的block");
    
    if ([self.previewPhotoTaskArray containsObject:file]) return;
    if (self.previewPhotoTaskArray.count == 2) {
        
        [self.previewPhotoTaskArray removeObjectAtIndex:1];
    }
    [self.previewPhotoTaskArray addObject:file];
    
    if (self.downloadType == kAPKDownloadTaskTypeNone) {
        
        [self performDownloadTask];
    }
}

//- (void)collect:(NSArray *)fileArray completionHandler:(APKCollectDVRFileCompletionHandler)completionHandler{
//    
//    __weak typeof(self)weakSelf = self;
//   [self.context performBlock:^{
//      
//       for (APKDVRFile *file in fileArray) {
//           
//           if (file.isDownloaded && !file.isCollected) {
//               
//               LocalFile *localFile = [LocalFile getLocalFileWithName:file.name context:weakSelf.context];
//               localFile.isCollected = YES;
//               file.isCollected = YES;
//           }
//       }
//       
//       [weakSelf.context save:nil];
//       completionHandler();
//   }];
//}

- (void)downloadThumbnailWithFileArray:(NSArray *)fileArray completionHandler:(APKDownloadDVRFileThumbnailCompletionHandler)completionHandler{
    
    if (fileArray.count == 0) {
        
        completionHandler();
        return;
    }
    
    self.thumbnailTaskCompletionHandler = completionHandler;
    [self.thumbnailTaskArray setArray:fileArray];
    [self.successThumbnailTaskArray removeAllObjects];
    
    if (self.downloadType == kAPKDownloadTaskTypeNone) {
        
        [self performDownloadTask];
    }
}

@end
