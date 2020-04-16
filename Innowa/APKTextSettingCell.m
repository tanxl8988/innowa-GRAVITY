//
//  APKTextSettingCell.m
//  Innowa
//
//  Created by Mac on 17/5/11.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKTextSettingCell.h"

@implementation APKTextSettingCell

- (void)configureCellWithSettingItem:(APKSettingItem *)item{
    
    self.label.text = item.title;
    self.infoLabel.text = item.textValue;
}

@end
