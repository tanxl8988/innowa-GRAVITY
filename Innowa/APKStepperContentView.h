//
//  APKStepperContentView.h
//  Innowa
//
//  Created by Mac on 17/5/17.
//  Copyright © 2017年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APKStepperContentView : UIView

@property (weak, nonatomic) IBOutlet UIButton *increaseButton;
@property (weak, nonatomic) IBOutlet UIButton *decreaseButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@end
