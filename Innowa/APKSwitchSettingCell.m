//
//  APKSwitchSettingCell.m
//  Innowa
//
//  Created by Mac on 17/5/2.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKSwitchSettingCell.h"

@implementation APKSwitchSettingCell

- (void)configureCellWithSettingItem:(APKSettingItem *)item{
    
    self.label.text = item.title;
    self.aSwitch.on = item.valueIndex;
}

- (IBAction)toggleSwitch:(UISwitch *)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(APKSwitchSettingCell:didUpdateSwitch:)]) {
        
        [self.delegate APKSwitchSettingCell:self didUpdateSwitch:sender];
    }
}

@end
