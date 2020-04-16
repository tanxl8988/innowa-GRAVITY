//
//  APKDeleteDVRFileTool.h
//  万能AIT
//
//  Created by Mac on 17/3/24.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "APKDVRFile.h"

typedef void(^APKDeleteDVRFileCompletionHandler)(NSArray *failureTaskArray);

@interface APKDeleteDVRFileTool : NSObject

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)context;
- (void)deleteWithFileArray:(NSArray <APKDVRFile *> *)fileArray completionHandler:(APKDeleteDVRFileCompletionHandler)completionHandler;

@end
