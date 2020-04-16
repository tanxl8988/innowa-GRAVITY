//
//  APKCustomTabBarController.m
//  Innowa
//
//  Created by Mac on 17/3/28.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKCustomTabBarController.h"
#import "MBProgressHUD.h"
#import "JYJSliderMenuTool.h"

@interface APKCustomTabBarController ()<UIGestureRecognizerDelegate>

@end

@implementation APKCustomTabBarController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        self.tabBar.hidden = YES;
        self.customTabBar = [[NSBundle mainBundle] loadNibNamed:@"APKCustomTabBar" owner:self options:nil].firstObject;
        [self.view addSubview:self.customTabBar];
        __weak typeof(self)weakSelf = self;
        self.selectedIndex = 1;
        self.customTabBar.updateIndexBlock = ^(NSInteger index){
            
            weakSelf.selectedIndex = index;
        };
    }
    return self;
}

- (void)dealloc
{

}

- (void)viewDidLayoutSubviews{
    
    [super viewDidLayoutSubviews];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat barHeight = 80;
    self.customTabBar.frame = CGRectMake(0, screenHeight - barHeight, screenWidth, barHeight);
    
    // 屏幕边缘pan手势(优先级高于其他手势)
//    UIScreenEdgePanGestureRecognizer *leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
//                                                                                                          action:@selector(moveViewWithGesture:)];
//    leftEdgeGesture.edges = UIRectEdgeLeft;// 屏幕左侧边缘响应
//    [self.view addGestureRecognizer:leftEdgeGesture];
//    // 这里是地图处理方式，遵守代理协议，实现代理方法
//    leftEdgeGesture.delegate = self;

}

- (void)moveViewWithGesture:(UIPanGestureRecognizer *)panGes {
    if (panGes.state == UIGestureRecognizerStateEnded) {
        [self profileCenter];
    }
}

- (void)profileCenter {
    // 展示个人中心
    [JYJSliderMenuTool showWithRootViewController:self];
}

@end
