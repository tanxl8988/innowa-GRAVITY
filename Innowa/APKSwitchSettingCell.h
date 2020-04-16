//
//  APKSwitchSettingCell.h
//  Innowa
//
//  Created by Mac on 17/5/2.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APKSettingItem.h"

@class APKSwitchSettingCell;

@protocol APKSwitchSettingCellDelegate <NSObject>

- (void)APKSwitchSettingCell:(APKSwitchSettingCell *)cell didUpdateSwitch:(UISwitch *)sender;

@end

@interface APKSwitchSettingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UISwitch *aSwitch;
@property (weak,nonatomic) id<APKSwitchSettingCellDelegate>delegate;

- (void)configureCellWithSettingItem:(APKSettingItem *)item;

@end
