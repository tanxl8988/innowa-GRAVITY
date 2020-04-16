//
//  APKCustomTabBar.m
//  Innowa
//
//  Created by Mac on 17/3/28.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKCustomTabBar.h"

@implementation APKCustomTabBar


- (void)awakeFromNib{
    
    [super awakeFromNib];
    
    self.leftLabel.text = NSLocalizedString(@"摄像机", nil);
    self.middleLabel.text = NSLocalizedString(@"相册", nil);
    self.rightLabel.text = NSLocalizedString(@"设置", nil);
    self.leftButton.enabled = NO;
    [self selectButtonWithIndex:1];
}

- (void)selectButtonWithIndex:(NSInteger)index{
    
    switch (index) {
        case 0:
            [self clickButton:self.leftButton];
            break;
        case 1:
            [self clickButton:self.middleButton];
            break;
        case 2:
            [self clickButton:self.rightButton];
            break;
    }
}

- (IBAction)clickButton:(UIButton *)sender {
    
    sender.enabled = NO;
    NSInteger index = 0;
    if (sender == self.leftButton) {
        
        self.middleButton.enabled = YES;
        self.rightButton.enabled = YES;
        index = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"returnToFirstSetVC" object:nil];

    }else if (sender == self.middleButton){
        
        self.leftButton.enabled = YES;
        self.rightButton.enabled = YES;
        index = 1;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"returnToFirstSetVC" object:nil];

    }else if (sender == self.rightButton){
        
        self.leftButton.enabled = YES;
        self.middleButton.enabled = YES;
        index = 2;
    }
    
    if (self.updateIndexBlock) {
        self.updateIndexBlock(index);
    }
}



@end
