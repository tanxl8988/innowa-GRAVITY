//
//  APKGetFileListTool.h
//  Innowa
//
//  Created by Mac on 17/7/4.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APKDVRFile.h"
#import <CoreData/CoreData.h>

typedef void(^APKGetFileListCompletionHandler)(BOOL success,NSArray *fileArray);

@interface APKGetFileListTool : NSObject

+ toolWithFileType:(APKDVRFileType)fileType isRearCameraFile:(BOOL)isRearCameraFile context:(NSManagedObjectContext *)context completionHandler:(APKGetFileListCompletionHandler)completionHandler;
- (void)getFileList;

@end
