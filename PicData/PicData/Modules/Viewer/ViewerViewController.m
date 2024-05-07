//
//  ViewerViewController.m
//  PicData
//
//  Created by 鹏鹏 on 2020/11/22.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "ViewerViewController.h"
#import <QuickLook/QuickLook.h>

@interface ViewerViewController () <QLPreviewControllerDataSource, QLPreviewControllerDelegate>

/** 预览文件的时候用 */
/** 主view */
@property(nonatomic, strong) QLPreviewController *preview;

// 预览文件资源路径
@property(nonatomic, strong) NSURL *fileURL;
// 解决txt乱码需创建一个临时文件  页面退出通过协议方法删除临时文件
@property(nonatomic, strong) NSString *tmpFilePath;

@end

@implementation ViewerViewController

- (NSString *)getNaviTitle:(NSString *)defaultTitle {
    if (self.filePath.length > 0) {
        return self.filePath.lastPathComponent;
    } else {
        return defaultTitle;
    }
}

- (void)loadNavigationItem {
    self.navigationItem.title = [self getNaviTitle:@"文件"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(shareToOtherAction:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 44, 44);
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)shareToOtherAction:(UIButton *)sender {

    [AppTool shareFileWithURLs:@[self.fileURL] sourceView:sender completionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        NSLog(@"调用分享的应用id :%@", activityType);
        if (completed) {
            NSLog(@"分享成功!");
        } else {
            NSLog(@"分享失败!");
        }
    }];
}

- (void)loadMainView {
    self.view.backgroundColor = UIColor.whiteColor;
    QLPreviewController *preview = [[QLPreviewController alloc] init];
    preview.dataSource = self;
    preview.delegate = self;
    [self addChildViewController:preview];
    preview.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    preview.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:preview.view];

    [preview.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(10, 10, 10, 10));
    }];

    self.preview = preview;

    for (UIView *view in self.preview.view.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"QLErrorView")]) {
            view.hidden = YES;
        }
        NSLog(@"%@", view);
    }

    self.fileURL = [self getPreviewFileURLWithFilePath:self.filePath];
    [self.preview reloadData];
}

#pragma mark 获取预览文件URL

- (NSURL *)getPreviewFileURLWithFilePath:(NSString *)filePath {
    NSURL *fileURL = nil;
    if (nil != filePath) {
        // 解决txt中文乱码问题
        if ([filePath.lowercaseString hasSuffix:@".txt"]) {
            NSStringEncoding *useEncodeing = nil;
            // 优先读取带编码头，例如utf-8
            // 其次以GBK编码读取 再次以GB18030编码读取 (注：不能先按GB18030解码 否则会出现整个文档无换行bug)
            NSString *txtString = [NSString stringWithContentsOfFile:filePath usedEncoding:useEncodeing error:nil];
            if (nil == txtString) {
                txtString = [NSString stringWithContentsOfFile:filePath encoding:0x80000632 error:nil];
            }
            if (nil == txtString) {
                txtString = [NSString stringWithContentsOfFile:filePath encoding:0x80000631 error:nil];
            }
            if (txtString) {
                if (nil == _tmpFilePath) {
                    NSString *tmpFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSString alloc] initWithFormat:@"%@", [self getNaviTitle:@"viewerTemp.txt"]]];

                    _tmpFilePath = tmpFilePath;
                    [[NSFileManager defaultManager] createFileAtPath:tmpFilePath contents:nil attributes:nil];
                }
                [txtString writeToFile:_tmpFilePath atomically:YES encoding:NSUTF16StringEncoding error:nil];
                fileURL = [NSURL fileURLWithPath:_tmpFilePath];
            }
        } else {
            fileURL = [NSURL fileURLWithPath:filePath];
        }
    }
    return fileURL;
}


#pragma mark - 协议相关方法
#pragma mark QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return (self.fileURL) ? 1 : 0;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return self.fileURL;
}

#pragma mark QLPreviewControllerDelegate

- (void)previewControllerWillDismiss:(QLPreviewController *)controller {
    if (_tmpFilePath) {
        [[NSFileManager defaultManager] removeItemAtPath:_tmpFilePath error:nil];
    }
}

- (void)dealloc {
    // 清除协议对象
    self.preview.delegate = nil;
    self.preview.dataSource = nil;
    if (_tmpFilePath) {
        [[NSFileManager defaultManager] removeItemAtPath:_tmpFilePath error:nil];
    }
}

@end
