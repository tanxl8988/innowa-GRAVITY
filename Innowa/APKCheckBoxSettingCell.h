//
//  APKCheckBoxSettingCell.h
//  Innowa
//
//  Created by Mac on 17/5/2.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APKSettingItem.h"

@class APKCheckBoxSettingCell;

@protocol APKCheckBoxSettingCellDelegate <NSObject>

- (void)APKCheckBoxSettingCell:(APKCheckBoxSettingCell *)cell didClickButton:(UIButton *)sender;

@end

@interface APKCheckBoxSettingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *button;

@property (weak,nonatomic) id<APKCheckBoxSettingCellDelegate> delegate;
- (void)configureCellWithSettingItem:(APKSettingItem *)item;

@end
