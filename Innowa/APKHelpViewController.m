//
//  APKHelpViewController.m
//  Innowa
//
//  Created by Mac on 17/5/12.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKHelpViewController.h"
#import "APKHelpCell.h"
#import "previewSettingView.h"

static NSString *cellIdentifier = @"helpCell";

@interface APKHelpViewController ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSIndexPath *selectedIndexPath;
@property (strong,nonatomic) NSArray *dataSource;
@property (nonatomic,retain) UITextView *bottomTextView;
@end

@implementation APKHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = NSLocalizedString(@"设置", nil);
    self.subTitleLabel.text = NSLocalizedString(@"帮助", nil);

    self.tableView.estimatedRowHeight =   87;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.dataSource = @[
                               @{@"question":@"1.行车记录仪死机",@"answer":@"（1）按RESET重启后查看\n（2）存储卡是否损坏"},
                               @{@"question":@"2.行车记录仪无法开机",@"answer":@"（1）检查电源线连接是否正常\n（2）检查是否有插卡\n（3）检查开机键是否按下起效\n（4）按RESET重启后查看"}
                               ];
    
    self.tableView.tableFooterView =
    self.bottomTextView;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath == self.selectedIndexPath) {
        
        self.selectedIndexPath = nil;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }else{
        
        NSIndexPath *oldSelectedIndexPath = self.selectedIndexPath;
        self.selectedIndexPath = indexPath;
        
        NSArray *indexPaths = oldSelectedIndexPath ? @[indexPath,oldSelectedIndexPath] : @[indexPath];
        [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
}


#pragma mark -  UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    APKHelpCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSDictionary *info = self.dataSource[indexPath.row];
    NSString *questtion = NSLocalizedString(info[@"question"], nil);
    NSString *answer = NSLocalizedString(info[@"answer"], nil);
    cell.titleLabel.text = questtion;
    cell.contentLabel.text = indexPath == self.selectedIndexPath ? answer : nil;
    
    return cell;
}


#pragma mark - actions

- (IBAction)quit:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


-(UITextView *)bottomTextView {
    if (!_bottomTextView) {
        _bottomTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 60, 500, 100)];
        _bottomTextView.backgroundColor = [UIColor blackColor];
        _bottomTextView.editable = NO;//设置为不可编辑
        _bottomTextView.scrollEnabled = NO;
        _bottomTextView.delegate = self;//设置代理
        _bottomTextView.textContainerInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f);//控制距离上下左右的边距
        NSString *str = NSLocalizedString(@"如欲浏览更过常见问题，请按", nil);
        NSString *htmlString = [NSString stringWithFormat:@"<span style='color: #FFFFFF ;style='font-size:20px'>%@<a href='https://www.innowa.jp/gravitym1-faq' style='font-size:16px' style='color: #007aff; text-decoration: none'> %@ </a><span>",str,NSLocalizedString(@"此", nil)];
        //HTML格式的文本
        NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        NSMutableParagraphStyle *style = [attributedString attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:nil];
        style.alignment = NSTextAlignmentLeft;
        _bottomTextView.attributedText = attributedString;
    }
    return _bottomTextView;
}

@end
