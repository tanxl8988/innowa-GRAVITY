//
//  CoreDataStackGenerator.m
//  东风项目
//
//  Created by Mac on 16/12/12.
//  Copyright © 2016年 APK. All rights reserved.
//

#import "CoreDataStack.h"

@implementation CoreDataStack


+ (void)generateCoreDataStack:(void (^)(NSManagedObjectContext *))completeBlock{
    
    NSURL *momUrl = [[NSBundle mainBundle] URLForResource:@"DataModal" withExtension:@"momd"];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:momUrl];
    NSAssert(mom, @"create mom failure");
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    context.persistentStoreCoordinator = psc;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *psUrl = [documentsDirectory URLByAppendingPathComponent:@"database.sqlite"];
        
        NSError *error;
        [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:psUrl options:nil error:&error];
        NSAssert(!error, error.description);
        
        completeBlock(context);
    });

}

@end
