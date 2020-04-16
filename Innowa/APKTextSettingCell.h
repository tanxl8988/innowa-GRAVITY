//
//  APKTextSettingCell.h
//  Innowa
//
//  Created by Mac on 17/5/11.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APKSettingItem.h"

@interface APKTextSettingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

- (void)configureCellWithSettingItem:(APKSettingItem *)item;

@end
