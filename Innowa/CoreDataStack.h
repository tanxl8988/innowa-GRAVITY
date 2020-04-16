//
//  CoreDataStackGenerator.h
//  东风项目
//
//  Created by Mac on 16/12/12.
//  Copyright © 2016年 APK. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface CoreDataStack : NSObject

+ (void)generateCoreDataStack:(void(^)(NSManagedObjectContext *context))completeBlock;

@end
