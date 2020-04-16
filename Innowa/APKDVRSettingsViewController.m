//
//  APKDVRSettingsViewController.m
//  Innowa
//
//  Created by Mac on 17/5/2.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKDVRSettingsViewController.h"
#import "APKNormalSettingCell.h"
#import "APKSwitchSettingCell.h"
#import "APKCheckBoxSettingCell.h"
#import "APKSettingItem.h"
#import "APKCommonTaskTool.h"
#import "APKDVR.h"
#import "APKAlertTool.h"
#import "MBProgressHUD.h"
#import "APKSettingsHeaderCell.h"
#import "APKSettingItemsView.h"
#import "APKTextSettingCell.h"
#import "AppDelegate.h"
#import "APKCustomTabBarController.h"
#import "settingHeadView.h"
#import "AFNetworking.h"
#import "APKFunctionTool.h"
#import "APKCommonTaskTool.h"
//#import "APKSpecialSettingsTool.h"

static NSString *identifier1 = @"normalSettingCell";
static NSString *identifier2 = @"switchSettingCell";
static NSString *identifier3 = @"checkBoxSettingCell";
static NSString *identifier4 = @"textSettingCell";
static NSString *headerIdentifier = @"headerCell";

@interface APKDVRSettingsViewController ()<UITableViewDataSource,UITableViewDelegate,APKCheckBoxSettingCellDelegate,APKSwitchSettingCellDelegate,APKSettingItemsViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *dataSource;
@property (strong,nonatomic) APKCommonTaskTool *commonTaskTool;
@property (weak,nonatomic) UIAlertController *setDVRClockAlert;
@property (strong,nonatomic) APKSettingItem *targetItem;
@property (strong,nonatomic) APKSettingItem *speedLimitAlertItem;
@property (nonatomic,retain) NSMutableArray *rowNumberArray;
@property (nonatomic,retain) NSMutableArray *headImageArray;
@property (nonatomic,retain) APKCommonTaskTool *taskTool;
@property (assign) BOOL isParkingMode;
//@property (strong,nonatomic) APKSpecialSettingsTool *settingsTool;

@end

@implementation APKDVRSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = NSLocalizedString(@"设置", nil);
    self.tableView.rowHeight = 62;
    
    self.rowNumberArray = [NSMutableArray arrayWithArray:@[@[],@[],@[],@[],@[]]];
    
    [[APKDVR sharedInstance] addObserver:self forKeyPath:@"isConnected" options:NSKeyValueObservingOptionNew context:nil];
    
//    [self.taskTool setDVRWithProperty:@"Video" value:@"record" completionHandler:^(BOOL success) {
//    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnToFirstSetVC) name:@"returnToFirstSetVC" object:nil];
}

-(void)returnToFirstSetVC
{
    [self.navigationController popToViewController:self animated:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.taskTool getSettingsInfo:^(BOOL success) {
        
        [self refreshPage];
        [self.tableView reloadData];
        
    }];
//    if (self.dataSource.count > 0) {
//        NSIndexPath *voiceRecordIndex = [NSIndexPath indexPathForRow:4 inSection:0];
//        NSIndexPath *exposureIndex = [NSIndexPath indexPathForRow:11 inSection:0];
//        NSArray *indexArr = @[voiceRecordIndex];
//
//        [self.tableView reloadRowsAtIndexPaths:indexArr withRowAnimation:UITableViewRowAnimationNone];
//    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [[APKDVR sharedInstance] removeObserver:self forKeyPath:@"isConnected"];
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    KWEAKSELF;
    if ([keyPath isEqualToString:@"isConnected"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            APKDVR *dvr = [APKDVR sharedInstance];
            if (dvr.isConnected) {
                
                [weakSelf refreshPage];
            }
        });
    }
}

#pragma mark - getter

//- (APKSpecialSettingsTool *)settingsTool{
//    
//    if (!_settingsTool) {
//        _settingsTool = [[APKSpecialSettingsTool alloc] init];
//    }
//    return _settingsTool;
//}

- (NSMutableArray *)dataSource{
    
    if (!_dataSource) {
        
//        NSArray *REC = @[@(APKSettingItemOptionVideoResolution),@(APKSettingItemOptionVideoClipDuration),@(APKSettingItemOptionScreenSetting),@(APKSettingItemOptionRecordSound),@(APKSettingItemOptionCollisionDetection),@(APKSettingItemOptionTimeMark),@(APKSettingItemOptionParkingMode),@(APKSettingItemOptionPowerFrequency),@(APKSettingItemOptionExposureValue)];
        NSArray *FILE = @[@(APKSettingItemOptionFormat),@(APKSettingItemOptionSDCardInfo)];
//        NSArray *SET = @[@(APKSettingItemOptionModifyWifi),@(APKSettingItemOptionTimeSetting),@(APKSettingItemOptionTimeZone),@(APKSettingItemOptionSatelliteTimeSync),@(APKSettingItemOptionSoundEffect),@(APKSettingItemOptionVolume),@(APKSettingItemOptionLanguage)];
//        NSArray *ADV = @[@(APKSettingItemOptionVelocityUnit),@(APKSettingItemOptionCustomSpeedLimitTips),@(APKSettingItemOptionFactoryReset),@(APKSettingItemOptionSoftwareVersion),@(APKSettingItemOptionHelp),@(APKSettingItemOptionAbout)];
        
        NSArray *videoSetArray = @[@(APKSettingItemOptionVideoResolution),@(APKSettingItemOptionVideoResolutionRear),@(APKSettingItemOptionVideoClipDuration),@(APKSettingItemTypeRearCameraVideo),@(APKSettingItemOptionRecordSound),@(APKSettingItemLoopRecordingSetting),@(APKSettingItemParkingModeLoopRecording),@(APKSettingItemOptionCollisionDetection),@(APKSettingItemOptionTimeMark),@(APKSettingItemOptionParkingMode),@(APKSettingItemTypeParkingModeSensitivity),@(APKSettingItemOptionParkingModeTime),@(APKSettingItemOptionPowerFrequency),@(APKSettingItemOptionExposureValue)];
        
        NSArray *normalSetArray = @[@(APKSettingItemOptionScreenSetting),@(APKSettingItemDefaultScreenDisPlay),@(APKSettingItemHideMenuBarAutomatically),@(APKSettingItemOptionTimeSetting),@(APKSettingItemOptionTimeZone),@(APKSettingItemOptionSatelliteTimeSync),@(APKSettingItemOptionSoundEffect),@(APKSettingItemOptionVolume),@(APKSettingItemOptionVelocityUnit),@(APKSettingItemOptionCustomSpeedLimitTips)];
        
        NSArray *detailSetArray = @[@(APKSettingItemOptionFactoryReset),@(APKSettingItemOptionSoftwareVersion),@(APKSettingAppVersion)];
        
        NSArray *appSetArray = @[@(APKSettingItemOptionLanguage),@(APKSettingItemOptionHelp),@(APKSettingItemOptionAbout),@(APKSettingItemOptionModifyWifi)];
        
        

        NSArray *infos = @[videoSetArray,FILE,normalSetArray,detailSetArray,appSetArray];
        
        _dataSource = [[NSMutableArray alloc] initWithCapacity:5];
        for (NSInteger i = 0; i < infos.count; i++) {
            
            NSArray *options = infos[i];
            NSMutableArray *itemArray = [[NSMutableArray alloc] initWithCapacity:options.count];
            for (NSInteger j = 0; j < options.count; j++) {
                
                APKSettingItemOptions option = [options[j] integerValue];
                APKSettingItem *item = [[APKSettingItem alloc] init];
                item.option = option;
                [itemArray addObject:item];
                if (item.option == APKSettingItemOptionCustomSpeedLimitTips) {
                    
                    self.speedLimitAlertItem = item;
                }
            }
            [_dataSource addObject:itemArray];
        }
    }
    
    return _dataSource;
}

- (APKCommonTaskTool *)commonTaskTool{
    
    if (!_commonTaskTool) {
        _commonTaskTool = [[APKCommonTaskTool alloc] init];
    }
    return _commonTaskTool;
}

#pragma mark - private method

- (void)operatorForSpecialItem:(NSInteger)value{
    
    if (self.targetItem.option == APKSettingItemOptionVelocityUnit) {
        
        [APKDVR sharedInstance].info.SpeedUnit = value;
        [self.speedLimitAlertItem updateItemInfo];
        [self.tableView reloadData];
        
    }else if (self.targetItem.option == APKSettingItemOptionCustomSpeedLimitTips){
        
        [APKDVR sharedInstance].info.SpeedLimitAlert = value;
    }else if(self.targetItem.option == APKSettingItemOptionExposureValue){
        
        [APKDVR sharedInstance].info.EV = value;
    }
}

- (void)showHUDWithMessage:(NSString *)message duration:(CGFloat)duration{
    
    MBProgressHUD *successHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    successHUD.mode = MBProgressHUDModeText;
    successHUD.userInteractionEnabled = NO;
    successHUD.label.text = message;
    [successHUD hideAnimated:YES afterDelay:duration];
}

- (void)updateUIWithTimer:(NSTimer *)timer{
    
    KWEAKSELF;
    if (self.setDVRClockAlert) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *time = [weakSelf getCurrentTime];
            weakSelf.setDVRClockAlert.message = time;
        });
        
    }else{
        
        [timer invalidate];
    }
}


- (void)refreshPage{
    
    for (NSInteger i = 0; i < self.dataSource.count; i++) {
        
        NSArray *itemArray = self.dataSource[i];
        for (APKSettingItem *item in itemArray) {
            
            [item updateItemInfo];
        }
    }
    [self.tableView reloadData];
}

#pragma mark set

- (void)factoryReset{
    
    KWEAKSELF;
    [APKAlertTool showAlertInViewController:self title:nil message:NSLocalizedString(@"是否恢复出厂设置？", nil) handler:^(UIAlertAction *action) {

        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
        hud.label.text = NSLocalizedString(@"设置正在更新中", nil);
        __weak typeof(self)weakSelf = self;
        NSString *property = weakSelf.targetItem.setProperty;
        NSString *value = weakSelf.targetItem.setValues[0];
        [weakSelf.commonTaskTool setDVRWithProperty:property value:value completionHandler:^(BOOL success) {

            [hud hideAnimated:YES];
            if (!success) {
                [APKAlertTool showAlertInViewController:weakSelf message:NSLocalizedString(@"恢复出厂设置失败！", nil)];
            }else{
                [APKDVR sharedInstance].isConnected = NO;
                [APKAlertTool showAlertInViewController:weakSelf message:NSLocalizedString(@"恢复出厂设置成功！", nil)];
            }
        }];
    }];
}

- (void)formatSDCard{
    
    __weak typeof (self) weakself = self;
    NSArray *arr = @[NSLocalizedString(@"当已设定停车模式", nil),NSLocalizedString(@"当没有设定停车模式", nil)];
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    for (int i = 0; i < arr.count; i++) {
        UIAlertAction* action = [UIAlertAction actionWithTitle:arr[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
            switch (i) {
                case 0:
                {
                    [weakself.commonTaskTool setDVRWithProperty:@"SD0" value:@"format_park" completionHandler:^(BOOL success) {
                        
                        if (success)
                            [weakself showHUDWithMessage:NSLocalizedString(@"设置成功！", nil) duration:1.f];
                        else
                            [APKAlertTool showAlertInViewController:weakself message:NSLocalizedString(@"设置失败！", nil)];
                        
                    }];
                }
                    break;
                    default:
                {
                    [weakself.commonTaskTool setDVRWithProperty:@"SD0" value:@"format" completionHandler:^(BOOL success) {
                        
                        if (success)
                            [weakself showHUDWithMessage:NSLocalizedString(@"设置成功！", nil) duration:1.f];
                        else
                            [APKAlertTool showAlertInViewController:weakself message:NSLocalizedString(@"设置失败！", nil)];
                        
                    }];
                    break;
                }
            }
        }];
        
        [alertController addAction:action];
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - APKSwitchSettingCellDelegate

- (void)APKSwitchSettingCell:(APKSwitchSettingCell *)cell didUpdateSwitch:(UISwitch *)sender{
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected) {
        [APKAlertTool showAlertInViewController:self message:NSLocalizedString(@"未连接DVR！", nil)];
        return;
    }
    
    KWEAKSELF;
    [self.taskTool getParkingModeInfo:^(BOOL success) {
        
        NSString *parkingModeInfo = [APKDVR sharedInstance].info.parkingModeInfo;
        NSString *parkMode = [parkingModeInfo substringToIndex:1];
        if ([parkMode isEqualToString:@"1"]){
            
            [APKAlertTool showAlertInViewController:weakSelf message:NSLocalizedString(@"停车模式中无法修改设置，请手动退出", nil)];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.2), dispatch_get_main_queue(), ^{
                sender.on = !sender.isOn;
            });
            return;
        }
        NSInteger index = sender.isOn;
        NSIndexPath *indexPath = [weakSelf.tableView indexPathForCell:cell];
        APKSettingItem *item = weakSelf.dataSource[indexPath.section][indexPath.row];
        NSString *property = item.setProperty;
        NSString *value = item.setValues[index];
        
        [weakSelf.commonTaskTool setDVRWithProperty:property value:value completionHandler:^(BOOL success) {
            
            if (success) {
                item.valueIndex = index;
                [weakSelf showHUDWithMessage:NSLocalizedString(@"设置成功！", nil) duration:1.f];
                
                if (weakSelf.targetItem.option == APKSettingItemOptionVideoResolution) {
                    
                    [APKDVR sharedInstance].info.recordSound = index;
                }
            }else{
                [APKAlertTool showAlertInViewController:weakSelf message:NSLocalizedString(@"设置失败！", nil)];
                [weakSelf.tableView reloadData];
            }
        }];
        
    }];
}

#pragma mark - APKSettingItemsViewDelegate

- (NSString *)APKSettingItemsView:(APKSettingItemsView *)settingItemsView titleOfItemAtIndex:(NSInteger)index{
    
    NSArray *titles = self.targetItem.setDisplayValues;
    NSString *key = titles[index];
    return NSLocalizedString(key, nil);
}

- (NSInteger)numberOfItemsInAPKSettingItemsView:(APKSettingItemsView *)settingItemsView{
    
    NSArray *titles = self.targetItem.setDisplayValues;
    if ([self.targetItem.setDisplayValues[0] isEqualToString:@""]) return 1;
    return titles.count;
}

- (void)APKSettingItemsView:(APKSettingItemsView *)settingItemsView didSelectItemAtIndex:(NSInteger)index{
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected) {
        [APKAlertTool showAlertInViewController:self message:NSLocalizedString(@"未连接DVR！", nil)];
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    [self.taskTool getParkingModeInfo:^(BOOL success) {
        
        NSString *parkingModeInfo = [APKDVR sharedInstance].info.parkingModeInfo;
        NSString *parkMode = [parkingModeInfo substringToIndex:1];
        if ([parkMode isEqualToString:@"1"]){
            
            [APKAlertTool showAlertInViewController:weakSelf message:NSLocalizedString(@"停车模式中无法修改设置，请手动退出", nil)];
            return;
        }
        
        NSString *property = weakSelf.targetItem.setProperty;
        NSString *value = weakSelf.targetItem.setValues[index];
        if (weakSelf.targetItem.valueIndex != index) {
            
            if ([property isEqualToString:@"ParkMode"] && [value isEqualToString:@"OFF"]) {
                
                [APKAlertTool showAlertInViewController:self title:nil message:NSLocalizedString(@"請在記錄儀內關閉泊車模式", nil) handler:nil];
                return;
            }
            
            APKSettingItemOptions option = weakSelf.targetItem.option;
            if (option == APKSettingItemOptionVideoResolution || option == APKSettingItemOptionVideoClipDuration){
                
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                hud.label.text = NSLocalizedString(@"设置正在更新中", nil);
                [weakSelf.commonTaskTool setDVRWithProperty:property value:value completionHandler:^(BOOL success) {
                    
                    if (success) {
                        hud.mode = MBProgressHUDModeText;
                        hud.label.text = NSLocalizedString(@"设置成功！", nil);
                        [hud hideAnimated:YES afterDelay:1.f];
                        weakSelf.targetItem.valueIndex = index;
                    }else{
                        [hud hideAnimated:YES];
                        [APKAlertTool showAlertInViewController:weakSelf message:NSLocalizedString(@"设置失败！", nil)];
                    }
                    [weakSelf.tableView reloadData];
                }];
            }
            else{
                
                if ([value isEqualToString:@"GSensorOFF"]) {
                    
                    [APKAlertTool showAlertInViewController:self message:NSLocalizedString(@"如要自定靈敏度請到記錄儀上設置", nil)];
                    return;
                }
                [weakSelf.commonTaskTool setDVRWithProperty:property value:value completionHandler:^(BOOL success) {
                    
                    if (success) {
                        
                        weakSelf.targetItem.valueIndex = index;
                        [weakSelf showHUDWithMessage:NSLocalizedString(@"设置成功！", nil) duration:1.f];
                        //一些设置需要做额外的处理
                        [weakSelf operatorForSpecialItem:index];
                        
                    }else{
                        [APKAlertTool showAlertInViewController:weakSelf message:NSLocalizedString(@"设置失败！", nil)];
                    }
                    [weakSelf.tableView reloadData];
                }];
            }
        }else{
            
            if ([property isEqualToString:@"ParkMode"] && [APKDVR sharedInstance].info.ParkMode == 0) {
                
                [APKAlertTool showAlertInViewController:self title:nil message:NSLocalizedString(@"請先在記錄儀內設定泊⾞模式", nil) handler:nil];
                return;
            }
        }
    }];
}

#pragma mark - APKCheckBoxSettingCellDelegate

#define space 20;
- (void)APKCheckBoxSettingCell:(APKCheckBoxSettingCell *)cell didClickButton:(UIButton *)sender{
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    APKSettingItem *item = self.dataSource[indexPath.section][indexPath.row];
    self.targetItem = item;
    
    CGRect anchorViewFrame =  [cell convertRect:sender.frame toView:self.view.window];
    anchorViewFrame.size.width += space;
    APKSettingItemsView *settingItemsView = [APKSettingItemsView showInViewController:self delegate:self anchorViewFrame:anchorViewFrame currentIndex:self.targetItem.valueIndex topLimit:120 bottomLimit:80];
    switch (item.option) {
        case APKSettingItemOptionScreenSetting:
        case APKSettingItemOptionCollisionDetection:
        case APKSettingItemOptionParkingMode:
        case APKSettingItemOptionLanguage:
            settingItemsView.textFont = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    APKSettingItem *item = self.dataSource[indexPath.section][indexPath.row];
    if (item.type != APKSettingItemTypeNormal) {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    
    if (item.option == APKSettingItemOptionHelp) {
        
        [self performSegueWithIdentifier:@"checkHelp" sender:nil];
        return;
    }
    
    if (item.option == APKSettingItemOptionAbout) {
        
        [self performSegueWithIdentifier:@"checkAbout" sender:nil];
        return;
    }
    
    APKDVR *dvr = [APKDVR sharedInstance];
    if (!dvr.isConnected) {
        
        [APKAlertTool showAlertInViewController:self message:NSLocalizedString(@"未连接DVR！", nil)];
        return;
    }
    
    KWEAKSELF;
    [self.taskTool getParkingModeInfo:^(BOOL success) {
        
        NSString *parkingModeInfo = [APKDVR sharedInstance].info.parkingModeInfo;
        NSString *parkMode = [parkingModeInfo substringToIndex:1];
        if ([parkMode isEqualToString:@"1"]){
            
            [APKAlertTool showAlertInViewController:weakSelf message:NSLocalizedString(@"停车模式中无法修改设置，请手动退出", nil)];
            return;
        }
        
        switch (item.option) {
            case APKSettingItemOptionTimeSetting:
                [weakSelf performSegueWithIdentifier:@"adjustDVRTime" sender:nil];
                break;
            case APKSettingItemOptionFormat:
                weakSelf.targetItem = item;
                [weakSelf formatSDCard];
                break;
            case APKSettingItemOptionFactoryReset:
                weakSelf.targetItem = item;
                [weakSelf factoryReset];
                break;
            case APKSettingItemOptionModifyWifi:
                [weakSelf performSegueWithIdentifier:@"modifyWifi" sender:nil];
                break;
            case APKSettingItemOptionSDCardInfo:
                [weakSelf performSegueWithIdentifier:@"checkSDCardInfo" sender:nil];
                break;
            case APKSettingAppUpdate:
            {
                [APKFunctionTool combineAppVersion:^(BOOL isSameVersion) {
                    
                    [APKAlertTool showAlertInViewController:weakSelf message:NSLocalizedString(@"已是最新版本", nil)];
                    return;
                    
                    if (isSameVersion) {
                        [APKAlertTool showAlertInViewController:weakSelf message:NSLocalizedString(@"已是最新版本", nil)];
                    }else{
                        [APKAlertTool showAlertInViewController:weakSelf title:nil message:NSLocalizedString(@"即将跳转到App Store，是否继续？", nil) handler:^(UIAlertAction *action) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/innowa-journey-share-videos/id1263014143"]];
                        }];
                    }
                }];
                
                break;
            }
            default:
                break;
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    settingHeadView *headview = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"headView"];
    if (!headview) {
        NSArray *infos = @[NSLocalizedString(@"录影设定", nil),NSLocalizedString(@"文件设定", nil),NSLocalizedString(@"一般设定", nil),NSLocalizedString(@"详细设定", nil),NSLocalizedString(@"APP设定", nil)];
        NSArray *array = self.rowNumberArray[section];
        headview = [[NSBundle mainBundle] loadNibNamed:@"settingHeadView" owner:nil options:nil][0];
        headview.actionButton.tag = section;
        UIImage *image = [UIImage imageNamed:@"icon-73"];
        if (array.count > 0){
            //image的翻转
            image = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:UIImageOrientationDown];
        }
        headview.arrowsImage.image = image;
        headview.titleL.text = NSLocalizedString(infos[section], nil);
        headview.clickHeadViewAction = ^(NSInteger tag) {
        
            if (array.count == 0) {
//                [self.rowNumberArray replaceObjectAtIndex:tag withObject:self.dataSource[tag]];
                for (int i = 0; i < self.rowNumberArray.count; i++) {
                    if (tag == i) {
                        [self.rowNumberArray replaceObjectAtIndex:tag withObject:self.dataSource[tag]];
                    }else
                    {
                        [self.rowNumberArray replaceObjectAtIndex:i withObject:@[]];
                    }
                }
            }
            else
            {
                [self.rowNumberArray replaceObjectAtIndex:tag withObject:@[]];
            }
            [self.tableView reloadData];
        };
    }
    return headview;
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSArray *array = self.rowNumberArray[section];
    return [array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    APKSettingItem *item = self.dataSource[indexPath.section][indexPath.row];
    if (item.type == APKSettingItemTypeNormal) {
        
        APKNormalSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier1 forIndexPath:indexPath];
        [cell configureCellWithSettingItem:item];
        return cell;
        
    }else if (item.type == APKSettingItemTypeSwitch){
        
        APKSwitchSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier2 forIndexPath:indexPath];
        cell.delegate = self;
        [cell configureCellWithSettingItem:item];
        return cell;
        
    }else if (item.type == APKSettingItemTypeCheckBox){
        
        APKCheckBoxSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier3 forIndexPath:indexPath];
        cell.delegate = self;
        [cell configureCellWithSettingItem:item];
        return cell;
        
    }else if (item.type == APKSettingItemTypeText){
        
        APKTextSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier4 forIndexPath:indexPath];
        [cell configureCellWithSettingItem:item];
        return cell;
    }
    
    return nil;
}

#pragma mark - Utilities

- (NSString *)getCurrentTime{
    
    //获取手机当前时间
    NSDate *date = [[NSDate alloc] init];
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentTime = [dateFormatter stringFromDate:date];
    return currentTime;
}

-(NSMutableArray*)headImageArray
{
    if (!_headImageArray) {
        _headImageArray = [NSMutableArray array];
    }
    return _headImageArray;
}

- (APKCommonTaskTool *)taskTool{
    
    if (!_taskTool) {
        _taskTool = [[APKCommonTaskTool alloc] init];
    }
    return _taskTool;
}

@end
