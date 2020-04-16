//
//  vidioColletionCell.h
//  Innowa
//
//  Created by Mac on 18/4/12.
//  Copyright © 2018年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface vidioColletionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *detailL;
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UIButton *selectdButton;
@property (nonatomic,copy) void(^cellSelected)(BOOL isSelected,BOOL showSelectdButton,NSIndexPath *index,vidioColletionCell *cell);
@property (nonatomic,retain) UICollectionViewController *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *downloadImageView;
@property (nonatomic,retain) NSIndexPath *index;
@property (weak, nonatomic) IBOutlet UILabel *sizeL;
@property (weak, nonatomic) IBOutlet UIImageView *collectImage;
@property (weak, nonatomic) IBOutlet UIImageView *seletedImage;
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (weak, nonatomic) IBOutlet UIImageView *lockImage;
@end
