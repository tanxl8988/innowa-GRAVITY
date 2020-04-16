//
//  APKLocalPhotoCell.m
//  Innowa
//
//  Created by Mac on 17/4/27.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKLocalPhotoCell.h"

@implementation APKLocalPhotoCell

- (void)awakeFromNib{
    
    [super awakeFromNib];
    
    self.selectFlag.hidden = YES;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressCell:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:longPress];
}

- (void)setSelected:(BOOL)selected{
    
    [super setSelected:selected];
    
    self.selectFlag.hidden = !selected;
}


- (void)configureCellWithFile:(LocalFile *)file{
    
    self.label.text = file.name;
    self.collectFlag.hidden = !file.isCollected;
}

- (void)longPressCell:(UILongPressGestureRecognizer *)sender {
    
    if (self.delegate) {
        
        if (sender.state == UIGestureRecognizerStateBegan) {
            
            if ([self.delegate respondsToSelector:@selector(beganLongPressAPKLocalPhotoCell:)]) {
                
                [self.delegate beganLongPressAPKLocalPhotoCell:self];
            }
            
        }else if (sender.state == UIGestureRecognizerStateEnded){
            
            if ([self.delegate respondsToSelector:@selector(endedLongPressAPKLocalPhotoCell:)]) {
                
                [self.delegate endedLongPressAPKLocalPhotoCell:self];
            }
        }
    }
}

@end
