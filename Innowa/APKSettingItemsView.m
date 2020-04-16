//
//  APKSettingItemsView.m
//  Innowa
//
//  Created by Mac on 17/5/11.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKSettingItemsView.h"
#import "APKSettingItemCell.h"

static NSString *cellIdentifier = @"settingItemCell";

@interface APKSettingItemsView ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property (strong,nonatomic) UIView *tableBackgroundView;
@property (strong,nonatomic) UITableView *tableView;
@property (weak,nonatomic) id<APKSettingItemsViewDelegate> delegate;

@end

@implementation APKSettingItemsView

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(APKSettingItemsView:didSelectItemAtIndex:)]) {
        [self.delegate APKSettingItemsView:self didSelectItemAtIndex:indexPath.row];
    }
    
    [self dismiss];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger count = 0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfItemsInAPKSettingItemsView:)]) {
        count = [self.delegate numberOfItemsInAPKSettingItemsView:self];
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    APKSettingItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    NSString *title = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(APKSettingItemsView:titleOfItemAtIndex:)]) {
        title = [self.delegate APKSettingItemsView:self titleOfItemAtIndex:indexPath.row];
    }
    
    cell.label.font = self.textFont;
    cell.label.text = title;
    return cell;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if (touch.view == gestureRecognizer.view) {
        
        return YES;
    }
    return NO;
}

#pragma mark - private method

- (void)addMotions{
    
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    tap.delegate = self;
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    swip.direction = UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
    [self addGestureRecognizer:tap];
    [self addGestureRecognizer:swip];
}

#pragma mark - public method

+ (instancetype)showInViewController:(UIViewController *)viewController delegate:(id<APKSettingItemsViewDelegate>)delegate anchorViewFrame:(CGRect)anchorViewFrame currentIndex:(NSInteger)currentIndex topLimit:(CGFloat)topLimit bottomLimit:(CGFloat)bottomLimit{

    APKSettingItemsView *settingItemsView = [[APKSettingItemsView alloc] init];
    settingItemsView.frame = viewController.view.window.bounds;
    settingItemsView.delegate = delegate;
    [viewController.view.window addSubview:settingItemsView];
    
    //添加手势
    [settingItemsView addMotions];
    
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.frame = anchorViewFrame;
    backgroundView.layer.shadowOffset = CGSizeMake(0, 2);
    backgroundView.layer.shadowOpacity = 0.80;
    [settingItemsView addSubview:backgroundView];
    settingItemsView.tableBackgroundView = backgroundView;
    
    UITableView *tableView = [[UITableView alloc] init];
    CGFloat rowHeight = CGRectGetHeight(anchorViewFrame) + 16;
    tableView.rowHeight = rowHeight;
    tableView.frame = backgroundView.bounds;
    tableView.dataSource = settingItemsView;
    tableView.delegate = settingItemsView;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UINib *nib = [UINib nibWithNibName:@"APKSettingItemCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    [backgroundView addSubview:tableView];
    settingItemsView.tableView = tableView;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentIndex inSection:0];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    //tableview最完美的高度
    NSInteger count = 0;
    if (delegate && [delegate respondsToSelector:@selector(numberOfItemsInAPKSettingItemsView:)]) {
        count = [delegate numberOfItemsInAPKSettingItemsView:settingItemsView];
    }
    CGFloat tableViewPerfectHeight = rowHeight * count;
    //tableBackgroundView的frame
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = CGRectGetWidth(anchorViewFrame);
    CGFloat height = 0;
    CGFloat space = 8;
    CGFloat selfHeight = CGRectGetHeight(settingItemsView.frame);
    CGFloat topSpace = anchorViewFrame.origin.y - topLimit;
    CGFloat bottomSpace = selfHeight - CGRectGetMaxY(anchorViewFrame) - bottomLimit;
    if (bottomSpace > topSpace) {
        
        x = anchorViewFrame.origin.x;
        y = CGRectGetMaxY(anchorViewFrame) + space;
        CGFloat maxHeight = bottomSpace - space * 2;
        if (tableViewPerfectHeight <= maxHeight) {
            height = tableViewPerfectHeight;
        }else{
            height = maxHeight;
        }
        
    }else{
        
        x = anchorViewFrame.origin.x;
        CGFloat maxHeight = topSpace - space * 2;
        if (tableViewPerfectHeight <= maxHeight) {
            height = tableViewPerfectHeight;
        }else{
            height = maxHeight;
        }
        y = anchorViewFrame.origin.y - height - space;
    }
    CGRect frame = CGRectMake(x, y, width, height);
    
    [UIView animateWithDuration:0.3 animations:^{
       
        backgroundView.frame = frame;
    }];
    
    
    return settingItemsView;
}

- (void)dismiss{
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.tableBackgroundView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
    }];
}

#pragma mark - setter

- (void)setTextFont:(UIFont *)textFont{
    
    _textFont = textFont;
    
    [self.tableView reloadData];
}


@end
