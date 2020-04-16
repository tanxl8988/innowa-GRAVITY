//
//  APKRequestDVRFileTool.h
//  万能AIT
//
//  Created by Mac on 17/3/23.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APKDVRFile.h"
#import <CoreData/CoreData.h>

typedef void(^APKRequestDVRFileSuccessBlock)(NSArray<APKDVRFile *> *fileArray);
typedef void(^APKRequestDVRFileFailureBlock)(void);

@interface APKRequestDVRFileTool : NSObject

@property (nonatomic,assign) BOOL isRequestAll;

- (instancetype)initWithFileType:(APKDVRFileType)fileType isRearCameraFile:(BOOL)isRearCameraFile managedObjectContext:(NSManagedObjectContext *)context;
- (void)requestDVRFileWithCount:(NSInteger)count fromIndex:(NSInteger)index successBlock:(APKRequestDVRFileSuccessBlock)successBlock failureBlock:(APKRequestDVRFileFailureBlock)failureBlock;

@end
