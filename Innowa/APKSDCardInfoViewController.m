//
//  APKSDCardInfoViewController.m
//  Innowa
//
//  Created by Mac on 17/5/12.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKSDCardInfoViewController.h"
#import "APKProgressView.h"
#import "APKGetDVRSDCardInfoTool.h"

@interface APKSDCardInfoViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *photoLabel;
@property (weak, nonatomic) IBOutlet UILabel *photoUsedLabel;
@property (weak, nonatomic) IBOutlet APKProgressView *photoProgressView;
@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventUsedLabel;
@property (weak, nonatomic) IBOutlet APKProgressView *eventProgressView;
@property (weak, nonatomic) IBOutlet UILabel *videoLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoUsedLabel;
@property (weak, nonatomic) IBOutlet APKProgressView *videoProgressView;
@property (weak, nonatomic) IBOutlet APKProgressView *parkingEventProgressView;
@property (weak, nonatomic) IBOutlet APKProgressView *parkingTimeProgressView;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *nameLabelArray;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *valueLabelArray;
@property (weak, nonatomic) IBOutlet UIView *parkingEventView;
@property (weak, nonatomic) IBOutlet UIView *parkingTimeView;

@property (weak, nonatomic) IBOutlet APKProgressView *progressViewArray;

@property (weak, nonatomic) IBOutlet UILabel *sdCapacityL;
@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (strong,nonatomic) APKGetDVRSDCardInfoTool *getSDCardInfoTool;

@end

@implementation APKSDCardInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = NSLocalizedString(@"设置", nil);
    self.subTitleLabel.text = NSLocalizedString(@"SD卡状态", nil);
    
    self.photoLabel.text = NSLocalizedString(@"照片" , nil);
    self.photoUsedLabel.text = @"0.00GB/0.00GB";
    
    self.eventLabel.text = NSLocalizedString(@"事件" , nil);
    self.eventUsedLabel.text = @"0.00GB/0.00GB";
    
    self.videoLabel.text = NSLocalizedString(@"视频" , nil);
    self.videoUsedLabel.text = @"0.00GB/0.00GB";
    
    for (int i = 0;i < self.nameLabelArray.count;i++) {
        
        UILabel *l = self.nameLabelArray[i];
        switch (i) {
            case 0:
                l.text = NSLocalizedString(@"泊车模式事件", nil);
                break;
            default:
                l.text = NSLocalizedString(@"缩时录影", nil);
                break;
        }
    }
    
//    self.totalLabel.text = [NSString stringWithFormat:NSLocalizedString(@"SD卡容量：%.2fGB", nil),0.f];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    __weak typeof(self)weakSelf = self;
    [self.getSDCardInfoTool getSDCardInfoWithCompletionHandler:^(BOOL success, APKSDCardInfo *sdCardInfo) {
       
        if (!success) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
           
            self.sdCapacityL.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"SD卡容量", nil),sdCardInfo.totalSpace];
            
            weakSelf.totalLabel.text = [NSString stringWithFormat:NSLocalizedString(@"SD卡容量：%.2fGB", nil),sdCardInfo.totalSpace];
        
            float usedPhotoSpace = sdCardInfo.totalPhotoSpace - sdCardInfo.freePhotoSpace;
            weakSelf.photoUsedLabel.text = [NSString stringWithFormat:@"%@/%@",[self changeMBWithGB:usedPhotoSpace],[self changeMBWithGB:sdCardInfo.freePhotoSpace]];
            
            float usedVideoSpace = sdCardInfo.totalVideoSpace - sdCardInfo.freeVideoSpace;
            weakSelf.videoUsedLabel.text = [NSString stringWithFormat:@"%@/%@",[self changeMBWithGB:usedVideoSpace],[self changeMBWithGB:sdCardInfo.freeVideoSpace]];

            float usedEventSpace = sdCardInfo.totalEventSpace - sdCardInfo.freeEventSpace;
            weakSelf.eventUsedLabel.text = [NSString stringWithFormat:@"%@/%@",[self changeMBWithGB:usedEventSpace],[self changeMBWithGB:sdCardInfo.freeEventSpace]];
            
            float usedParkingSpace = sdCardInfo.parkingEventTotalSpace - sdCardInfo.parkingEventfreeSpace;
            UILabel *l = self.valueLabelArray[0];
            l.text = [NSString stringWithFormat:@"%@/%@",[self changeMBWithGB:usedParkingSpace],[self changeMBWithGB:sdCardInfo.parkingEventfreeSpace]];

            float usedParkingTimeSpace = sdCardInfo.parkingTimeTotalSpace - sdCardInfo.parkingTimeFreeSpace;
            UILabel *l2 = self.valueLabelArray[1];
            l2.text = [NSString stringWithFormat:@"%@/%@",[self changeMBWithGB:usedParkingTimeSpace],[self changeMBWithGB:sdCardInfo.parkingTimeFreeSpace]];
        
            weakSelf.photoProgressView.progress = sdCardInfo.totalPhotoSpace != 0 ? usedPhotoSpace / sdCardInfo.totalPhotoSpace : 0;
            weakSelf.eventProgressView.progress = sdCardInfo.totalEventSpace != 0 ? usedEventSpace / sdCardInfo.totalEventSpace : 0;
            weakSelf.videoProgressView.progress = sdCardInfo.totalVideoSpace != 0 ? usedVideoSpace / sdCardInfo.totalVideoSpace : 0;
            weakSelf.parkingEventProgressView.progress = sdCardInfo.parkingEventTotalSpace == 0 ? 0 : usedParkingSpace / sdCardInfo.parkingEventTotalSpace;
            weakSelf.parkingTimeProgressView.progress = sdCardInfo.parkingTimeTotalSpace == 0 ? 0 : usedParkingTimeSpace / sdCardInfo.parkingTimeTotalSpace;
            
            weakSelf.parkingEventView.hidden = sdCardInfo.parkingEventTotalSpace == 0 ? YES : NO;
            weakSelf.parkingTimeView.hidden = sdCardInfo.parkingTimeTotalSpace == 0 ? YES : NO;
            
            if (weakSelf.parkingTimeView.hidden == YES)
                weakSelf.photoView.frame = weakSelf.parkingEventView.frame;
            
            
            if (weakSelf.parkingTimeView.hidden == YES) {
                
                weakSelf.sdCapacityL.frame = CGRectMake(CGRectGetMinX(weakSelf.sdCapacityL.frame), CGRectGetMaxY(weakSelf.photoView.frame) + 50, CGRectGetWidth(weakSelf.sdCapacityL.frame), CGRectGetHeight(weakSelf.sdCapacityL.frame));
            }
        });
    }];
}

-(NSString *)changeMBWithGB:(float)space
{
    NSString *spaceStr = @"";
    if (space/1024 >= 1) {
        float used = space/1024;
        spaceStr = [NSString stringWithFormat:@"%.1fGB",used];
    }else{
        spaceStr = [NSString stringWithFormat:@"%.fMB",space];
    }
    return spaceStr;
}

- (APKGetDVRSDCardInfoTool *)getSDCardInfoTool{
    
    if (!_getSDCardInfoTool) {
        _getSDCardInfoTool = [[APKGetDVRSDCardInfoTool alloc] init];
    }
    return _getSDCardInfoTool;
}

- (IBAction)quit:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
