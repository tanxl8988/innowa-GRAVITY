//
//  APKNormalSettingCell.m
//  Innowa
//
//  Created by Mac on 17/5/2.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKNormalSettingCell.h"

@implementation APKNormalSettingCell

- (void)configureCellWithSettingItem:(APKSettingItem *)item{
    
    self.label.text = item.title;
}

@end
