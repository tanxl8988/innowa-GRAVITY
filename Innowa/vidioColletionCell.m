//
//  vidioColletionCell.m
//  Innowa
//
//  Created by Mac on 18/4/12.
//  Copyright © 2018年 APK. All rights reserved.
//

#import "vidioColletionCell.h"

@implementation vidioColletionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressCell:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:longPress];
    
    // Initialization code
}
- (IBAction)selectedButtonAction:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    
    self.cellSelected(sender.isSelected,NO,self.index,nil);
    
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    self.seletedImage.hidden = !selected;
    
    self.imageView.alpha = selected ? 0.8 : 1;
    
}

-(void)longPressCell:(UILongPressGestureRecognizer *)sender
{
    
    if (sender.state == UIGestureRecognizerStateBegan){
        self.cellSelected(NO,YES,self.index,self);
    }
}

@end
