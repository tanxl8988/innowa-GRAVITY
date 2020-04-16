//
//  settingHeadView.h
//  Innowa
//
//  Created by 李福池 on 2018/8/6.
//  Copyright © 2018年 APK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface settingHeadView : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UILabel *titleL;
@property (weak, nonatomic) IBOutlet UIImageView *arrowsImage;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (nonatomic,assign) BOOL rotateValue;
@property (nonatomic,copy) void (^clickHeadViewAction)(NSInteger tag);

@end
