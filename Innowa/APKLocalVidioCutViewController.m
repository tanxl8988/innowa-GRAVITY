//
//  APKLocalVidioCutViewController.m
//  Innowa
//
//  Created by 李福池 on 2018/6/7.
//  Copyright © 2018年 APK. All rights reserved.
//

#import "APKLocalVidioCutViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "APKDownloadDVRFileTool.h"
#import "APKRefreshLocalFilesTool.h"
#import "APKDownloadDVRFileTool.h"

@interface APKLocalVidioCutViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIVideoEditorControllerDelegate>
@property (nonatomic,retain) UIVideoEditorController *editVC;
@property (nonatomic,assign) BOOL isDismissEditVC;
@property (nonatomic,retain) APKRefreshLocalFilesTool *refreshLocalFilesTool;
@property (nonatomic,retain) APKDownloadDVRFileTool *downloadTool;

@end

@implementation APKLocalVidioCutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    count = 0;
    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIVideoEditorController *editVC;
    if ([UIVideoEditorController canEditVideoAtPath:self.fileUrl]) {// 检查这个视频资源能不能被修改
        
        editVC = [[UIVideoEditorController alloc] init];
        editVC.videoPath = self.fileUrl;
        editVC.delegate = self;
        editVC.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;//720P
        
    }
    if (self.isDismissEditVC) {
        [self dismissViewControllerAnimated:NO completion:nil];
        return;
    }
    
    [self presentViewController:editVC animated:YES completion:nil];
    self.editVC = editVC;
}

//编辑成功后的Video被保存在沙盒的临时目录中
static int count = 0;
- (void)videoEditorController:(UIVideoEditorController *)editor didSaveEditedVideoToPath:(NSString *)editedVideoPath {
    
    NSLog(@"+++++++++++++++%@",editedVideoPath);
    if (count > 0) return;//解决重复保存的问题
    
    APKDVRFile *file = [APKDVRFile new];
    file.type = kAPKDVRFileTypeVidioEdit;
    NSArray *array = [self.localFile.name componentsSeparatedByString:@"."];
    NSString *fileName = [NSString stringWithFormat:@"%@_edit.MOV",array.firstObject];
    file.name = [NSString stringWithFormat:@"%@",fileName];
    file.date = self.localFile.saveDate;

    [self.downloadTool saveFile:file withUrl:[NSURL URLWithString:editedVideoPath] isVidioEdit:YES];
    
    count ++;
}


- (void)videoEditorController:(UIVideoEditorController *)editor didFailWithError:(NSError *)error {
    
    NSLog(@"%@",error.description);
}


- (void)videoEditorControllerDidCancel:(UIVideoEditorController *)editor {
    
    self.isDismissEditVC = YES;
    
    [self.editVC dismissViewControllerAnimated:NO completion:nil];
    
}

- (APKRefreshLocalFilesTool *)refreshLocalFilesTool{
    
    if (!_refreshLocalFilesTool) {
        _refreshLocalFilesTool = [APKRefreshLocalFilesTool sharedInstace];
    }
    return _refreshLocalFilesTool;
}

- (APKDownloadDVRFileTool *)downloadTool{
    
    if (!_downloadTool) {
        
        _downloadTool = [[APKDownloadDVRFileTool alloc] initWithManagedObjectContext:self.refreshLocalFilesTool.context];
    }
    
    return _downloadTool;
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
