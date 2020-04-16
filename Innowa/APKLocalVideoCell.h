//
//  APKLocalVideoCell.h
//  Innowa
//
//  Created by Mac on 17/4/27.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalFile.h"


@class APKLocalVideoCell;

@protocol APKLocalVideoCellDelegate <NSObject>

- (void)APKLocalVideoCell:(APKLocalVideoCell *)cell didClickDeleteButton:(UIButton *)sender;
- (void)APKLocalVideoCell:(APKLocalVideoCell *)cell didClickCollectButton:(UIButton *)sender;
- (void)APKLocalVideoCell:(APKLocalVideoCell *)cell didClickShareButton:(UIButton *)sender;

@end

@interface APKLocalVideoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imagev;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *collectButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak,nonatomic) id<APKLocalVideoCellDelegate>delegate;

- (void)configureCellWithFile:(LocalFile *)file;

@end
