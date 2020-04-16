//
//  APKNormalSettingCell.h
//  Innowa
//
//  Created by Mac on 17/5/2.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APKSettingItem.h"

@interface APKNormalSettingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;

- (void)configureCellWithSettingItem:(APKSettingItem *)item;

@end
