//
//  APKLocalPhotoCaptionView.m
//  第三版云智汇
//
//  Created by Mac on 16/8/25.
//  Copyright © 2016年 APK. All rights reserved.
//

#import "APKDVRPhotoCaptionView.h"

@implementation APKDVRPhotoCaptionView

- (CGSize)sizeThatFits:(CGSize)size {
    
    return CGSizeMake(size.width, 44);
}

- (void)setupCaption {
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    // 初始化
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.deleteButton.frame = CGRectMake(0, 0, 30, 30);
    [self.deleteButton setBackgroundImage:[UIImage imageNamed:@"delete_normal"] forState:UIControlStateNormal];
    [self.deleteButton setBackgroundImage:[UIImage imageNamed:@"delete_highlight"] forState:UIControlStateHighlighted];
    [self.deleteButton setBackgroundImage:[UIImage imageNamed:@"delete_highlight"] forState:UIControlStateDisabled];
    [self.deleteButton addTarget:self action:@selector(clickActionButton:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc]initWithCustomView:self.deleteButton];
    
    self.downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.downloadButton.frame = CGRectMake(0, 0, 30, 30);
    [self.downloadButton setBackgroundImage:[UIImage imageNamed:@"download_normal"] forState:UIControlStateNormal];
    [self.downloadButton setBackgroundImage:[UIImage imageNamed:@"download_highlight"] forState:UIControlStateHighlighted];
    [self.downloadButton setBackgroundImage:[UIImage imageNamed:@"download_highlight"] forState:UIControlStateDisabled];
    [self.downloadButton addTarget:self action:@selector(clickActionButton:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *downloadItem = [[UIBarButtonItem alloc]initWithCustomView:self.downloadButton];
    
    [self setItems:@[downloadItem,flexSpace,deleteItem]];
    self.userInteractionEnabled = YES;
}

- (void)configureViewWithDVRFile:(APKDVRFile *)file{
    
    if (file.previewPath) {
    
        self.downloadButton.hidden = NO;
        self.deleteButton.hidden = NO;
        self.downloadButton.enabled = !file.isDownloaded;
        
    }else{
        
        self.downloadButton.hidden = YES;
        self.deleteButton.hidden = YES;
    }
}

- (void)clickActionButton:(UIButton *)sender{
    
    if (!self.customDelegate) return;
    
    if (sender == self.deleteButton) {
        
        if ([self.customDelegate respondsToSelector:@selector(APKDVRPhotoCaptionView:didClickDeleteButton:)]) {
            
            [self.customDelegate APKDVRPhotoCaptionView:self didClickDeleteButton:sender];
        }
    }
    else if (sender == self.downloadButton){
        
        if ([self.customDelegate respondsToSelector:@selector(APKDVRPhotoCaptionView:didClickDownloadButton:)]) {
            
            [self.customDelegate APKDVRPhotoCaptionView:self didClickDownloadButton:sender];
        }
    }
}

@end





