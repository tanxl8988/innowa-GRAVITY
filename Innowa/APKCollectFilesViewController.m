//
//  APKCollectFilesViewController.m
//  Innowa
//
//  Created by Mac on 17/4/27.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKCollectFilesViewController.h"
#import "APKCustomTabBarController.h"
#import "APKCollectPhotosViewController.h"
#import "APKCollectVideosViewController.h"

@interface APKCollectFilesViewController ()<UIScrollViewDelegate>


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UIButton *checkAllButton;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewContentWidth;
@property (nonatomic,assign) CGRect previousTitleLRect;

@property (strong,nonatomic) APKRefreshLocalFilesTool *refreshLocalFilesTool;

@end

@implementation APKCollectFilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.checkAllButton.hidden = YES;
    self.previousTitleLRect = self.titleLabel.frame;
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    if (screenWidth > 320) {
        self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    }else{
        self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    }
    self.titleLabel.text = NSLocalizedString(@"我的收藏", nil);
    [self.selectButton setTitle:NSLocalizedString(@"选择", nil) forState:UIControlStateNormal];
    [self.checkAllButton setTitle:NSLocalizedString(@"全选", nil) forState:UIControlStateNormal];
    [self.photoButton setTitle:NSLocalizedString(@"照片", nil) forState:UIControlStateNormal];
    [self.videoButton setTitle:NSLocalizedString(@"视频", nil) forState:UIControlStateNormal];
    [self updateUIWithFileTypeButton:self.videoButton];

    self.scrollViewContentWidth.constant = screenWidth * 2;
    
    __weak typeof(self)weakSelf = self;
    APKCollectVideosViewController *videosVC = self.childViewControllers.firstObject;
    videosVC.selectButton = self.selectButton;
    videosVC.selectModeHandler = ^{
        
        [weakSelf switchSelectButtons];
    };
    
    APKCollectPhotosViewController *photosVC = self.childViewControllers.lastObject;
    photosVC.selectModeHandler = ^{
        
        [weakSelf switchSelectButtons];
    };
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    APKCustomTabBarController *tabBarVC = (APKCustomTabBarController *)self.tabBarController;
    tabBarVC.customTabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    APKCustomTabBarController *tabBarVC = (APKCustomTabBarController *)self.tabBarController;
    tabBarVC.customTabBar.hidden = NO;
    
    APKCollectVideosViewController *videosVC = self.childViewControllers.firstObject;
    APKCollectPhotosViewController *photosVC = self.childViewControllers.lastObject;
    if (photosVC.haveRefreshLocalFiles || videosVC.haveRefreshLocalFiles) {
        
        [self.refreshLocalFilesTool updateAllFileCount];
    }
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

#pragma mark - getter

- (APKRefreshLocalFilesTool *)refreshLocalFilesTool{
    
    if (!_refreshLocalFilesTool) {
        _refreshLocalFilesTool = [APKRefreshLocalFilesTool sharedInstace];
    }
    return _refreshLocalFilesTool;
}

#pragma mark - private method

- (void)switchSelectButtons{
    
        if ([self.selectButton.titleLabel.text isEqualToString:NSLocalizedString(@"选择", nil)]) {
    
            [self.selectButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
            self.checkAllButton.hidden = NO;
            self.titleLabel.hidden = NO;
            self.titleLabel.frame = CGRectMake(20, CGRectGetMinY(self.titleLabel.frame), CGRectGetWidth(self.titleLabel.frame), CGRectGetHeight(self.titleLabel.frame));
    
        }else{
    
            [self.selectButton setTitle:NSLocalizedString(@"选择", nil) forState:UIControlStateNormal];
            self.checkAllButton.hidden = YES;
            self.titleLabel.hidden = NO;
            self.titleLabel.frame = self.titleLabel.frame = CGRectMake(self.view.center.x - CGRectGetWidth(self.titleLabel.frame)/2, CGRectGetMinY(self.titleLabel.frame), CGRectGetWidth(self.titleLabel.frame), CGRectGetHeight(self.titleLabel.frame));
        }
}

- (void)resetSelectButtons{
    
    CGFloat offsetX = self.scrollView.contentOffset.x;
    if (offsetX == 0) {
        
        APKCollectPhotosViewController *photosVC = self.childViewControllers.lastObject;
        if (photosVC.selectMode) {
            photosVC.selectMode = NO;
        }
        
    }else{
        
        APKCollectVideosViewController *videosVC = self.childViewControllers.firstObject;
        if (videosVC.selectMode) {
            videosVC.selectMode = NO;
        }
    }
    
    if ([self.selectButton.titleLabel.text isEqualToString:NSLocalizedString(@"取消", nil)]) {
        
        [self.selectButton setTitle:NSLocalizedString(@"选择", nil) forState:UIControlStateNormal];
        self.checkAllButton.hidden = YES;
        self.titleLabel.hidden = NO;
    }
}

- (void)updateUIWithFileTypeButton:(UIButton *)sender{
    
    sender.enabled = NO;
    if (sender == self.photoButton) {
        
        self.videoButton.enabled = YES;
//        self.videoButton.backgroundColor = [UIColor colorWithRed:167.f/255.f green:205.f/225.f blue:230.f/225.f alpha:1];
//        self.videoButton.backgroundColor = [UIColor clearColor];
//        self.photoButton.backgroundColor = [UIColor colorWithRed:68.f/255.f green:108.f/225.f blue:169.f/225.f alpha:1];
//        self.photoButton.backgroundColor = [UIColor brownColor];
        self.photoButton.selected = YES;
        self.videoButton.selected = NO;
    }else if (sender == self.videoButton){
        
        self.photoButton.enabled = YES;
//        self.videoButton.backgroundColor = [UIColor colorWithRed:68.f/255.f green:108.f/225.f blue:169.f/225.f alpha:1];
//        self.videoButton.backgroundColor = [UIColor brownColor];
//        self.photoButton.backgroundColor = [UIColor colorWithRed:167.f/255.f green:205.f/225.f blue:230.f/225.f alpha:1];
//        self.photoButton.backgroundColor = [UIColor clearColor];
        self.videoButton.selected = YES;
        self.photoButton.selected = NO;
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    CGFloat offsetX = scrollView.contentOffset.x;
    if (offsetX == 0) {
        
        [self updateUIWithFileTypeButton:self.videoButton];
        
    }else{
        
        [self updateUIWithFileTypeButton:self.photoButton];
    }
    
    [self resetSelectButtons];
}

#pragma mark - actions

- (IBAction)clickSwitchFileTypeButton:(UIButton *)sender {
    
    [self updateUIWithFileTypeButton:sender];
    
    CGFloat offsetX = 0.f;
    if (sender == self.photoButton){
        
        CGFloat scrollViewWidth = CGRectGetWidth(self.scrollView.frame);
        offsetX = scrollViewWidth;
    }
    CGPoint offset = self.scrollView.contentOffset;
    offset.x = offsetX;
    [UIView animateWithDuration:0.3 animations:^{
        
        self.scrollView.contentOffset = offset;
    }];
    
    [self resetSelectButtons];
}


- (IBAction)clickQuitButton:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickSelectButton:(UIButton *)sender {
    
    [self switchSelectButtons];
    CGFloat offsetX = self.scrollView.contentOffset.x;
    if (offsetX == 0) {
        
        APKCollectVideosViewController *videosVC = self.childViewControllers.firstObject;
        videosVC.selectMode = !videosVC.selectMode;
        
    }else{
        
        APKCollectPhotosViewController *photosVC = self.childViewControllers.lastObject;
        photosVC.selectMode = !photosVC.selectMode;
    }
}

- (IBAction)clickCheckAllButton:(UIButton *)sender {
    
    CGFloat offsetX = self.scrollView.contentOffset.x;
    if (offsetX == 0) {
        
        APKCollectVideosViewController *videosVC = self.childViewControllers.firstObject;
        videosVC.checkAll = !videosVC.checkAll;

    }else{
        
        APKCollectPhotosViewController *photosVC = self.childViewControllers.lastObject;
        photosVC.checkAll = !photosVC.checkAll;
    }
}

@end
