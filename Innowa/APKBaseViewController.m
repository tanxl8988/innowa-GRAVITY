//
//  APKBaseViewController.m
//  保时捷项目
//
//  Created by Mac on 16/4/21.
//
//

#import "APKBaseViewController.h"
#import "LocalFile.h"

@interface APKBaseViewController ()

@end

@implementation APKBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

//- (BOOL)shouldAutorotate{
//    
//    return NO;
//}

- (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}


-(void)combinData:(NSArray*)arr isBackScheduling:(BOOL)isBackScheduling
{
    if (arr.count == 0) {
        return;
    }
    
    NSArray *timeSortortArr = [self sortLocalFileWithdate:arr isBackSchedulling:isBackScheduling];
    NSMutableArray *nameSortArr = [self changeLocalFileFAndRFile:timeSortortArr];
    
    if (arr.count == 0) return;
    if (self.dataArray.count > 0) [self.dataArray removeAllObjects];
    
    NSArray *souceData = [NSArray arrayWithArray:nameSortArr];
    for (int i = 0;i < souceData.count; i++) {
        
        LocalFile *thisFile = souceData[i];
        NSMutableArray *newArray = [NSMutableArray array];
        [newArray addObject:thisFile];
        
        if (i == 0) [self.dataArray addObject:newArray];
        else
        {
            NSMutableArray *compareFileArray = self.dataArray.lastObject;
            LocalFile *compareFile = compareFileArray.firstObject;
            bool isSameDay = [self isSameDay:thisFile.saveDate date2:compareFile.saveDate];
            
            if (isSameDay)[compareFileArray addObject:thisFile];
            else [self.dataArray addObject:newArray];
        }
    }
}

-(void)combinDVRData:(NSArray*)arr//合并同一天的视频
{
    
    NSArray *timeSortortArr = [self sortFileWithdate:arr];
    
    NSMutableArray *nameSortArr = [self changeFAndRFile:timeSortortArr];
    
    NSArray *souceData = [NSArray arrayWithArray:nameSortArr];
    
    for (int i = 0;i < souceData.count; i++) {
        
        APKDVRFile *thisFile = souceData[i];
        
        NSMutableArray *newArray = [NSMutableArray array];
        [newArray addObject:thisFile];
        
        if (i == 0)
            
            [self.dataArray addObject:newArray];
        else
        {
            NSMutableArray *compareFileArray = self.dataArray.lastObject;
            APKDVRFile *compareFile = compareFileArray.firstObject;
            bool isSameDay = [self isSameDay:thisFile.date date2:compareFile.date];
            
            if (isSameDay) [compareFileArray addObject:thisFile];
            else
                [self.dataArray addObject:newArray];
        }
        
    }
    
}

-(NSArray *)sortFileWithdate:(NSArray *)fileArr
{
   NSArray *sortArr = [fileArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        APKDVRFile *file1 = obj1;
        APKDVRFile *file2 = obj2;
        return [file2.date compare:file1.date];
    }];
    
    return sortArr;
}

-(NSArray *)sortLocalFileWithdate:(NSArray *)fileArr isBackSchedulling:(BOOL)isBackSchedulling
{
    NSArray *sortArr = [fileArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        LocalFile *file1 = obj1;
        LocalFile *file2 = obj2;
        if (isBackSchedulling)
            return [file1.saveDate compare:file2.saveDate];
        else
            return [file2.saveDate compare:file1.saveDate];
    }];
    
    return sortArr;
}

-(NSMutableArray *)changeFAndRFile:(NSArray *)sortArr
{
    if (sortArr.count == 0) return (NSMutableArray*)sortArr;
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:sortArr];
    for (int i = 0;i < sortArr.count - 1; i++) {
        APKDVRFile *file1 = arr[i];
        APKDVRFile *file2 = arr[i + 1];
        
        int sameTime = [self compareOneDay:file1.date withAnotherDay:file2.date];
        if (sameTime == 1 && [file2.name containsString:@"F."]) {
            
            [arr replaceObjectAtIndex:i withObject:file2];
            [arr replaceObjectAtIndex:i+1 withObject:file1];
            
        }
    }
    return arr;
}


-(NSMutableArray *)changeLocalFileFAndRFile:(NSArray *)sortArr
{
    NSMutableArray *arr = [NSMutableArray arrayWithArray:sortArr];
    for (int i = 0;i < sortArr.count - 1; i++) {
        LocalFile *file1 = arr[i];
        LocalFile *file2 = arr[i + 1];
        
        int sameTime = [self compareOneDay:file1.saveDate withAnotherDay:file2.saveDate];
        if (sameTime == 1 && [file2.name containsString:@"F."]) {
            
            [arr replaceObjectAtIndex:i withObject:file2];
            [arr replaceObjectAtIndex:i+1 withObject:file1];
            
        }
    }
    return arr;
}

-(void)combinDVRDataWithGoup:(NSArray *)arr//合并相隔一分钟的视频
{
    NSArray *timeSortArr = [self sortFileWithdate:arr];
    
    NSMutableArray *nameSortArr = [self changeFAndRFile:timeSortArr];
    
    NSArray *souceData = [NSArray arrayWithArray:nameSortArr];
    
    for (int i = 0;i < souceData.count; i++) {
        
        APKDVRFile *thisFile = souceData[i];
        
        NSMutableArray *newArray = [NSMutableArray array];
        [newArray addObject:thisFile];
        
        if (i == 0) {
            
            [self.dataArray addObject:newArray];
        }
        else
        {
            NSMutableArray *compareFileArray = self.dataArray.lastObject;
            APKDVRFile *compareFile = compareFileArray.lastObject;
            NSTimeInterval start = [thisFile.date timeIntervalSince1970]*1;
            NSTimeInterval end = [compareFile.date timeIntervalSince1970]*1;
            
            int interval = end - start;
            NSLog(@"DVR File time interval: %d",interval);
            
            if (interval < 60) [compareFileArray addObject:thisFile];
            else
                [self.dataArray addObject:newArray];
        }
    }
}



-(int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay
{
    NSComparisonResult result = [oneDay compare:anotherDay];
    NSLog(@"date1 : %@, date2 : %@", oneDay, anotherDay);
    if (result == NSOrderedSame) {
        //NSLog(@"Date1  is in the future");
        return 1;
    }
    else if (result == NSOrderedAscending){
        //NSLog(@"Date1 is in the past");
        return -1;
    }
    //NSLog(@"Both dates are the same");
    return 0;
}


//刷新数据
-(void)refleshData:(NSMutableArray*)deleteFileArray
{
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.dataArray];
    
    //*********清除删除数据**********
    for (NSMutableArray *array in self.dataArray) {
        
        for (LocalFile *file in deleteFileArray) {
            
            if ([array containsObject:file]) {
                
                [array removeObject:file];
            }
        }
        
    }
    
    //*********清除空数组**********(warn:数组不能遍历时同时修改)
    for (NSMutableArray *array in tempArray) {
        
        if (array.count == 0) {
            [self.dataArray removeObject:array];
        }
        
    }
    
}

-(UILabel*)setDetailtimeL:(NSIndexPath*)indexPath
{
    UILabel *detailTime = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 220, 0, 200, 20)];
    
    detailTime.textAlignment = NSTextAlignmentRight;
    
    NSMutableArray *timeArray = [NSMutableArray array];
    
    for (LocalFile *file in self.dataArray[indexPath.section]) {
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];//将日期转化为字符串
        [df setDateFormat:@"hh:mm:ss"];
        NSString * s1 = [df stringFromDate:file.saveDate];
        
        if (s1) {
            [timeArray addObject:s1];
        }
        
        
    }
    
    detailTime.text = timeArray.count == 1 ? timeArray.firstObject : [NSString stringWithFormat:@"%@ ~ %@",timeArray.lastObject,timeArray.firstObject];
    
    return detailTime;
}

-(UILabel*)setDVRDetailtimeL:(NSIndexPath*)indexPath
{
    UILabel *detailTime = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 200, 20)];
    
    detailTime.textAlignment = NSTextAlignmentRight;
    
    detailTime.textColor = [UIColor whiteColor];
    
    NSMutableArray *timeArray = [NSMutableArray array];
    
    for (APKDVRFile *file in self.dataArray[indexPath.section]) {
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];//将日期转化为字符串
        [df setDateFormat:@"hh:mm:ss"];
        NSString * s1 = [df stringFromDate:file.date];
        
        if (s1) {
            [timeArray addObject:s1];
        }
        
        
    }
    
    detailTime.text = timeArray.count == 1 ? timeArray.firstObject : [NSString stringWithFormat:@"%@ ~ %@",timeArray.lastObject,timeArray.firstObject];
    
    return detailTime;
}

-(NSMutableArray*)getAllFileArray:(NSArray*)indexPaths
{
    NSMutableArray *fileArray = [NSMutableArray array];
    
    for (NSIndexPath *indexPath in indexPaths) {
        
        if (indexPath.row % 2 == 0) {
            
            [self addSelfToDownloadList:indexPath arr:fileArray];
//            NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
//            if (![indexPaths containsObject:nextIndexPath]) {
//
//                APKDVRFile *file = self.dataArray[indexPath.section][indexPath.row+1];
//                if (!file.isDownloaded) {
//                    [fileArray addObject:file];
//                }
//            }
        }else
        {
//            NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
//            if (![indexPaths containsObject:lastIndexPath]) {
//                
//                APKDVRFile *file = self.dataArray[indexPath.section][indexPath.row-1];
//                if (!file.isDownloaded) {
//                    [fileArray addObject:file];
//                }
//            }
            [self addSelfToDownloadList:indexPath arr:fileArray];
        }
    }
    
    return fileArray;
}

-(void)addSelfToDownloadList:(NSIndexPath*)indexPath arr:(NSMutableArray*)fileArray
{
    APKDVRFile *file = self.dataArray[indexPath.section][indexPath.row];
    if (!file.isDownloaded) {
        [fileArray addObject:file];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{

    return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleLightContent;
}

-(NSMutableArray*)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    
    return _dataArray;
}

@end
