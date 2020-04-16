//
//  previewSettingView.h
//  Innowa
//
//  Created by 李福池 on 2018/6/15.
//  Copyright © 2018年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APKCommonTaskTool.h"

@interface previewSettingView : UIView<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UISlider *frontSlider;
@property (weak, nonatomic) IBOutlet UISlider *rearSlider;
@property (nonatomic,retain) UIViewController *showInVC;
@property (weak, nonatomic) IBOutlet UILabel *rearL;
@property (strong,nonatomic) APKCommonTaskTool *commonTaskTool;
@property (weak, nonatomic) IBOutlet UILabel *frontL;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
-(void)refleshSliderValue;
@end
