//
//  ViewerController.m
//  PicData
//
//  Created by Garenge on 2020/11/4.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "ViewerController.h"

@interface ViewerController ()

@end

@implementation ViewerController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)loadNavigationItem {
    self.navigationItem.title = @"浏览";
}

- (void)loadMainView {
    [super loadMainView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // 每次页面加载出来的时候, 需要当前目录名字
    NSString *directory = [[PDDownloadManager sharedPDDownloadManager] systemDownloadFullDirectory];
    self.navigationItem.title = [NSString stringWithFormat:@"浏览-%@", directory];

    NSFileManager *fileManager = [NSFileManager defaultManager];

    // 获取该目录下所有的文件夹和文件
    NSString *downloadPath = [[PDDownloadManager sharedPDDownloadManager] systemDownloadFullPath];

    NSError *subError = nil;
    NSArray *fileContents = [fileManager contentsOfDirectoryAtPath:downloadPath error:&subError];
    if (nil == subError) {
        NSLog(@"%@", fileContents);
    } else {
        NSLog(@"%@", subError);
    }
}

@end
