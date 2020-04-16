//
//  LocalFile.m
//  万能AIT
//
//  Created by Mac on 17/3/23.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "LocalFile.h"
#import "DVRFile.h"

@implementation LocalFile

@dynamic isCollected,dvrFile,name,identifier,type,saveDate,isFromRearCamera,gpsDataStr;

+ (LocalFile *)createWithFile:(DVRFile *)dvrFile fileDate:(NSDate *)fileDate identifier:(NSString *)identifier isCollected:(BOOL)isCollected isRearCameraFile:(BOOL)isRearCameraFile gpsData:(NSArray*)gpsArray context:(NSManagedObjectContext *)context{
    
    LocalFile *file = [NSEntityDescription insertNewObjectForEntityForName:@"LocalFile" inManagedObjectContext:context];
    file.name = dvrFile.name;
    file.type = dvrFile.type;
    file.identifier = identifier;
    file.isCollected = isCollected;
    file.isFromRearCamera = isRearCameraFile;
    file.dvrFile = dvrFile;
    file.saveDate = fileDate;
    if (gpsArray.count > 0) {//new add
     file.gpsDataStr = [self transformArrayToString:gpsArray];
        NSLog(@"localDvrGpsInfo:%@",file.gpsDataStr);
    }
    return file;
}

+(NSString*)transformArrayToString:(NSArray*)arr
{
    NSMutableString *gpsDataStr = [NSMutableString string];
    for (NSArray *pointArray in arr) {
        
        if (pointArray == arr.lastObject) {
           
            [gpsDataStr appendString:pointArray[0]];
            [gpsDataStr appendString:@","];
            [gpsDataStr appendString:pointArray[1]];
            return gpsDataStr;;
        }
        
        [gpsDataStr appendString:pointArray[0]];
        [gpsDataStr appendString:@","];
        [gpsDataStr appendString:pointArray[1]];
        [gpsDataStr appendString:@"/"];
    }
    
    return gpsDataStr;
}

+ (NSArray *)getLocalFilesWithType:(APKDVRFileType)type isFromRearCamera:(BOOL)isFromRearCamera context:(NSManagedObjectContext *)context{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %d AND isFromRearCamera == %d",(int16_t)type,isFromRearCamera];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"LocalFile"];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *fileArray = [context executeFetchRequest:request error:&error];
    NSAssert(!error, error.localizedDescription);
    
    return fileArray;
}

//+ (NSArray *)getLocalFilesWithType:(APKDVRFileType)type context:(NSManagedObjectContext *)context{
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %d",(int16_t)type];
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"LocalFile"];
//    [request setPredicate:predicate];
//    NSError *error;
//    NSArray *fileArray = [context executeFetchRequest:request error:&error];
//    NSAssert(!error, error.localizedDescription);
//    
//    return fileArray;
//}


+ (NSArray *)getCollectFilesWithContext:(NSManagedObjectContext *)context{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isCollected == YES"];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"LocalFile"];
    [request setPredicate:predicate];
    NSError *error;
    NSArray *fileArray = [context executeFetchRequest:request error:&error];
    NSAssert(!error, error.localizedDescription);
    
    return fileArray;
}

+ (NSArray *)getAllLocalFilesWithContext:(NSManagedObjectContext *)context{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"LocalFile"];
    NSArray *fileArray = [context executeFetchRequest:request error:nil];
    return fileArray;
}

+ (LocalFile *)getLocalFileWithName:(NSString *)name context:(NSManagedObjectContext *)context{
    
    NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"%K == %@",@"name",name];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"LocalFile"];
    [request setPredicate:namePredicate];
    NSError *error;
    NSArray *fileArray = [context executeFetchRequest:request error:&error];
    LocalFile *file = nil;
    if (!error && fileArray.count > 0) {
        file = fileArray.firstObject;
    }
    
    return file;
}


@end
