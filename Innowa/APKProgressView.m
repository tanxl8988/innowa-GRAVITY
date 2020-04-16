//
//  APKBarChart.m
//  Innowa
//
//  Created by Mac on 17/5/15.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKProgressView.h"

@interface APKProgressView ()

@property (strong,nonatomic) UIView *contentView;
@property (strong,nonatomic) CALayer *progressLayer;
@property (assign) CGFloat maxContentWidth;
@property (strong,nonatomic) UIColor *costomColor;

@end

@implementation APKProgressView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    
    self.progress = 0.f;
    self.costomColor = [UIColor colorWithRed:170.f/255.f green:121.f/255.f blue:66.f/255.f alpha:1];;
    
    self.backgroundColor = self.costomColor;
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.progressLayer = [CALayer layer];
    self.progressLayer.backgroundColor = self.costomColor.CGColor;
    [self.contentView.layer addSublayer:self.progressLayer];
    [self addSubview:self.contentView];
}

- (void)layoutSubviews{
    
    [super layoutSubviews];

    CGFloat lineWidth = 2.f;
    CGFloat contentWidth = CGRectGetWidth(self.frame) - lineWidth * 2;
    CGFloat contentHeight = CGRectGetHeight(self.frame) - lineWidth * 2;
    
    self.contentView.frame = CGRectMake(lineWidth, lineWidth, contentWidth, contentHeight);
    
    self.maxContentWidth = contentWidth;
    self.progressLayer.frame = CGRectMake(0, 0, self.maxContentWidth * self.progress, contentHeight);
}

#pragma mark - setter

- (void)setProgress:(CGFloat)progress{
    
    _progress = progress;
    
    CGRect frame = self.progressLayer.frame;
    frame.size.width = self.maxContentWidth * progress;
    self.progressLayer.frame = frame;
}

@end
