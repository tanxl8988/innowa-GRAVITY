//
//  APKStepper.m
//  Innowa
//
//  Created by Mac on 17/5/17.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKStepper.h"
#import "APKStepperContentView.h"
#import "APKStepperCell.h"

static NSString *cellIdentifier = @"stepperCell";

@interface APKStepper ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic)  UIButton *increaseButton;
@property (weak, nonatomic)  UIButton *decreaseButton;
@property (weak, nonatomic)  UICollectionView *collectionView;
@property (weak, nonatomic)  UICollectionViewFlowLayout *flowLayout;
@property (strong,nonatomic) NSMutableArray *dataSource;

@end

@implementation APKStepper

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    
    //添加内容
    APKStepperContentView *contentView = [[[NSBundle mainBundle] loadNibNamed:@"APKStepperContentView" owner:self options:nil] firstObject];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    contentView.frame = self.bounds;
    [self addSubview:contentView];
    
    self.increaseButton = contentView.increaseButton;
    self.decreaseButton = contentView.decreaseButton;
    self.collectionView = contentView.collectionView;
    self.flowLayout = contentView.flowLayout;
    
    [self.increaseButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.decreaseButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];

    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    UINib *nib = [UINib nibWithNibName:@"APKStepperCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:cellIdentifier];
}

#pragma mark - getter

- (NSString *)value{
    
    if (self.dataSource.count == 0) {
        return @"0";
    }
    
    NSIndexPath *indexPath = self.collectionView.indexPathsForVisibleItems.firstObject;
    NSString *text = self.dataSource[indexPath.item];
    return text;
}

- (NSMutableArray *)dataSource{
    
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

#pragma mark - public method

- (void)configureWithMaxValue:(NSInteger)maxValue minValue:(NSInteger)minValue currentValue:(NSInteger)currentValue{
    
    if (minValue > maxValue || currentValue > maxValue || currentValue < minValue) {
        return;
    }
    
    [self.dataSource removeAllObjects];
    for (NSInteger i = minValue; i <= maxValue; i++) {
        
        NSString *text = [NSString stringWithFormat:@"%d",(int)i];
        [self.dataSource addObject:text];
    }
    
    [self.collectionView reloadData];
    NSInteger item = currentValue - minValue;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

#pragma mark - private method

- (void)clickButton:(UIButton *)sender{
    
    if (self.dataSource.count == 0) {
        return;
    }
    
    NSIndexPath *currentIndexPath = self.collectionView.indexPathsForVisibleItems.firstObject;
    NSInteger item = currentIndexPath.item;
    if (sender == self.increaseButton) {
        
        if (item != self.dataSource.count - 1) {
            item += 1;
        }
        
    }else if (sender == self.decreaseButton){
        
        if (item != 0) {
            item -= 1;
        }
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return collectionView.frame.size;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    APKStepperCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.label.text = self.dataSource[indexPath.item];
    return cell;
}

@end
