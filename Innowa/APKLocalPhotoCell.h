//
//  APKLocalPhotoCell.h
//  Innowa
//
//  Created by Mac on 17/4/27.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalFile.h"

@class APKLocalPhotoCell;
@protocol APKLocalPhotoCellDelegate <NSObject>

- (void)beganLongPressAPKLocalPhotoCell:(APKLocalPhotoCell *)cell;
- (void)endedLongPressAPKLocalPhotoCell:(APKLocalPhotoCell *)cell;

@end

@interface APKLocalPhotoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imagev;
@property (weak, nonatomic) IBOutlet UIImageView *selectFlag;
@property (weak, nonatomic) IBOutlet UIImageView *collectFlag;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak,nonatomic) id<APKLocalPhotoCellDelegate> delegate;

- (void)configureCellWithFile:(LocalFile *)file;

@end
