//
//  APKHandleGpsInfoTool.m
//  Innowa
//
//  Created by apical on 2018/10/30.
//  Copyright © 2018年 APK. All rights reserved.
//

#import "APKHandleGpsInfoTool.h"
#import "DVRFile.h"
#import <UIKit/UIKit.h>

@implementation APKHandleGpsInfoTool


-(void)handleGpsInfoData:(NSString *)nmeaDataStr andCompleteBlock:(void (^)(NSArray * _Nonnull))completeBlock
{
    NSMutableArray *allGpsArray = [NSMutableArray array];
    NSArray *allDataArray = [nmeaDataStr componentsSeparatedByString:@"$"];
    for (NSString *str in allDataArray) {
        
        if ([str containsString:@"GPGGA"]) {
            
            NSArray *validDataArray = [str componentsSeparatedByString:@","];
            
            NSMutableArray *onePointArray = [NSMutableArray array];
            [onePointArray addObject:validDataArray[2]];
            [onePointArray addObject:validDataArray[4]];
            
            [allGpsArray addObject:onePointArray];
        }
    }
    completeBlock(allGpsArray);
    
}

+(NSArray *)transformGpsInfoFromStringToArr:(NSString *)gpsStr
{
    NSMutableArray *gpsInfoArray = [NSMutableArray array];
    
    NSArray *allPointArray = [gpsStr componentsSeparatedByString:@"/"];
    for (NSString *pointStr in allPointArray) {
        
        NSMutableArray *pointArray = [NSMutableArray array];
        NSArray *point = [pointStr componentsSeparatedByString:@","];
            
        NSString *longtitudeStr = [self transformNmeaDataToGpsPoint:point[0]];
        NSString *latitudeStr = [self transformNmeaDataToGpsPoint:point[1]];
        [pointArray addObject:longtitudeStr];
        [pointArray addObject:latitudeStr];
        
        [gpsInfoArray addObject:pointArray];
    }
    
    return gpsInfoArray;
}

+(NSString*)transformNmeaDataToGpsPoint:(NSString*)nmeaData
{
    
    if (!nmeaData || [nmeaData isEqualToString:@""]) {
        
        return @"";
    }
    
    NSString *titudeStr = @"";
    
    NSRange range;
    NSRange range2;
    NSRange range3;
    if (nmeaData.length == 9) {
        
        range = NSMakeRange(0, 2);
        range2 = NSMakeRange(2, 2);
        range3 = NSMakeRange(5, 4);
    }else
    {
        range = NSMakeRange(0, 3);
        range2 = NSMakeRange(3, 2);
        range3 = NSMakeRange(6, 4);
    }
    
    titudeStr = [titudeStr stringByAppendingString:[nmeaData substringWithRange:range]];
    titudeStr = [titudeStr stringByAppendingString:@" "];
    titudeStr = [titudeStr stringByAppendingString:[nmeaData substringWithRange:range2]];
    titudeStr = [titudeStr stringByAppendingString:@" "];
    
    NSString *secondStr = [self getValidSecondStr:nmeaData range:range3];
    titudeStr = [titudeStr stringByAppendingString:secondStr];
    
    titudeStr = [self transformStrToGpsPoint:titudeStr];
    
    return titudeStr;
}


+(NSString*)getValidSecondStr:(NSString*)nmeaData range:(NSRange)range
{
    NSString *str = [nmeaData substringWithRange:range];
    NSString *secondStr = [NSString stringWithFormat:@"0.%@",str];
    CGFloat second = (CGFloat)[secondStr floatValue] * 60;
    NSString *validSecondstr = [NSString stringWithFormat:@"%f",second];
    
    return validSecondstr;
}

+(NSString*)transformStrToGpsPoint:(NSString*)str
{
    NSArray *arr = [str componentsSeparatedByString:@" "];
    
    CGFloat value = [(NSString*)arr[0] floatValue];
    CGFloat value2 = (CGFloat)[(NSString*)arr[1] floatValue]/60;
    CGFloat value3 = (CGFloat)[(NSString*)arr[2] floatValue]/3600;
    
    float allValue = value + value2 + value3;
    
    NSString *pointStr = [NSString stringWithFormat:@"%6f",allValue];
    return pointStr;
}


@end
