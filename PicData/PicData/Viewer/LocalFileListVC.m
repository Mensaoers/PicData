//
//  LocalFileListVC.m
//  PicData
//
//  Created by Garenge on 2020/11/4.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "LocalFileListVC.h"
//#import "ViewerCell.h"
#import "ViewerViewController.h"
#import "ViewerContentView.h"

@interface LocalFileListVC () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) ViewerContentView *contentView;
@property (nonatomic, strong) NSMutableArray <ViewerFileModel *>*fileNamesList;
@property (nonatomic, strong) NSMutableArray *imgsList;

@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) PicContentModel *contentModel;


@end

@implementation LocalFileListVC

- (PicContentModel *)contentModel {
    if (nil == _contentModel) {
        NSArray *result = [PicContentModel queryTableWithTitle:[self.targetFilePath lastPathComponent]];
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
//    return @"/Volumes/LZP_HDD/.12AC169F959B49C89E3EE409191E2EF1/Program Files (x86)/Program File/ODg4OA==";
}
- (NSString *)targetFilePath {
    if (nil == _targetFilePath) {
        _targetFilePath = [self systemDownloadFullPath];
    }
    return _targetFilePath;
}

- (void)loadNavigationItem {

    NSMutableArray *leftBarButtonItems = [NSMutableArray array];
    if (self.navigationController.viewControllers.count >= 2) {
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(backAction:)];
        [leftBarButtonItems addObject:backItem];
    }
    // mac端也允许整理按钮, 加警告框即可
    if (self.navigationController.viewControllers.count <= 2) {
        UIBarButtonItem *arrangeItem = [[UIBarButtonItem alloc] initWithTitle:@"整理" style:UIBarButtonItemStyleDone target:self action:@selector(arrangeItemClickAction:)];
        [leftBarButtonItems addObject:arrangeItem];
    }
    self.navigationItem.leftBarButtonItems = leftBarButtonItems;

    NSMutableArray *items = [NSMutableArray array];
    
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
        make.left.mas_equalTo(5);
        make.right.mas_equalTo(-5);
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
}

- (void)refreshLoadData:(BOOL)needFileSize {

    // 每次页面加载出来的时候, 需要当前目录名字
    NSString *directory = [self.targetFilePath lastPathComponent];
    self.contentLabel.text = [NSString stringWithFormat:@"%@", directory];

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
            // fileName.pathExtension
            // NSLog(@"%@", fileName.pathExtension);
            NSString *pathExtension = fileName.pathExtension;
            if ([pathExtension containsString:@"txt"] || [pathExtension containsString:@"jpg"]) {
                ViewerFileModel *fileModel = [ViewerFileModel modelWithName:fileName isFolder:NO];
                [self.fileNamesList addObject:fileModel];
            } else {

                ViewerFileModel *fileModel = [ViewerFileModel modelWithName:fileName isFolder:YES];

                NSString *dirPath = [self.targetFilePath stringByAppendingPathComponent:fileName];
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
                [self.fileNamesList addObject:fileModel];
            }
        }

        [self.contentView reloadData];
    } else {
        NSLog(@"%@", subError);
    }
    [self.contentView.mj_header endRefreshing];
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

/// 创建压缩包
- (void)createZipWithTargetPathName:(NSString *)targetPathName ZipNameTFText:(NSString *)zipNameTFText pwdNameTFText:(NSString *)pwdNameTFText sourceView:(UIView *)sourceView {

    PDBlockSelf
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 压缩文件
        NSString *zippedFileName;
        if (zipNameTFText.length == 0) {
            zippedFileName = targetPathName;
        } else {
            if ([zipNameTFText.pathExtension.lowercaseString isEqualToString:@"zip"]) {
                // 用户已经写好了".zip"
                zippedFileName = zipNameTFText;
            } else {
                // 用户没写, 我补上
                zippedFileName = [NSString stringWithFormat:@"%@.zip", zipNameTFText];
            }
        }
        NSString *zippedPath = [NSTemporaryDirectory() stringByAppendingPathComponent:zippedFileName];
        BOOL zipResult = [SSZipArchive createZipFileAtPath:zippedPath withContentsOfDirectory:weakSelf.targetFilePath keepParentDirectory:YES withPassword:pwdNameTFText.length > 0 ? pwdNameTFText : nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (zipResult) {
                // 压缩成功
                [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
                [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"压缩成功" afterDelay:1];

                /// 压缩之后弹出分享框
                [weakSelf showActivityViewControllerWithItems:@[[NSURL fileURLWithPath:zippedPath]] sourceView:sourceView ComleteHandler:^{
                    // 不分享了, 那得删了临时数据
                    NSError *rmError = nil;
                    [[NSFileManager defaultManager] removeItemAtPath:zippedPath error:&rmError];
                    if (rmError) {
                        NSLog(@"删除文件失败: %@", rmError);
                    }
                }];
            } else {
                [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
                [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"压缩失败" afterDelay:1];
            }
        });

    });
}

- (void)shareAllFiles:(UIButton *)sender {
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

/// 压缩之后弹出分享框
- (void)showActivityViewControllerWithItems:(NSArray *)activityItems sourceView:(UIView *)sourceView ComleteHandler:(void(^)(void))completeHandler {
    UIViewController *topRootViewController = UIApplication.sharedApplication.keyWindow.rootViewController;

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityVC.completionWithItemsHandler = ^(UIActivityType __nullable activityType, BOOL completed, NSArray *__nullable returnedItems, NSError *__nullable activityError) {
        NSLog(@"调用分享的应用id :%@", activityType);

        completeHandler();

        if (completed) {
            NSLog(@"分享成功!");
        } else {
            NSLog(@"分享失败!");
        }
    };

    if ([[UIDevice currentDevice].model isEqualToString:@"iPhone"]) {
        [topRootViewController presentViewController:activityVC animated:YES completion:nil];
    } else if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
        UIPopoverPresentationController *popover = activityVC.popoverPresentationController;
        if (popover) {
            popover.sourceView = sourceView;
            popover.permittedArrowDirections = UIPopoverArrowDirectionUp;
        }
        [topRootViewController presentViewController:activityVC animated:YES completion:nil];
    } else {
        //do nothing
    }
}

- (void)arrangeItemClickAction:(UIBarButtonItem *)sender {

    PDBlockSelf
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"整理文件夹" message:@"该操作可能会删除本地文件(夹), 重要文件请再三确认" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"仅刷新文件夹大小" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        [weakSelf refreshLoadData:YES];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"清空无图文件夹" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        [weakSelf arrangeAllFiles];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)arrangeAllFiles {

    PDBlockSelf
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"清空无图文件夹" message:@"该操作会删除该目录下空文件夹, 且不可恢复, 确定要整理吗?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确认删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        BOOL isRoot = [weakSelf.targetFilePath isEqualToString:[[PDDownloadManager sharedPDDownloadManager] systemDownloadFullPath]];

        [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];

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
                    if ([pathExtension containsString:@"txt"] || [pathExtension containsString:@"jpg"]) {

                    } else {
                        isEmptyF = NO;
                    }
                } else {
                    // 图库整理, 移除没有图片的子项目
                    if ([pathExtension containsString:@"jpg"]) {
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

        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"整理完成" afterDelay:1];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)clearAllFiles {
    PDBlockSelf
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"确定清空所有文件吗?(该目录也将一并清除), 该过程不可逆" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [MBProgressHUD showHUDAddedTo:weakSelf.view WithStatus:@"正在删除"];
        NSError *rmError = nil;
        if (weakSelf.navigationController.viewControllers.count > 1) {

                // 还要把数据库数据更新
            if (weakSelf.navigationController.viewControllers.count == 2) {
                // 进到列表中, 只需要更新这个类别下面所有的数据就好了
                [PicContentTaskModel deleteFromTableWithSourceTitle:[weakSelf.targetFilePath lastPathComponent]];
            } else {
                // 更新contentModel就好了
                if (self.contentModel) {
                    [PicContentTaskModel deleteFromTableWithTitle:self.contentModel.title];
                }
            }

            // [[NSFileManager defaultManager] removeItemAtPath:[weakSelf.targetFilePath stringByAppendingPathComponent:@"."] error:&rmError];//可以删除该路径下所有文件包括文件夹
            [[NSFileManager defaultManager] removeItemAtPath:weakSelf.targetFilePath error:&rmError];//可以删除该路径下所有文件包括该文件夹本身
        } else {
            // 根视图, 删除所有
            [PDDownloadManager.sharedPDDownloadManager totalCancel];
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
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

static NSString *likeString = @"我的收藏";
- (void)likeAllFiles {
    PDBlockSelf
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"确定移动该文件夹至收藏夹吗?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 构造收藏文件夹
        NSString *systemPath = [self systemDownloadFullPath];
        NSString *likePath = [systemPath stringByAppendingPathComponent:likeString];

        BOOL result = YES;
        NSError *copyError = nil;
        if ([[PDDownloadManager sharedPDDownloadManager] checkFilePathExist:likePath]) {

            if (weakSelf.navigationController.viewControllers.count == 2) {
                /// 多图集页面
                for (ViewerFileModel *fileModel in weakSelf.fileNamesList) {
                    if (!fileModel.isFolder) {
                        continue;
                    }
                    NSString *toPath = [likePath stringByAppendingPathComponent:fileModel.fileName];
                    result = [[NSFileManager defaultManager] copyItemAtPath:[self.targetFilePath stringByAppendingPathComponent:fileModel.fileName] toPath:toPath error:&copyError];
                    [PicContentTaskModel updateTableWithSourceTitle:likeString WhenTitle:fileModel.fileName];
                }
            } else {
                /// 子页面
                NSString *folderName = [self.targetFilePath lastPathComponent];
                NSString *toPath = [likePath stringByAppendingPathComponent:folderName];
                result = [[NSFileManager defaultManager] copyItemAtPath:self.targetFilePath toPath:toPath error:&copyError];
                [PicContentTaskModel updateTableWithSourceTitle:likeString WhenTitle:folderName];
            }

            if (result) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"收藏成功, 文件已移至\"根目录/%@\"目录下", likeString] preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }]];
                [alert addAction:[UIAlertAction actionWithTitle:@"删除原目录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSError *rmError = nil;
                    [[NSFileManager defaultManager] removeItemAtPath:weakSelf.targetFilePath error:&rmError];//可以删除该路径下所有文件包括该文件夹本身
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }]];
                [weakSelf presentViewController:alert animated:YES completion:nil];
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"收藏失败, %@", copyError] preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
                [weakSelf presentViewController:alert animated:YES completion:nil];
            }
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
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

    ViewerFileModel *fileModel = self.fileNamesList[indexPath.row];

    if (fileModel.isFolder) {
        LocalFileListVC *localListVC = [[LocalFileListVC alloc] init];
        localListVC.targetFilePath = [self.targetFilePath stringByAppendingPathComponent:fileModel.fileName];
        [self.navigationController pushViewController:localListVC animated:YES];
    } else {

        if ([fileModel.fileName.pathExtension containsString:@"jpg"]) {
            [self viewPicFile:fileModel indexPath:indexPath contentView:collectionView];
        } else if ([fileModel.fileName.pathExtension containsString:@"txt"]) {
            ViewerViewController *viewerVC = [[ViewerViewController alloc] init];
            viewerVC.filePath = [self.targetFilePath stringByAppendingPathComponent:fileModel.fileName];
            [self.navigationController pushViewController:viewerVC animated:YES needHiddenTabBar:YES];
        }
    }
}

- (void)viewPicFile:(ViewerFileModel *)fileModel indexPath:(NSIndexPath * _Nonnull)indexPath contentView:(UICollectionView * _Nonnull)contentView {
    [self.imgsList removeAllObjects];
}

@end
