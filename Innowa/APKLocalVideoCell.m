//
//  APKLocalVideoCell.m
//  Innowa
//
//  Created by Mac on 17/4/27.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKLocalVideoCell.h"
#import <Photos/Photos.h>

@implementation APKLocalVideoCell


- (void)awakeFromNib{
    
    [super awakeFromNib];
    
    UIView *aView = [[UIView alloc] initWithFrame:self.bounds];
    aView.backgroundColor = [UIColor colorWithRed:167.f/255.f green:205.f/225.f blue:230.f/225.f alpha:1];
    self.selectedBackgroundView = aView;
}

- (void)configureCellWithFile:(LocalFile *)file{
    
    self.label.text = file.name;
    self.collectButton.selected = file.isCollected;
}

- (IBAction)clickButton:(UIButton *)sender {
    
    if (self.isEditing) {
        return;
    }
    
    if (self.delegate) {
        
        if (sender == self.deleteButton){
            
            if ([self.delegate respondsToSelector:@selector(APKLocalVideoCell:didClickDeleteButton:)]) {
                
                [self.delegate APKLocalVideoCell:self didClickDeleteButton:sender];
            }
            
            
        }else if (sender == self.collectButton){
            
            if ([self.delegate respondsToSelector:@selector(APKLocalVideoCell:didClickCollectButton:)]) {
                
                [self.delegate APKLocalVideoCell:self didClickCollectButton:sender];
            }
            
        }else if (sender == self.shareButton){
            
            if ([self.delegate respondsToSelector:@selector(APKLocalVideoCell:didClickShareButton:)]) {
                
                [self.delegate APKLocalVideoCell:self didClickShareButton:sender];
            }
        }
    }
}


@end
