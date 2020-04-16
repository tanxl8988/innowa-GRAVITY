//
//  DVRFile.h
//  万能AIT
//
//  Created by Mac on 17/3/23.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "APKDVRFile.h"

@class LocalFile;
@interface DVRFile : NSManagedObject

@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSString *thumbnailPath;
@property (assign) int16_t type;
@property (strong,nonatomic) LocalFile *localFile;

+ (DVRFile *)getDVRFileWithName:(NSString *)name type:(int16_t)type context:(NSManagedObjectContext *)context;
+ (DVRFile *)createDVRFileWithFile:(APKDVRFile *)file context:(NSManagedObjectContext *)context;

@end
