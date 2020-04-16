//
//  APKLocalPhotoCaptionView.h
//  Innowa
//
//  Created by Mac on 17/4/27.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <MWPhotoBrowser/MWPhotoBrowser.h>
#import "LocalFile.h"

@class APKLocalPhotoCaptionView;
@protocol APKLocalPhotoCaptionViewDelegate <NSObject>

- (void)APKLocalPhotoCaptionView:(APKLocalPhotoCaptionView *)captionView didClickDeleteButton:(UIButton *)sender;
- (void)APKLocalPhotoCaptionView:(APKLocalPhotoCaptionView *)captionView didClickCollectButton:(UIButton *)sender;
- (void)APKLocalPhotoCaptionView:(APKLocalPhotoCaptionView *)captionView didClickShareButton:(UIButton *)sender;

@end

@interface APKLocalPhotoCaptionView : MWCaptionView

@property (strong,nonatomic) UIButton *deleteButton;
@property (strong,nonatomic) UIButton *collectButton;
@property (strong,nonatomic) UIButton *shareButton;

@property (weak,nonatomic) id<APKLocalPhotoCaptionViewDelegate> customDelegate;

- (void)configureViewWithLocalFile:(LocalFile *)file;

@end
