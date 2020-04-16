//
//  APKDVRVideoCell.m
//  Innowa
//
//  Created by Mac on 17/4/26.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKDVRVideoCell.h"

@implementation APKDVRVideoCell

- (void)awakeFromNib{
    
    [super awakeFromNib];
    
    UIView *aView = [[UIView alloc] initWithFrame:self.bounds];
    aView.backgroundColor = [UIColor colorWithRed:167.f/255.f green:205.f/225.f blue:230.f/225.f alpha:1];
    self.selectedBackgroundView = aView;
}

- (void)configureWithFile:(APKDVRFile *)file{
    
    self.titleLabel.text = file.name;
    
    UIImage *image = nil;
    if (file.thumbnailPath) {
        image = [UIImage imageWithContentsOfFile:file.thumbnailPath];
    }
    if (!image) {
        image = [UIImage imageNamed:@"photos_floder"];
    }
    self.imagev.image = image;
    self.downloadButton.enabled = !file.isDownloaded;
}

- (IBAction)clickButton:(UIButton *)sender {
    
    if (self.isEditing) {
        return;
    }
    
    if (self.delegate) {
        
        if (sender == self.downloadButton) {
            
            if ([self.delegate respondsToSelector:@selector(APKDVRVideoCell:didClickDownloadButton:)]) {
                
                [self.delegate APKDVRVideoCell:self didClickDownloadButton:sender];
            }
            
        }else if (sender == self.deleteButton){
            
            if ([self.delegate respondsToSelector:@selector(APKDVRVideoCell:didClickDeleteButton:)]) {
                
                [self.delegate APKDVRVideoCell:self didClickDeleteButton:sender];
            }
        }
    }
}


@end
