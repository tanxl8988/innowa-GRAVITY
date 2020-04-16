//
//  APKDVRVideoCell.h
//  Innowa
//
//  Created by Mac on 17/4/26.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APKDVRFile.h"


@class APKDVRVideoCell;

@protocol APKDVRVideoCellDelegate <NSObject>

- (void)APKDVRVideoCell:(APKDVRVideoCell *)cell didClickDownloadButton:(UIButton *)sender;
- (void)APKDVRVideoCell:(APKDVRVideoCell *)cell didClickDeleteButton:(UIButton *)sender;

@end

@interface APKDVRVideoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imagev;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (weak,nonatomic) id<APKDVRVideoCellDelegate> delegate;

- (void)configureWithFile:(APKDVRFile *)file;


@end
