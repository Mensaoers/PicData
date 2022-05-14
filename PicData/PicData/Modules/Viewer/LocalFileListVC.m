//
//  LocalFileListVC.m
//  PicData
//
//  Created by Garenge on 2020/11/4.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "LocalFileListVC.h"
#import "ViewerViewController.h"
#import "PicBrowserToolViewHandler.h"

@interface LocalFileListVC () <UICollectionViewDelegate, UICollectionViewDataSource, YBImageBrowserDelegate>

@property (nonatomic, strong) ViewerContentView *contentView;
@property (nonatomic, strong) NSMutableArray <ViewerFileModel *>*fileNamesList;
@property (nonatomic, strong) NSMutableArray *imgsList;

@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) PicContentModel *contentModel;

@property (nonatomic, weak) YBImageBrowser *browser;

@property (nonatomic, assign) NSInteger lastViewIndex;

@end

@implementation LocalFileListVC

// TODO: 不能根据导航层数判断按钮显示, 后期需要在其他地方弹出本地文件界面

- (PicContentModel *)contentModel {
    if (nil == _contentModel) {
        NSArray *result = [PicContentTaskModel queryTableWithTitle:[self.targetFilePath lastPathComponent]];
        if (result.count > 0) {
            _contentModel = result[0];
        }
    }
    return _contentModel;
}

- (NSMutableArray<ViewerFileModel *> *)fileNamesList {
    if (nil == _fileNamesList) {
        _fileNamesList = [NSMutableArray array];
    }
    return _fileNamesList;
}

- (NSMutableArray *)imgsList {
    if (nil == _imgsList) {
        _imgsList = [NSMutableArray array];
    }
    return _imgsList;
}

- (NSString *)systemDownloadFullPath {
    return [[PDDownloadManager sharedPDDownloadManager] systemDownloadFullPath];
}
- (NSString *)targetFilePath {
    if (nil == _targetFilePath) {
        _targetFilePath = [self systemDownloadFullPath];
    }
    return _targetFilePath;
}

- (void)loadNavigationItem {

    NSMutableArray *leftBarButtonItems = [NSMutableArray array];
    if (self.navigationController.viewControllers.count > 1) {
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(backAction:)];
        [leftBarButtonItems addObject:backItem];
    }
    // mac端也允许整理按钮, 加警告框即可
    UIBarButtonItem *arrangeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"ellipsis"] style:UIBarButtonItemStyleDone target:self action:@selector(arrangeItemClickAction:)];
    [leftBarButtonItems addObject:arrangeItem];

#if TARGET_OS_MACCATALYST

    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"arrow.clockwise"] style:UIBarButtonItemStyleDone target:self action:@selector(refreshItemClickAction:)];
    [leftBarButtonItems addObject:refreshItem];

#endif

    self.navigationItem.leftBarButtonItems = leftBarButtonItems;

    NSMutableArray *items = [NSMutableArray array];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareAllFiles:) forControlEvents:UIControlEventTouchUpInside];
    shareButton.frame = CGRectMake(0, 0, 25, 25);
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    [items addObject:shareItem];
    
    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStyleDone target:self action:@selector(clearAllFiles)];
    [items addObject:deleteItem];

    if (self.navigationController.viewControllers.count >= 2) {
        if ([self.targetFilePath containsString:likeString]) {
            // 我已经是收藏文件夹了
        } else {
            UIBarButtonItem *likeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"like"] style:UIBarButtonItemStyleDone target:self action:@selector(likeAllFiles)];
            [items addObject:likeItem];
        }
    }
    
    self.navigationItem.rightBarButtonItems = items;
}

- (void)backAction:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadMainView {
    [super loadMainView];
    
    self.view.backgroundColor = BackgroundColor;
    
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.textColor = UIColor.lightGrayColor;
    contentLabel.numberOfLines = 0;
    [self.view addSubview:contentLabel];
    self.contentLabel = contentLabel;
    
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(24);
        make.right.mas_equalTo(-24);
        make.top.mas_equalTo(8);
    }];

    ViewerContentView *contentView = [ViewerContentView collectionView:self.view.mj_w];
    contentView.delegate = self;
    contentView.dataSource = self;
    [self.view addSubview:contentView];

    self.contentView = contentView;

    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentLabel.mas_bottom);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.equalTo(self.view.mas_bottomMargin).with.offset(0);
    }];

    contentView.layer.cornerRadius = 4;
    contentView.layer.masksToBounds = YES;

    PDBlockSelf
    contentView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf refreshLoadData:NO];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self refreshLoadData:NO];
    [self loadNavigationItem];
}

- (void)refreshLoadData:(BOOL)needFileSize {

    // 每次页面加载出来的时候, 需要当前目录名字
    NSString *directory = [self.targetFilePath lastPathComponent];
    self.contentLabel.text = [[NSString stringWithFormat:@"%@", directory] stringByReplacingOccurrencesOfString:@":" withString:@"/"];

    NSFileManager *fileManager = [NSFileManager defaultManager];

    // 获取该目录下所有的文件夹和文件
    NSError *subError = nil;
    NSMutableArray *fileContents = [[fileManager contentsOfDirectoryAtPath:self.targetFilePath error:&subError] mutableCopy];
    // 文件夹排序
    [fileContents sortUsingSelector:@selector(localizedStandardCompare:)];
    if (nil == subError) {
        // NSLog(@"%@", fileContents);

        [self.fileNamesList removeAllObjects];
        for (NSString *fileName in fileContents) {

            if ([fileName isEqualToString:@".DS_Store"]) {
                continue;
            }

            NSString *filePath = [self.targetFilePath stringByAppendingPathComponent:fileName];
            if ([PPFileManager isDirectory:filePath]) {
                ViewerFileModel *fileModel = [ViewerFileModel modelWithName:fileName isFolder:YES];

                NSString *dirPath = filePath;
                NSError *subError = nil;
                NSArray *subFileContents = [fileManager contentsOfDirectoryAtPath:dirPath error:&subError];

                // 获取大小的代码, 节约资源(有明显卡顿)
                if (needFileSize) {
                    NSEnumerator *childFilesEnumerator = [[fileManager subpathsAtPath:dirPath] objectEnumerator];
                    NSString *subFileName = nil;
                    long long folderSize = 0;
                    while ((subFileName = [childFilesEnumerator nextObject]) != nil) {
                        NSString *fileAbsolutePath = [dirPath stringByAppendingPathComponent:subFileName];
                        folderSize += [self getFileSize:fileAbsolutePath];
                    }

                    fileModel.fileSize = folderSize > 0 ? folderSize : 0;
                }
                fileModel.fileCount = subFileContents.count;
                if (self.fileNamesList.count > 0 && fileModel.fileCount < 2) {
                    [self.fileNamesList insertObject:fileModel atIndex:0];
                } else {
                    [self.fileNamesList addObject:fileModel];
                }
            } else {
                ViewerFileModel *fileModel = [ViewerFileModel modelWithName:fileName isFolder:NO];
                [self.fileNamesList addObject:fileModel];
            }
        }

        self.navigationItem.title = [NSString stringWithFormat:@"%ld", self.fileNamesList.count];
        [self.contentView reloadData];
    } else {
        NSLog(@"%@", subError);
    }
    [self.contentView.mj_header endRefreshing];

    self.lastViewIndex = 0;
}

- (long long)getFileSize:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:path error:nil];
        NSNumber *fileSize;
        if ((fileSize = [attributes objectForKey:NSFileSize]))
            return [fileSize longLongValue];
        else
            return -1;
    } else {
        return -1;
    }
}

- (void)shareAllFiles:(UIButton *)sender {
    NSMutableArray *actions = [NSMutableArray array];
#if TARGET_OS_MACCATALYST

    [actions addObject:[UIAlertAction actionWithTitle:@"在本地显示" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [AppTool shareFileWithURLs:@[[NSURL fileURLWithPath:self.targetFilePath]] sourceView:sender completionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {

        }];
    }]];
#endif

    if (self.contentModel) {
        [actions addObject:[UIAlertAction actionWithTitle:@"分享链接" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            if (self.contentModel == nil) {
                [MBProgressHUD showInfoOnView:self.view WithStatus:@"未找到套图链接"];
                return;
            }

            [AppTool shareFileWithURLs:@[[NSURL URLWithString:[self.contentModel.HOST_URL stringByAppendingString:self.contentModel.href]]] sourceView:sender completionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
                NSLog(@"调用分享的应用id :%@", activityType);
                if (completed) {
                    NSLog(@"分享成功!");
                } else {
                    NSLog(@"分享失败!");
                }
            }];
        }]];


        [actions addObject:[UIAlertAction actionWithTitle:@"PDF长图分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self sharePDF:sender];
        }]];
    }

    [actions addObject:[UIAlertAction actionWithTitle:@"直接分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        /// 压缩之后弹出分享框
        [AppTool shareFileWithURLs:@[[NSURL fileURLWithPath:self.targetFilePath]] sourceView:sender completionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {

            if (completed) {
                NSLog(@"分享成功!");
            } else {
                NSLog(@"分享失败!");
            }
        }];
    }]];

    [actions addObject:[UIAlertAction actionWithTitle:@"压缩分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self shareZip:sender];
    }]];

    [actions addObject:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self showAlertWithTitle:nil message:@"分享文件" actions:actions];
}

#pragma mark pdf
/// 长图
- (void)sharePDF:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"创建并分享PDF" message:@"此操作会将文件夹下所有图片按当前顺序生成PDF文件, 是否继续?" preferredStyle:UIAlertControllerStyleAlert];

    NSString *targetName = [NSString stringWithFormat:@"%@.pdf", [self.targetFilePath lastPathComponent]];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.placeholder = targetName;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.placeholder = @"密码选填";
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"创建PDF" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {\

        NSString *fileName = alert.textFields[0].text;
        if (fileName.length == 0 || [fileName stringByDeletingPathExtension].length == 0) {
            fileName = targetName;
        } else {
            if (![fileName.pathExtension.lowercaseString isEqualToString:@"pdf"]) {
                fileName = [fileName stringByAppendingPathExtension:@"pdf"];
            }
        }
        [self generatePDF:fileName password:alert.textFields[1].text sourceView:sender];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

/// 生成长图
- (void)generatePDF:(NSString *)fileName password:(NSString *)passsword sourceView:(UIButton *)sourceView {
    PDBlockSelf
    [MBProgressHUD showHUDAddedTo:[AppTool getAppKeyWindow] animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        // 临时文件
        NSString *pdfPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];

        [LGPdf createPdfWithImageCount:weakSelf.fileNamesList.count width:A4_L sepmargin:0 pdfPath:pdfPath password:passsword minWidth:10 enmuHandler:^UIImage * _Nullable(NSInteger index) {
            ViewerFileModel *tempModel = weakSelf.fileNamesList[index];
            if ([PPFileManager isFileTypePicture:tempModel.fileName.pathExtension]) {
                UIImage *image = [UIImage imageWithContentsOfFile:[weakSelf.targetFilePath stringByAppendingPathComponent:tempModel.fileName]];
                return image;
            } else {
                return nil;
            }
        }];

        dispatch_async(dispatch_get_main_queue(), ^{

            [MBProgressHUD hideHUDForView:[AppTool getAppKeyWindow] animated:YES];
            [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"创建PDF成功" afterDelay:1];

#if TARGET_OS_MACCATALYST
            [AppTool shareFileWithURLs:@[[NSURL fileURLWithPath:pdfPath]] sourceView:sourceView completionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {

            }];

#else
            ViewerViewController *viewerVC = [[ViewerViewController alloc] init];
            viewerVC.filePath = pdfPath;
            viewerVC.backBlock = ^(NSString * _Nonnull filePath) {

                PDBlockSelf
                [weakSelf showAlertWithTitle:@"删除文件" message:@"是否需要删除该pdf文件以节省空间" confirmTitle:@"删掉吧" confirmHandler:^(UIAlertAction * _Nonnull action) {
                    // 不分享了, 那得删了临时数据
                    NSError *rmError = nil;
                    [[NSFileManager defaultManager] removeItemAtPath:pdfPath error:&rmError];
                    if (rmError) {
                        NSLog(@"删除文件失败: %@", rmError);
                    } else {
                        [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"移除成功" afterDelay:1];
                    }
                } cancelTitle:@"取消" cancelHandler:nil];
            };
            [weakSelf.navigationController pushViewController:viewerVC animated:YES needHiddenTabBar:YES];
#endif
        });
    });
}

#pragma mark zip
// zip
- (void)shareZip:(UIButton *)sender {
    PDBlockSelf
    NSString *targetPathName = [NSString stringWithFormat:@"%@.zip", [self.targetFilePath lastPathComponent]];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"分享文件" message:@"请输入压缩包的名字, 默认为文件夹名称, 密码选填" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.placeholder = targetPathName;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.placeholder = @"密码选填";
    }];

    [alert addAction:[UIAlertAction actionWithTitle:@"去压缩" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        UITextField *zipNameTF = alert.textFields[0];
        NSString *zipNameTFText = zipNameTF.text;
        UITextField *pwdNameTF = alert.textFields[1];
        NSString *pwdNameTFText = pwdNameTF.text;

        /// 创建压缩包
        [weakSelf createZipWithTargetPathName:targetPathName ZipNameTFText:zipNameTFText pwdNameTFText:pwdNameTFText sourceView:sender];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

/// 创建压缩包
- (void)createZipWithTargetPathName:(NSString *)targetPathName ZipNameTFText:(NSString *)zipNameTFText pwdNameTFText:(NSString *)pwdNameTFText sourceView:(UIView *)sourceView {

    PDBlockSelf
    [MBProgressHUD showHUDAddedTo:[AppTool getAppKeyWindow] animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 压缩文件
        NSString *zippedFileName;
        if (zipNameTFText.length == 0 || [zipNameTFText stringByDeletingPathExtension].length == 0) {
            zippedFileName = targetPathName;
        } else {
            if ([zipNameTFText.pathExtension.lowercaseString isEqualToString:@"zip"]) {
                // 用户已经写好了".zip"
                zippedFileName = zipNameTFText;
            } else {
                // 用户没写, 我补上
                zippedFileName = [zipNameTFText stringByAppendingPathExtension:@"zip"];
            }
        }

        NSString *zippedPath = [NSTemporaryDirectory() stringByAppendingPathComponent:zippedFileName];
        BOOL zipResult = [SSZipArchive createZipFileAtPath:zippedPath withContentsOfDirectory:weakSelf.targetFilePath keepParentDirectory:YES withPassword:pwdNameTFText.length > 0 ? pwdNameTFText : nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (zipResult) {
                // 压缩成功
                [MBProgressHUD hideHUDForView:[AppTool getAppKeyWindow] animated:YES];
                [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"压缩成功" afterDelay:1];

                /// 压缩之后弹出分享框
                [AppTool shareFileWithURLs:@[[NSURL fileURLWithPath:zippedPath]] sourceView:sourceView completionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {

                    if (completed) {
                        NSLog(@"分享成功!");
                    } else {
                        NSLog(@"分享失败!");
                    }
                    // 不分享了, 那得删了临时数据
                    NSError *rmError = nil;
                    [[NSFileManager defaultManager] removeItemAtPath:zippedPath error:&rmError];
                    if (rmError) {
                        NSLog(@"删除文件失败: %@", rmError);
                    }
                }];
            } else {
                [MBProgressHUD hideHUDForView:[AppTool getAppKeyWindow] animated:YES];
                [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"压缩失败" afterDelay:1];
            }
        });

    });
}

- (void)arrangeItemClickAction:(UIBarButtonItem *)sender {

    PDBlockSelf
    NSMutableArray *actions = [NSMutableArray array];
    if (self.contentModel) {
        [actions addObject:[UIAlertAction actionWithTitle:@"重新下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf reDownloadContents];
        }]];
    }
    [actions addObject:[UIAlertAction actionWithTitle:@"一键重命名" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
        [weakSelf renameAllPicturesOfDirectoryAtPath:self.targetFilePath];
        [weakSelf refreshLoadData:NO];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"重命名完成" afterDelay:1];
    }]];

    if (nil == self.contentModel) {
        [actions addObject:[UIAlertAction actionWithTitle:@"仅刷新文件夹大小" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            [weakSelf refreshLoadData:YES];
        }]];

        [actions addObject:[UIAlertAction actionWithTitle:@"清空无图文件夹" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            [weakSelf arrangeAllFiles];
        }]];
    }
    [actions addObject:[UIAlertAction actionWithTitle:@"清空所有文本文档" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
        [weakSelf deleteAllTextFiles:self.targetFilePath];
        [weakSelf refreshLoadData:NO];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"清空文本完成" afterDelay:1];
    }]];
    [actions addObject:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self showAlertWithTitle:@"整理文件夹" message:@"该操作可能会删除本地文件(夹), 重要文件请再三确认" actions:actions];
}

- (void)refreshItemClickAction:(UIBarButtonItem *)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self refreshLoadData:NO];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

/// 清空所有文本文档
- (void)deleteAllTextFiles:(NSString *)dirPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // 列举所有文件
    NSError *subError = nil;
    NSArray *targetPathExtension = @[@"txt"];
    NSArray *fileContents = [fileManager contentsOfDirectoryAtPath:dirPath error:&subError];
    if (subError) {
        return;
    }
    for (NSString *fileName in fileContents) {

        NSString *filePath = [dirPath stringByAppendingPathComponent:fileName];
        if ([PPFileManager isDirectory:filePath]) {
            // 这是个文件夹
            [self deleteAllTextFiles:filePath];
            continue;
        }

        // 如果这个文件是含有"-"的图片, 我们就来改一下文件名
        if ([targetPathExtension containsObject:fileName.pathExtension.lowercaseString]) {

            NSLog(@"找到一个文本文档: %@", filePath);
            NSError *rmError = nil;
            [fileManager removeItemAtPath:filePath error:&rmError];
            if (rmError) {
                NSLog(@"删除文档失败: %@, error: %@", filePath, rmError.description);
            }
        }
    }
}

/// 一键重命名各个图片
- (void)renameAllPicturesOfDirectoryAtPath:(NSString *)dirPath {

    NSFileManager *fileManager = [NSFileManager defaultManager];

    // 列举所有文件
    NSError *subError = nil;
    NSArray *targetPathExtension = @[@"jpg", @"jpeg", @"png"];
    NSArray *fileContents = [fileManager contentsOfDirectoryAtPath:dirPath error:&subError];
    if (subError) {
        return;
    }
    for (NSString *fileName in fileContents) {

        NSString *filePath = [dirPath stringByAppendingPathComponent:fileName];
        if ([PPFileManager isDirectory:filePath]) {
            // 这是个文件夹
            [self renameAllPicturesOfDirectoryAtPath:filePath];
            continue;
        }

        // 如果这个文件是含有"-"的图片, 我们就来改一下文件名
        if ([targetPathExtension containsObject:fileName.pathExtension.lowercaseString] && [fileName containsString:@"-"]) {

            // 1. 获取类型
            NSString *pathExtension = fileName.pathExtension;
            NSString *fileNameWithoutP = fileName.stringByDeletingPathExtension;
            if (fileNameWithoutP.length == 0) { continue; }

            NSString *regex = @"(?<=-).*?(?=-)";
            NSError *error;
            NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
            // 对str字符串进行匹配
            NSString *fileNameWithoutPAfter = [fileNameWithoutP substringWithRange:[regular firstMatchInString:fileNameWithoutP options:0 range:NSMakeRange(0, fileNameWithoutP.length)].range];
            if (fileNameWithoutPAfter.length == 0) {
                continue;
            }

            NSString *fileNameAfter = [fileNameWithoutPAfter stringByAppendingPathExtension:pathExtension];

            if ([fileManager fileExistsAtPath:[dirPath stringByAppendingPathComponent:fileNameAfter]]) {
                NSLog(@"目标文件%@已存在", fileNameAfter);
                [fileManager removeItemAtPath:filePath error:nil];
                continue;
            }


            NSString *afterPath = [dirPath stringByAppendingPathComponent:fileNameAfter];

            NSError *copyError = nil;
            [fileManager moveItemAtPath:filePath toPath:afterPath error:&copyError];
            if (copyError) {
                NSLog(@"移动文件夹下%@失败", fileName);
                continue;
            }
        }
    }

}

/// 重新下载
- (void)reDownloadContents {
    PicContentModel *contentModel = self.contentModel;
    if (nil == contentModel) {
        [MBProgressHUD showInfoOnView:self.view WithStatus:@"找不到该套图的下载记录" afterDelay:1];
        return;
    }
    PicSourceModel *sourceModel = [[PicSourceModel queryTableWithUrl:contentModel.sourceHref] firstObject];
    if (nil == sourceModel) {
        [MBProgressHUD showInfoOnView:self.view WithStatus:@"找不到数据源" afterDelay:1];
        return;
    }
    if (![PicContentTaskModel deleteFromTableWithTitle:contentModel.title]) {
        [MBProgressHUD showInfoOnView:self.view WithStatus:@"删除原下载记录失败" afterDelay:1];
        return;
    }
    MJWeakSelf
    [ContentParserManager tryToAddTaskWithSourceModel:sourceModel ContentModel:contentModel operationTips:^(BOOL isSuccess, NSString * _Nonnull tips) {
        [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:tips afterDelay:1];
    }];
}

- (void)arrangeAllFiles {

    PDBlockSelf
    [self showAlertWithTitle:@"清空无图文件夹" message:@"该操作会删除该目录下空文件夹, 且不可恢复, 确定要整理吗?" confirmTitle:@"确认删除" confirmHandler:^(UIAlertAction * _Nonnull action) {
        BOOL isRoot = [weakSelf.targetFilePath isEqualToString:[[PDDownloadManager sharedPDDownloadManager] systemDownloadFullPath]];

        [MBProgressHUD showHUDAddedTo:[AppTool getAppKeyWindow] animated:YES];

        NSFileManager *fileManager = [NSFileManager defaultManager];
        for (ViewerFileModel *fileModel in weakSelf.fileNamesList) {
            if (!fileModel.isFolder) {
                continue;
            }
            NSString *dirPath = [weakSelf.targetFilePath stringByAppendingPathComponent:fileModel.fileName];
            NSError *subError = nil;
            NSArray *fileContents = [fileManager contentsOfDirectoryAtPath:dirPath error:&subError];
            BOOL isEmptyF = YES;
            for (NSString *fileName in fileContents) {
                NSString *pathExtension = fileName.pathExtension;
                if (isRoot) {
                    // 根目录整理, 移除没有文件夹的子项目
                    if ([PPFileManager isFileTypeDocAndPic:pathExtension]) {

                    } else {
                        isEmptyF = NO;
                    }
                } else {
                    // 图库整理, 移除没有图片的子项目
                    if ([PPFileManager isFileTypePicture:pathExtension]) {
                        isEmptyF = NO;
                    }
                }
            }
            if (isEmptyF) {
                // 没有文件夹, 干掉
                NSError *rmError = nil;
                [fileManager removeItemAtPath:dirPath error:&rmError];
            }
        }
        [weakSelf refreshLoadData:YES];

        [MBProgressHUD hideHUDForView:[AppTool getAppKeyWindow] animated:YES];
        [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"整理完成" afterDelay:1];
    } cancelTitle:@"取消" cancelHandler:nil];
}

- (void)clearAllFiles {
    PDBlockSelf
    [self showAlertWithTitle:@"提醒" message:@"确定清空所有文件吗?(该目录也将一并清除), 该过程不可逆" confirmTitle:@"确定" confirmHandler:^(UIAlertAction * _Nonnull action) {
        [MBProgressHUD showHUDAddedTo:weakSelf.view WithStatus:@"正在删除"];
        NSError *rmError = nil;
        if (weakSelf.navigationController.viewControllers.count > 1) {

            // 还要把数据库数据更新
            if (nil == self.contentModel) {
                // 进到列表中, 只需要更新这个类别下面所有的数据就好了
                [PicContentTaskModel deleteFromTableWithSourceTitle:self.targetFilePath.lastPathComponent];
            } else {
                // 更新contentModel就好了
                [PicContentTaskModel deleteFromTableWithTitle:self.contentModel.title];
            }

            // [[NSFileManager defaultManager] removeItemAtPath:[weakSelf.targetFilePath stringByAppendingPathComponent:@"."] error:&rmError];//可以删除该路径下所有文件包括文件夹
            [[NSFileManager defaultManager] removeItemAtPath:weakSelf.targetFilePath error:&rmError];//可以删除该路径下所有文件包括该文件夹本身
        } else {
            // 根视图, 删除所有
            [ContentParserManager cancelAll];
            // 取消所有已添加
            [PicContentTaskModel deleteFromTable_All];
            [[NSFileManager defaultManager] removeItemAtPath:[weakSelf.targetFilePath stringByAppendingPathComponent:@"."] error:&rmError];//可以删除该路径下所有文件不包括该文件夹本身
        }
        if (nil == rmError) {
            [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"删除成功" afterDelay:1];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } else {
            // [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"删除失败" afterDelay:1];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf.contentView.mj_header beginRefreshing];
        }
    } cancelTitle:@"取消" cancelHandler:nil];
}

static NSString *likeString = @"我的收藏";
- (void)likeAllFiles {
    PDBlockSelf

    [self showAlertWithTitle:@"提醒" message:@"确定移动该文件夹至收藏夹吗?" confirmTitle:@"确定" confirmHandler:^(UIAlertAction * _Nonnull action) {
        // 构造收藏文件夹
        NSString *systemPath = [self systemDownloadFullPath];
        NSString *likePath = [systemPath stringByAppendingPathComponent:likeString];

        __block BOOL result = YES;
        __block NSError *copyError = nil;

        if (![PPFileManager checkFolderPathExistOrCreate:likePath]) {
            return;
        }
        if (nil == weakSelf.contentModel) {
            /// 多图集页面
            for (ViewerFileModel *fileModel in weakSelf.fileNamesList) {
                if (!fileModel.isFolder) {
                    continue;
                }
                // 多套图就循环处理收藏
                [weakSelf likeOneFolderWithName:fileModel.fileName folderPath:[self.targetFilePath stringByAppendingPathComponent:fileModel.fileName] withLikePath:likePath completeHandler:^(BOOL result_l, NSError *copyError_l) {
                    result = result_l;
                    copyError = copyError_l;
                }];
            }
        } else {
            /// 子页面
            [weakSelf likeOneFolderWithName:weakSelf.contentModel.title folderPath:self.targetFilePath withLikePath:likePath completeHandler:^(BOOL result_l, NSError *copyError_l) {
                result = result_l;
                copyError = copyError_l;
            }];
        }

        if (result) {

            [weakSelf showAlertWithTitle:nil message:[NSString stringWithFormat:@"收藏成功, 文件已移至\"根目录/%@\"目录下", likeString] confirmTitle:@"删除原目录" confirmHandler:^(UIAlertAction * _Nonnull action) {
                NSError *rmError = nil;
                [[NSFileManager defaultManager] removeItemAtPath:weakSelf.targetFilePath error:&rmError];//可以删除该路径下所有文件包括该文件夹本身
                if (rmError) {

                    [weakSelf showAlertWithTitle:nil message:[NSString stringWithFormat:@"收藏失败, %@", rmError] confirmTitle:@"确定" confirmHandler:^(UIAlertAction * _Nonnull action) {
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }];
                }
            } cancelTitle:@"返回" cancelHandler:nil];

        } else {
            [weakSelf showAlertWithTitle:nil message:[NSString stringWithFormat:@"收藏失败, %@", copyError] confirmTitle:@"确定" confirmHandler:nil];
        }
    } cancelTitle:@"取消" cancelHandler:nil];
}

/// 专门处理一套图对的收藏逻辑
- (void)likeOneFolderWithName:(NSString *)folderName folderPath:(NSString *)folderPath withLikePath:(NSString *)likePath completeHandler:(void(^)(BOOL result_l, NSError *copyError_l))completeHandler {
    BOOL result = YES;
    NSError *copyError = nil;

    NSFileManager *fileManager = [NSFileManager defaultManager];

    // 拼接目标路径
    NSString *toFolderPath = [likePath stringByAppendingPathComponent:folderName];

    // 判断下目标路径存不存在
    BOOL isDirectory = YES;
    if ([fileManager fileExistsAtPath:toFolderPath isDirectory:&isDirectory]) {
        // 这个文件夹存在了
        // 我要把这个文件夹里面的文件, 逐个拷贝过去
        NSError *subError = nil;
        NSArray *fileContents = [fileManager contentsOfDirectoryAtPath:folderPath error:&subError];
        for (NSString *fileName in fileContents) {
            // 拼接子文件路径
            NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
            NSString *toFilePath = [toFolderPath stringByAppendingPathComponent:fileName];
            // 如果这个文件本地有了, 没事, 复制也不会生效, 报错也不管
            [fileManager copyItemAtPath:filePath toPath:toFilePath error:&copyError];
        }
        result = YES;
    } else {
        // 目标文件夹不存在, 直接拷贝
        result = [[NSFileManager defaultManager] copyItemAtPath:folderPath toPath:toFolderPath error:&copyError];
    }

    if (completeHandler) {
        completeHandler(result, copyError);
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fileNamesList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ViewerContentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ViewerContentCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.targetPath = self.targetFilePath;
    cell.fileModel = self.fileNamesList[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];

    self.lastViewIndex = indexPath.row;

    ViewerFileModel *fileModel = self.fileNamesList[indexPath.row];

    if (fileModel.isFolder) {
        LocalFileListVC *localListVC = [[LocalFileListVC alloc] init];
        localListVC.targetFilePath = [self.targetFilePath stringByAppendingPathComponent:fileModel.fileName];
        [self.navigationController pushViewController:localListVC animated:YES];
    } else {

        if ([PPFileManager isFileTypePicture:fileModel.fileName.pathExtension]) {
            [self viewPicFile:fileModel indexPath:indexPath contentView:collectionView];
        } else if ([PPFileManager isFileTypeDocument:fileModel.fileName.pathExtension]) {
            ViewerViewController *viewerVC = [[ViewerViewController alloc] init];
            viewerVC.filePath = [self.targetFilePath stringByAppendingPathComponent:fileModel.fileName];
            [self.navigationController pushViewController:viewerVC animated:YES needHiddenTabBar:YES];
        }
    }
}

- (void)viewPicFile:(ViewerFileModel *)fileModel indexPath:(NSIndexPath * _Nonnull)indexPath contentView:(UICollectionView * _Nonnull)contentView {
    [self.imgsList removeAllObjects];
    NSInteger currentIndex = 0;
    for (NSInteger index = 0; index < self.fileNamesList.count; index ++) {
        ViewerFileModel *tempModel = self.fileNamesList[index];
        if ([PPFileManager isFileTypePicture:tempModel.fileName.pathExtension]) {

            if ([tempModel.fileName isEqualToString:fileModel.fileName]) {
                currentIndex = self.imgsList.count;
            }

            YBIBImageData *data = [YBIBImageData new];
            data.imagePath = [self.targetFilePath stringByAppendingPathComponent:tempModel.fileName];
            ViewerContentCell *contentCell = (ViewerContentCell *)[contentView cellForItemAtIndexPath:indexPath];
            data.projectiveView = contentCell.imageView;
            [self.imgsList addObject:data];
        }
    }

    YBImageBrowser *browser = [YBImageBrowser new];
    browser.delegate = self;
    browser.dataSourceArray = self.imgsList;
    browser.currentPage = currentIndex;
    // 只有一个保存操作的时候，可以直接右上角显示保存按钮
    PicBrowserToolViewHandler *handler = PicBrowserToolViewHandler.new;
    browser.toolViewHandlers = @[handler];
    // toolViewHandlers; // topView.operationType = YBIBTopViewOperationTypeSave;
    [browser show];
    self.browser = browser;
}

#if TARGET_OS_MACCATALYST

- (void)pressesBegan:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event {
    /**
          // These are pre-defined constants for use with the input property of UIKeyCommand objects.

          UIKIT_EXTERN NSString *const UIKeyInputUpArrow        API_AVAILABLE(ios(7.0));

          UIKIT_EXTERN NSString *const UIKeyInputDownArrow      API_AVAILABLE(ios(7.0));

          UIKIT_EXTERN NSString *const UIKeyInputLeftArrow      API_AVAILABLE(ios(7.0));

          UIKIT_EXTERN NSString *const UIKeyInputRightArrow      API_AVAILABLE(ios(7.0));

          UIKIT_EXTERN NSString *const UIKeyInputEscape          API_AVAILABLE(ios(7.0));

          UIKIT_EXTERN NSString *const UIKeyInputPageUp          API_AVAILABLE(ios(8.0));

          UIKIT_EXTERN NSString *const UIKeyInputPageDown        API_AVAILABLE(ios(8.0));

          UIKIT_EXTERN NSString *const UIKeyInputHome            API_AVAILABLE(ios(13.4), tvos(13.4)) API_UNAVAILABLE(watchos);

          UIKIT_EXTERN NSString *const UIKeyInputEnd            API_AVAILABLE(ios(13.4), tvos(13.4)) API_UNAVAILABLE(watchos);

          UIKIT_EXTERN NSString *const UIKeyInputF1              API_AVAILABLE(ios(13.4), tvos(13.4)) API_UNAVAILABLE(watchos);

          UIKIT_EXTERN NSString *const UIKeyInputF1              API_AVAILABLE(ios(13.4), tvos(13.4)) API_UNAVAILABLE(watchos);

          UIKIT_EXTERN NSString *const UIKeyInputF2              API_AVAILABLE(ios(13.4), tvos(13.4)) API_UNAVAILABLE(watchos);

          UIKIT_EXTERN NSString *const UIKeyInputF3              API_AVAILABLE(ios(13.4), tvos(13.4)) API_UNAVAILABLE(watchos);

          UIKIT_EXTERN NSString *const UIKeyInputF4              API_AVAILABLE(ios(13.4), tvos(13.4)) API_UNAVAILABLE(watchos);

          UIKIT_EXTERN NSString *const UIKeyInputF5              API_AVAILABLE(ios(13.4), tvos(13.4)) API_UNAVAILABLE(watchos);

          UIKIT_EXTERN NSString *const UIKeyInputF6              API_AVAILABLE(ios(13.4), tvos(13.4)) API_UNAVAILABLE(watchos);

          UIKIT_EXTERN NSString *const UIKeyInputF7              API_AVAILABLE(ios(13.4), tvos(13.4)) API_UNAVAILABLE(watchos);

          UIKIT_EXTERN NSString *const UIKeyInputF8              API_AVAILABLE(ios(13.4), tvos(13.4)) API_UNAVAILABLE(watchos);

          UIKIT_EXTERN NSString *const UIKeyInputF9              API_AVAILABLE(ios(13.4), tvos(13.4)) API_UNAVAILABLE(watchos);

          UIKIT_EXTERN NSString *const UIKeyInputF10            API_AVAILABLE(ios(13.4), tvos(13.4)) API_UNAVAILABLE(watchos);

          UIKIT_EXTERN NSString *const UIKeyInputF11            API_AVAILABLE(ios(13.4), tvos(13.4)) API_UNAVAILABLE(watchos);

          UIKIT_EXTERN NSString *const UIKeyInputF12            API_AVAILABLE(ios(13.4), tvos(13.4)) API_UNAVAILABLE(watchos);
     */

    BOOL didHandleEvent=NO;
    for(UIPress*press in presses) {
        if(@available(macCatalyst 13.4, *)) {
            UIKey *key = press.key;
            //键值
            //匹配键值
            if (key.keyCode == UIKeyboardHIDUsageKeyboardReturnOrEnter) { // enter
                didHandleEvent = YES;
                if (self.contentModel != nil) {
                    if (self.browser.superview == nil && self.fileNamesList.count > 0 && self.fileNamesList.count > self.lastViewIndex) {
                        ViewerFileModel *fileModel = self.fileNamesList[self.lastViewIndex];
                        [self viewPicFile:fileModel indexPath:[NSIndexPath indexPathForItem:self.lastViewIndex inSection:0] contentView:self.contentView];
                    }
                }
            }
            if ([key.charactersIgnoringModifiers isEqualToString:UIKeyInputEscape]) {//esc
                didHandleEvent = YES;
                [self.browser hide];
            }
            if ([key.charactersIgnoringModifiers isEqualToString:UIKeyInputLeftArrow]) {//左箭头
                didHandleEvent = YES;
                self.browser.currentPage = MAX(self.browser.currentPage - 1, 0);
            }
            if ([key.charactersIgnoringModifiers isEqualToString:UIKeyInputRightArrow]) {//右箭头
                didHandleEvent = YES;
                self.browser.currentPage = MIN(self.browser.currentPage + 1, self.imgsList.count);
            }
            if ([key.charactersIgnoringModifiers isEqualToString:UIKeyInputUpArrow]) { // 上箭头
                [self.browser hide];
            }
            if ([key.charactersIgnoringModifiers isEqualToString:UIKeyInputDownArrow]) { // 上箭头
                [self.browser hide];
            }
        }else{
            // Fallback on earlier versions
        }
    }
    if(!didHandleEvent) {//没取到匹配值,调用父类
        [super pressesBegan:presses withEvent:event];
    }
}

#endif

#pragma mark YBImageBrowserDataSource
- (void)yb_imageBrowser:(YBImageBrowser *)imageBrowser pageChanged:(NSInteger)page data:(id<YBIBDataProtocol>)data {
    self.lastViewIndex = page;
    [self.contentView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:page inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    YBIBImageData *data_ = (YBIBImageData *)data;// (YBIBImageData <YBIBDataProtocol>*)data;
    ViewerContentCell *contentCell = (ViewerContentCell *)[self.contentView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0]];
    data_.projectiveView = contentCell.imageView;
}

@end
