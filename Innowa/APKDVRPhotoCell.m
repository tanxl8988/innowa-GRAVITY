//
//  APKDVRPhotoCell.m
//  Innowa
//
//  Created by Mac on 17/4/26.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKDVRPhotoCell.h"

@implementation APKDVRPhotoCell

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

- (void)configureCellWithFile:(APKDVRFile *)file{
    
    self.label.text = file.name;
    
    UIImage *image = nil;
    if (file.thumbnailPath) {
        image = [UIImage imageWithContentsOfFile:file.thumbnailPath];
    }
    if (!image) {
        image = [UIImage imageNamed:@"photos_floder"];
    }
    self.imagev.image = image;
}

- (void)longPressCell:(UILongPressGestureRecognizer *)sender {
    
    if (self.delegate) {
        
        if (sender.state == UIGestureRecognizerStateBegan) {
            
            if ([self.delegate respondsToSelector:@selector(beganLongPressAPKDVRPhotoCell:)]) {
                
                [self.delegate beganLongPressAPKDVRPhotoCell:self];
            }
            
        }else if (sender.state == UIGestureRecognizerStateEnded){
            
            if ([self.delegate respondsToSelector:@selector(endedLongPressAPKDVRPhotoCell:)]) {
                
                [self.delegate endedLongPressAPKDVRPhotoCell:self];
            }
        }
    }
}

@end
