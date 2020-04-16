//
//  APKDVRPhotoCell.h
//  Innowa
//
//  Created by Mac on 17/4/26.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APKDVRFile.h"

@class APKDVRPhotoCell;
@protocol APKDVRPhotoCellDelegate <NSObject>

- (void)beganLongPressAPKDVRPhotoCell:(APKDVRPhotoCell *)cell;
- (void)endedLongPressAPKDVRPhotoCell:(APKDVRPhotoCell *)cell;

@end

@interface APKDVRPhotoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imagev;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UIImageView *selectFlag;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak,nonatomic) id<APKDVRPhotoCellDelegate> delegate;

- (void)configureCellWithFile:(APKDVRFile *)file;

@end
