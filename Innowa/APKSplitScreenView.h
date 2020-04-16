//
//  APKSplitScreenView.h
//  Innowa
//
//  Created by 李福池 on 2018/6/15.
//  Copyright © 2018年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APKSplitScreenView : UIView

typedef enum : NSUInteger {
    kAPKDVRRearInFront,
    kAPKDVRFrontInRear,
    kAPKDVROnlyFront,
    kAPKDVROnlyRear,
} splitState;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *splitButtons;
@property (nonatomic,retain) UIButton *previosSelectedButton;
@property (nonatomic,copy) void (^clickSpitButton)(NSInteger btnTag);
@property (nonatomic,assign) NSInteger selectedButtonTag;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *frontBtn;
@property (weak, nonatomic) IBOutlet UIButton *rearBtn;


@end
