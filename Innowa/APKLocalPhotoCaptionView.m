//
//  APKLocalPhotoCaptionView.m
//  Innowa
//
//  Created by Mac on 17/4/27.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKLocalPhotoCaptionView.h"

@implementation APKLocalPhotoCaptionView

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

    self.collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.collectButton.frame = CGRectMake(0, 0, 30, 30);
    [self.collectButton setBackgroundImage:[UIImage imageNamed:@"collect_normal"] forState:UIControlStateNormal];
    [self.collectButton setBackgroundImage:[UIImage imageNamed:@"collect_highlight"] forState:UIControlStateHighlighted];
    [self.collectButton setBackgroundImage:[UIImage imageNamed:@"collect_highlight"] forState:UIControlStateSelected];
    [self.collectButton setBackgroundImage:[UIImage imageNamed:@"collect_highlight"] forState:UIControlStateDisabled];
    [self.collectButton addTarget:self action:@selector(clickActionButton:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *collectItem = [[UIBarButtonItem alloc]initWithCustomView:self.collectButton];
    
    self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.shareButton.frame = CGRectMake(0, 0, 30, 30);
    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"share_normal"] forState:UIControlStateNormal];
    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"share_highlight"] forState:UIControlStateHighlighted];
    [self.shareButton setBackgroundImage:[UIImage imageNamed:@"share_highlight"] forState:UIControlStateDisabled];
    [self.shareButton addTarget:self action:@selector(clickActionButton:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc]initWithCustomView:self.shareButton];
    
    [self setItems:@[deleteItem,flexSpace,collectItem,flexSpace,shareItem]];
    self.userInteractionEnabled = YES;
}

- (void)configureViewWithLocalFile:(LocalFile *)file{
    
    self.collectButton.selected = file.isCollected;
}

- (void)clickActionButton:(UIButton *)sender{
    
    if (!self.customDelegate) return;
    
    if (sender == self.deleteButton) {
        
        if ([self.customDelegate respondsToSelector:@selector(APKLocalPhotoCaptionView:didClickDeleteButton:)]) {
            
            [self.customDelegate APKLocalPhotoCaptionView:self didClickDeleteButton:sender];
        }
        
    }else if (sender == self.collectButton){
        
        if ([self.customDelegate respondsToSelector:@selector(APKLocalPhotoCaptionView:didClickCollectButton:)]) {
            
            [self.customDelegate APKLocalPhotoCaptionView:self didClickCollectButton:sender];
        }
        
    }else if (sender == self.shareButton){
        
        if ([self.customDelegate respondsToSelector:@selector(APKLocalPhotoCaptionView:didClickShareButton:)]) {
            
            [self.customDelegate APKLocalPhotoCaptionView:self didClickShareButton:sender];
        }
    }
}

@end
