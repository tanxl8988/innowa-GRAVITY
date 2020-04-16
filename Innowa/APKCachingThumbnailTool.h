//
//  APKCachingThumbnailTool.h
//  Innowa
//
//  Created by Mac on 17/5/4.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>


@interface APKCachingThumbnailTool : NSObject

- (instancetype)initWithThumbNailSize:(CGSize)thumbnailSize;
- (void)startCachingWithAssets:(NSArray <PHAsset *>*)assets;
- (void)stopCaching;
- (void)requestThumbnailForAsset:(PHAsset *)asset resultHandler:(void (^)(UIImage *thumbnail))resultHandler;
- (void)getVidioAsset:(PHAsset*)asset resultHandler:(void (^)(NSString *url))resultHandler;

@end
