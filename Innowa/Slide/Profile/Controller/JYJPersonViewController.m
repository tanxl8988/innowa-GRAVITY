//
//  JYJPersonViewController.m
//  导航测试demo
//
//  Created by JYJ on 2017/6/5.
//  Copyright © 2017年 baobeikeji. All rights reserved.
//

#import "JYJPersonViewController.h"
#import "JYJMyWalletViewController.h"
#import "JYJMyCardViewController.h"
#import "JYJMyTripViewController.h"
#import "JYJMyFriendViewController.h"
#import "JYJMyStickerViewController.h"
#import "JYJCommenItem.h"
#import "JYJProfileCell.h"
#import "JYJPushBaseViewController.h"
#import "JYJAnimateViewController.h"
#import "APKCustomTabBarController.h"


@interface JYJPersonViewController () <UITableViewDelegate, UITableViewDataSource>
/** tableView */
@property (nonatomic, weak) UITableView *tableView;
/** headerIcon */
@property (nonatomic, weak) UIImageView *headerIcon;
/** data */
@property (nonatomic, strong) NSArray *data;//数据源

@property (nonatomic,retain) UILabel *headView;//头部视图
@end

@implementation JYJPersonViewController

- (NSArray *)data {
    if (!_data) {
        _data = @[@[],@[],@[],@[],@[]];
    }
    return _data;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableView.frame = self.view.bounds;
    self.headerIcon.frame = CGRectMake(self.tableView.frame.size.width / 2 - 36, 39, 72, 72);
}

- (void)setupUI {
    UITableView *tableView = [[UITableView alloc] init];
    tableView.scrollEnabled = YES;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSelectionStyleGray;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.tableFooterView = [UIView new];
    tableView.tableHeaderView = self.headView;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    
}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}


-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSArray *nameArray = @[@"Live View",@"Gallery Local",@"Gallery DVR",@"Setting",@"FAQ"];
    
    UIButton *headBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
    
    [headBtn setTitle:nameArray[section] forState:UIControlStateNormal];
    
    headBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    headBtn.contentEdgeInsets = UIEdgeInsetsMake(0,10, 0, 0);
    
//    headBtn.titleLabel.textColor = [UIColor colorWithRed:12.0/255.0 green:155.0/255.0 blue:222.0/255.0 alpha:1];
    headBtn.titleLabel.textColor = [UIColor brownColor];
    [headBtn setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    
//    [headBtn setTitleColor:[UIColor colorWithRed:12.0/255.0 green:155.0/255.0 blue:222.0/255.0 alpha:1] forState:UIControlStateNormal];
    
    headBtn.tag = 100 + section;
    
    [headBtn addTarget:self action:@selector(sectionHeaderBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return headBtn;
    
}

-(void)sectionHeaderBtnClick:(UIButton*)btn
{
    if (btn.tag == 100) {
        
        APKCustomTabBarController *tabBarVC = self.tabVC;
        
        [tabBarVC.customTabBar selectButtonWithIndex:0];
        
        [self.fontVC closeAnimation];
        
    }else if (btn.tag == 101)
    {
        
        NSArray *array = self.data[btn.tag - 100];
        
        self.data = array.count > 0 ? @[@[],@[],@[],@[],@[]] : @[@[],@[@"Normal",@"Event",@"Parking Time Lapse",@"Parking Event",@"Picture"],@[],@[],@[]];
        
        [self.tableView reloadData];
        
    }else if(btn.tag == 102)
    {
        NSArray *array = self.data[btn.tag - 100];
        
        self.data = array.count > 0 ? @[@[],@[],@[],@[],@[]] : @[@[],@[],@[@"Normal",@"Event",@"Parking Time Lapse",@"Parking Event",@"Picture"],@[],@[]];
        
        [self.tableView reloadData];
        
    }else if(btn.tag == 103)
    {
        APKCustomTabBarController *tabBarVC = self.tabVC;
        
        [tabBarVC.customTabBar selectButtonWithIndex:2];
        
         [self.fontVC closeAnimation];
    }else
    {
        
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *name = self.data[section];
    
    return name.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    JYJProfileCell* tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];

    if (tableViewCell == nil) {
        //创建一个UITableViewCell对象，并绑定到cellID
        tableViewCell = [[JYJProfileCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellID"];
    }
    tableViewCell.item = self.data[indexPath.section][indexPath.row];
    return tableViewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


-(UILabel*)headView
{
    if (!_headView) {
        _headView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 66)];
        _headView.text = @"   Menu";
        _headView.backgroundColor = [UIColor colorWithRed:12.0/255.0 green:155.0/255.0 blue:222.0/255.0 alpha:1];
        _headView.backgroundColor = [UIColor brownColor];
        _headView.textColor = [UIColor whiteColor];
    }
    
    return _headView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
