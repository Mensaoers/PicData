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
#import "PicBrowserToolViewHandler.h"
#import "ViewerContentView.h"

@interface LocalFileListVC () <UICollectionViewDelegate, UICollectionViewDataSource, YBImageBrowserDelegate>

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

- (NSString *)targetFilePath {
    if (nil == _targetFilePath) {
        _targetFilePath = [[PDDownloadManager sharedPDDownloadManager] systemDownloadFullPath];
    }
    return _targetFilePath;
}

- (void)loadNavigationItem {

    if ([self.targetFilePath isEqualToString:[[PDDownloadManager sharedPDDownloadManager] systemDownloadFullPath]]) {
        UIBarButtonItem *arrangeItem = [[UIBarButtonItem alloc] initWithTitle:@"整理" style:UIBarButtonItemStyleDone target:self action:@selector(arrangeAllFiles)];
        self.navigationItem.leftBarButtonItem = arrangeItem;
    }

    NSMutableArray *items = [NSMutableArray array];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareAllFiles:) forControlEvents:UIControlEventTouchUpInside];
    shareButton.frame = CGRectMake(0, 0, 25, 25);
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    [items addObject:shareItem];
    
    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStyleDone target:self action:@selector(clearAllFiles)];
    [items addObject:deleteItem];
    
    if (self.navigationController.viewControllers.count > 2) {
        UIBarButtonItem *likeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"like"] style:UIBarButtonItemStyleDone target:self action:@selector(likeAllFiles)];
        [items addObject:likeItem];
    }
    
    self.navigationItem.rightBarButtonItems = items;
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
        [weakSelf refreshLoadData];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self refreshLoadData];
}

- (void)refreshLoadData {
    // 每次页面加载出来的时候, 需要当前目录名字
    NSString *directory = [self.targetFilePath lastPathComponent];
    self.contentLabel.text = [NSString stringWithFormat:@"%@", directory];

    NSFileManager *fileManager = [NSFileManager defaultManager];

    // 获取该目录下所有的文件夹和文件
    NSError *subError = nil;
    NSMutableArray *fileContents = [[fileManager contentsOfDirectoryAtPath:self.targetFilePath error:&subError] mutableCopy];
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
                [self.fileNamesList addObject:fileModel];
            }
        }

        [self.contentView reloadData];
    } else {
        NSLog(@"%@", subError);
    }
    [self.contentView.mj_header endRefreshing];
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

- (void)arrangeAllFiles {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (ViewerFileModel *fileModel in self.fileNamesList) {
        if (!fileModel.isFolder) {
            continue;
        }
        NSString *dirPath = [self.targetFilePath stringByAppendingPathComponent:fileModel.fileName];
        NSError *subError = nil;
        NSArray *fileContents = [fileManager contentsOfDirectoryAtPath:dirPath error:&subError];
        BOOL hasFolder = NO;
        for (NSString *fileName in fileContents) {
            NSString *pathExtension = fileName.pathExtension;
            if ([pathExtension containsString:@"txt"] || [pathExtension containsString:@"jpg"]) {

            } else {
                hasFolder = YES;
            }
        }
        if (!hasFolder) {
            // 没有文件夹, 干掉
            NSError *rmError = nil;
            [fileManager removeItemAtPath:dirPath error:&rmError];
        }
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    [MBProgressHUD showInfoOnView:self.view WithStatus:@"整理完成" afterDelay:1];
    [self refreshLoadData];
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
                [PicContentModel unAddALLWithSourceTitle:[weakSelf.targetFilePath lastPathComponent]];
            } else {
                // 更新contentModel就好了
                if (self.contentModel) {
                    self.contentModel.hasAdded = 0;
                    [self.contentModel updateTable];
                }
            }

            // [[NSFileManager defaultManager] removeItemAtPath:[weakSelf.targetFilePath stringByAppendingPathComponent:@"."] error:&rmError];//可以删除该路径下所有文件包括文件夹
            [[NSFileManager defaultManager] removeItemAtPath:weakSelf.targetFilePath error:&rmError];//可以删除该路径下所有文件包括该文件夹本身
        } else {
            // 根视图, 删除所有
            [PDDownloadManager.sharedPDDownloadManager totalCancel];
            // 取消所有已添加
            [PicContentModel unAddALL];
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

- (void)likeAllFiles {
    PDBlockSelf
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"确定移动该文件至收藏夹吗?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 构造收藏文件夹
        NSString *systemPath = [[PDDownloadManager sharedPDDownloadManager] systemDownloadFullPath];
        NSString *likePath = [systemPath stringByAppendingPathComponent:@"我的收藏"];
        if ([[PDDownloadManager sharedPDDownloadManager] checkFilePathExist:likePath]) {
            NSString *toPath = [likePath stringByAppendingPathComponent:[self.targetFilePath lastPathComponent]];
            NSError *copyError = nil;
            BOOL result = [[NSFileManager defaultManager] copyItemAtPath:self.targetFilePath toPath:toPath error:&copyError];
            if (result) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"收藏成功, 文件已移至\"根目录/我的收藏/\"目录下" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }]];
                [alert addAction:[UIAlertAction actionWithTitle:@"删除该目录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
    NSInteger currentIndex = 0;
    for (NSInteger index = 0; index < self.fileNamesList.count; index ++) {
        ViewerFileModel *tempModel = self.fileNamesList[index];
        if ([tempModel.fileName.pathExtension containsString:@"jpg"]) {

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
}

#pragma mark YBImageBrowserDataSource
- (void)yb_imageBrowser:(YBImageBrowser *)imageBrowser pageChanged:(NSInteger)page data:(id<YBIBDataProtocol>)data {
    [self.contentView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:page inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    YBIBImageData *data_ = (YBIBImageData *)data;// (YBIBImageData <YBIBDataProtocol>*)data;
    ViewerContentCell *contentCell = (ViewerContentCell *)[self.contentView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0]];
    data_.projectiveView = contentCell.imageView;
}

@end
