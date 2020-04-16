//
//  APKAboutContentController.m
//  Innowa
//
//  Created by Mac on 17/10/10.
//  Copyright © 2017年 APK. All rights reserved.
//

#import "APKAboutContentController.h"

@interface APKAboutContentController ()

@end

@implementation APKAboutContentController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        
        CGFloat marginWidth = 20;
        CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds) - marginWidth * 2;
        NSDictionary *attrs = @{NSFontAttributeName : self.aboutLabel.font};
        CGRect rect = [self.aboutLabel.text boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attrs context:nil];
        CGFloat rowHeight = rect.size.height + marginWidth * 2 + 50;
        return rowHeight;
    }
    else if (indexPath.row == 1) {
        
        return 149;
    }
    else{
        
        return 109;
    }
}

@end
