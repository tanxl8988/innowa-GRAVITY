//
//  DVRFile.m
//  万能AIT
//
//  Created by Mac on 17/3/23.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "DVRFile.h"

@implementation DVRFile
@dynamic name,type,thumbnailPath,localFile;

+ (DVRFile *)createDVRFileWithFile:(APKDVRFile *)file context:(NSManagedObjectContext *)context{
    
    DVRFile *dvrFile = [NSEntityDescription insertNewObjectForEntityForName:@"DVRFile" inManagedObjectContext:context];
    dvrFile.name = file.name;
    dvrFile.type = file.type;
    dvrFile.thumbnailPath = file.thumbnailPath;
    return dvrFile;
}

+ (DVRFile *)getDVRFileWithName:(NSString *)name type:(int16_t)type context:(NSManagedObjectContext *)context{
    
    NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"name == %@ AND type == %d",name,type];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"DVRFile"];
    [request setPredicate:namePredicate];
    NSError *error;
    NSArray *fileArray = [context executeFetchRequest:request error:&error];
    DVRFile *file = nil;
    if (!error && fileArray.count > 0) {
        file = fileArray.firstObject;
    }
    
    return file;
}

@end
