//
//  APKBaseViewController.h
//  保时捷项目
//
//  Created by Mac on 16/4/21.
//
//

#import <UIKit/UIKit.h>

@interface APKBaseViewController : UIViewController
@property (nonatomic,retain) NSMutableArray *dataArray;
- (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2;//判断是不是同一天
-(void)combinData:(NSArray*)arr isBackScheduling:(BOOL)isBackScheduling; //合并相同日期数据,判断是否倒序
-(void)combinDVRData:(NSArray*)arr;
-(void)combinDVRDataWithGoup:(NSArray*)arr;

-(void)refleshData:(NSMutableArray*)array;
-(UILabel*)setDetailtimeL:(NSIndexPath*)indexPath;
-(UILabel*)setDVRDetailtimeL:(NSIndexPath*)indexPath;
-(NSMutableArray*)getAllFileArray:(NSArray*)indexPaths;//获得成对的视频文件
-(int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay;
-(NSMutableArray *)changeFAndRFile:(NSArray *)sortArr;
-(NSArray *)sortFileWithdate:(NSArray *)fileArr;

@end
