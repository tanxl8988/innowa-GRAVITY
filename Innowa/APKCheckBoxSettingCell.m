//
//  APKCheckBoxSettingCell.m
//  Innowa
//
//  Created by Mac on 17/5/2.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKCheckBoxSettingCell.h"
#import "APKDVR.h"

@interface APKCheckBoxSettingCell ()

@property (weak, nonatomic) IBOutlet UIView *borderView;
@property (weak, nonatomic) IBOutlet UIButton *spaceButton;

@end

@implementation APKCheckBoxSettingCell

- (void)awakeFromNib{
    
    [super awakeFromNib];
    
    self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.spaceButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
}

- (void)configureCellWithSettingItem:(APKSettingItem *)item{
    
    self.label.text = item.title;
    
    NSArray *displayValues = item.setDisplayValues;
    for (NSString *value in displayValues) {
        if ([value containsString:NSLocalizedString(@"自定义:", nil)]) {
            
            NSString *GSensorvalue = @"";
            if (item.valueIndex == 0)
                GSensorvalue = @"1.0;1.0;1.0";
            else if (item.valueIndex == 1)
                GSensorvalue = @"1.5;1.5;1.5";
            else if (item.valueIndex == 2)
                GSensorvalue = @"2.5;2.5;2.5";
            else
                GSensorvalue = [APKDVR sharedInstance].info.GSensorStr;
            
            NSString *customGsensorStr = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"自定义:", nil),GSensorvalue];
            item.setDisplayValues = @[@"高灵敏度",@"中灵敏度",@"低灵敏度",customGsensorStr];
            NSLog(@"");
        }
    }
    //space button
    NSString *maxStr = nil;
    NSInteger maxLength = 0;
    for (NSString *value in displayValues) {
        
        NSString *str = NSLocalizedString(value, nil);
        if (str.length > maxLength) {
            maxLength = str.length;
            maxStr = str;
        }
    }
    [self.spaceButton setTitle:maxStr forState:UIControlStateNormal];

    //button
    NSInteger index = 0;
    if (item.valueIndex < displayValues.count && item.valueIndex >= 0) {
        index = item.valueIndex;
    }
    NSString *value = displayValues[index];
    [self.button setTitle:NSLocalizedString(value, nil) forState:UIControlStateNormal];
}

- (IBAction)clickButton:(UIButton *)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(APKCheckBoxSettingCell:didClickButton:)]) {
        
        [self.delegate APKCheckBoxSettingCell:self didClickButton:sender];
    }
}


@end
