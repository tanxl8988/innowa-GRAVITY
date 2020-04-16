//
//  APKCachingThumbnailTool.m
//  Innowa
//
//  Created by Mac on 17/5/4.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKCachingThumbnailTool.h"

@interface APKCachingThumbnailTool ()

@property (strong,nonatomic) PHCachingImageManager *cachingManager;
@property (strong,nonatomic) PHImageRequestOptions *options;
@property (assign) CGSize thumbnailSize;
@property (assign) PHImageContentMode contentMode;

@end

@implementation APKCachingThumbnailTool

#pragma mark - life circle

- (instancetype)initWithThumbNailSize:(CGSize)thumbnailSize{
    
    if (self = [super init]) {
        
        self.thumbnailSize = thumbnailSize;
        self.contentMode = PHImageContentModeAspectFit;
    }
    
    return self;
}

#pragma mark - getter

- (PHCachingImageManager *)cachingManager{
    
    if (!_cachingManager) {
        _cachingManager = [[PHCachingImageManager alloc] init];
    }
    return _cachingManager;
}

- (PHImageRequestOptions *)options{
    
    if (!_options) {
        _options = [[PHImageRequestOptions alloc] init];
        _options.synchronous = NO;
        _options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        _options.resizeMode = PHImageRequestOptionsResizeModeFast;
    }
    
    return _options;
}

#pragma mark - public method

- (void)startCachingWithAssets:(NSArray <PHAsset *>*)assets{
    
    [self.cachingManager startCachingImagesForAssets:assets targetSize:self.thumbnailSize contentMode:self.contentMode options:self.options];
}

- (void)stopCaching{
    
    [self.cachingManager stopCachingImagesForAllAssets];
}

- (void)requestThumbnailForAsset:(PHAsset *)asset resultHandler:(void (^)(UIImage *thumbnail))resultHandler{
    
    [self.cachingManager requestImageForAsset:asset targetSize:self.thumbnailSize contentMode:self.contentMode options:self.options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        resultHandler(result);
    }];
}

-(void)getVidioAsset:(PHAsset *)asset resultHandler:(void (^)(NSString *))resultHandler
{
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        
        NSString * sandboxExtensionTokenKey = info[@"PHImageFileSandboxExtensionTokenKey"];
        NSArray * arr = [sandboxExtensionTokenKey componentsSeparatedByString:@";"];
//        NSString * filePath = [arr[arr.count - 1] substringFromIndex:9];
        NSString * filePath = arr[arr.count - 1];
        resultHandler(filePath);
    }];
}

@end
