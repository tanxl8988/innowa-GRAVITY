//
//  settingHeadView.m
//  Innowa
//
//  Created by 李福池 on 2018/8/6.
//  Copyright © 2018年 APK. All rights reserved.
//

#import "settingHeadView.h"

@implementation settingHeadView
- (IBAction)clickActionButton:(UIButton *)sender {
    
    self.rotateValue = !self.rotateValue;
    self.clickHeadViewAction(sender.tag);

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
