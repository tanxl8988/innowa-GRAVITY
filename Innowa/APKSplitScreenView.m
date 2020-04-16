//
//  APKSplitScreenView.m
//  Innowa
//
//  Created by 李福池 on 2018/6/15.
//  Copyright © 2018年 APK. All rights reserved.
//

#import "APKSplitScreenView.h"

@implementation APKSplitScreenView

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self.sureButton setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
     [self.cancelButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [self.frontBtn setTitle:NSLocalizedString(@"前", nil) forState:UIControlStateNormal];
    [self.rearBtn setTitle:NSLocalizedString(@"后", nil) forState:UIControlStateNormal];
}

- (IBAction)clickButtonAction:(UIButton *)sender {
    
    if (sender == self.previosSelectedButton) return;
    for (UIButton *btn in _splitButtons) btn.selected = NO;
    sender.selected = YES;
    self.selectedButtonTag = sender.tag;
    self.previosSelectedButton = sender;
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"splitScreenNotication" object:nil userInfo:@{@"splitScreenValue":[NSString stringWithFormat:@"%ld",sender.tag]}];
}

- (IBAction)clickConfirmButton:(UIButton *)sender {
    
    if (sender.tag == 100) self.clickSpitButton(self.selectedButtonTag);
    
    [self removeFromSuperview];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
