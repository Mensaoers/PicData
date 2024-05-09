//
//  SharedListViewController.m
//  PicData
//
//  Created by Garenge on 2024/4/28.
//  Copyright © 2024 garenge. All rights reserved.
//

#import "SharedListViewController.h"
#import "SharedListTableViewCell.h"
#import "ViewerFileSModel.h"

@interface SharedListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray <ViewerFileSModel *>*fileNamesList;

@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) BOOL isEditing;

@end

@implementation SharedListViewController

static NSString *SharedListTableViewCellID = @"SharedListTableViewCell";

- (void)setIsEditing:(BOOL)isEditing {
    _isEditing = isEditing;

    if (isEditing) {
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(doFilterItemAction:)];
        UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"square.and.arrow.up"] style:UIBarButtonItemStylePlain target:self action:@selector(doShareItemAction:)];
        self.navigationItem.rightBarButtonItems = @[cancelItem, shareItem];

        self.navigationItem.title = @"已选中0个文件";
    } else {
        UIBarButtonItem *filterItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"list.bullet"] style:UIBarButtonItemStylePlain target:self action:@selector(doFilterItemAction:)];
        self.navigationItem.rightBarButtonItems = @[filterItem];
        self.navigationItem.title = [NSString stringWithFormat:@"历史分享(%ld)", self.fileNamesList.count];
    }
    [self.fileNamesList pp_enumeration:^(ViewerFileSModel * _Nonnull element, NSInteger index, NSInteger totalCount) {
        element.isSelected = NO;
    }];

    [self.fileNamesList pp_enumeration:^(ViewerFileSModel * _Nonnull element, NSInteger index, NSInteger totalCount) {
        element.isSelected = NO;
    }];

    [self.tableView reloadData];
}

- (NSMutableArray<ViewerFileSModel *> *)fileNamesList {
    if (nil == _fileNamesList) {
        _fileNamesList = [NSMutableArray array];
    }
    return _fileNamesList;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshLoadData:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)loadNavigationItem {
    self.navigationItem.title = @"历史分享";

    UIBarButtonItem *filterItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"list.bullet"] style:UIBarButtonItemStylePlain target:self action:@selector(doFilterItemAction:)];
    self.navigationItem.rightBarButtonItems = @[filterItem];
}

- (void)loadMainView {
    self.view.backgroundColor = pdColor(249, 249, 249, 1);

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

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = pdColor(249, 249, 249, 1);
    if (@available(iOS 15.0, *)) {
        tableView.sectionHeaderTopPadding = 0;
    } else {
        // Fallback on earlier versions
    }
    [self.view addSubview:tableView];
    self.tableView = tableView;

    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.equalTo(contentLabel.mas_bottom).offset(8);
        make.bottom.equalTo(self.view.mas_bottomMargin).offset(-8);
    }];

    [tableView registerClass:[SharedListTableViewCell class] forCellReuseIdentifier:SharedListTableViewCellID];

    tableView.tableHeaderView = [UIView new];
    tableView.tableFooterView = [UIView new];

}

#pragma mark - action

- (void)doFilterItemAction:(UIBarButtonItem *)sender {
    self.isEditing = !self.isEditing;
}

- (void)doShareItemAction:(UIBarButtonItem *)sender {

    NSArray <NSURL *>*urls = [[self.fileNamesList pp_filter:^BOOL(ViewerFileSModel * _Nonnull element) {
        return element.isSelected;
    }] pp_map:^id _Nonnull(ViewerFileSModel * _Nonnull element) {
        NSString *filePath = [PDDownloadManager.sharedPDDownloadManager.systemShareFolderPath stringByAppendingPathComponent:element.fileName];
        return [NSURL fileURLWithPath:filePath];
    }];

    [AppTool shareFileWithURLs:urls sourceView:self.view completionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {

    }];
}

#pragma mark - data

- (void)refreshLoadData:(BOOL)needFileSize {

    NSString *targetFilePath = [PDDownloadManager sharedPDDownloadManager].systemShareFolderPath;
    // 每次页面加载出来的时候, 需要当前目录名字
    NSString *directory = [targetFilePath lastPathComponent];
    self.contentLabel.text = [[NSString stringWithFormat:@"%@", directory] stringByReplacingOccurrencesOfString:@":" withString:@"/"];

    NSFileManager *fileManager = [NSFileManager defaultManager];

    // 获取该目录下所有的文件夹和文件
    NSError *subError = nil;
    NSMutableArray *fileContents = [[fileManager contentsOfDirectoryAtPath:targetFilePath error:&subError] mutableCopy];
    // 文件夹排序
    [fileContents sortUsingSelector:@selector(localizedStandardCompare:)];
    [self.fileNamesList removeAllObjects];
    if (nil == subError) {
        // NSLog(@"%@", fileContents);
        for (NSString *fileName in fileContents) {

            if ([fileName hasPrefix:@"."]) {
                continue;
            }

            NSString *filePath = [targetFilePath stringByAppendingPathComponent:fileName];
            if ([PPFileManager isDirectory:filePath]) {
                ViewerFileSModel *fileModel = [ViewerFileSModel modelWithName:fileName isFolder:YES];

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
                        folderSize += [NSFileManager.defaultManager getFileSize:fileAbsolutePath];
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
                ViewerFileSModel *fileModel = [ViewerFileSModel modelWithName:fileName isFolder:NO];
                fileModel.fileSize = [NSFileManager.defaultManager getFileSize:filePath];
                [self.fileNamesList addObject:fileModel];
            }
        }

        self.navigationItem.title = [NSString stringWithFormat:@"历史分享(%ld)", self.fileNamesList.count];
        [self.tableView reloadData];
    } else {
        NSLog(@"%@", subError);
        [self.tableView reloadData];
    }
}

#pragma mark - tableView delegate dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fileNamesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SharedListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SharedListTableViewCellID forIndexPath:indexPath];

    cell.isEditing = self.isEditing;
    cell.model = self.fileNamesList[indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.isEditing) {
        ViewerFileSModel *model = self.fileNamesList[indexPath.row];
        model.isSelected = !model.isSelected;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

        NSInteger count = [self.fileNamesList pp_filter:^BOOL(ViewerFileSModel * _Nonnull element) {
            return element.isSelected;
        }].count;
        self.navigationItem.title = [NSString stringWithFormat:@"已选中个%ld文件", count];
        return;
    }

    ViewerFileSModel *model = self.fileNamesList[indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *filePath = [PDDownloadManager.sharedPDDownloadManager.systemShareFolderPath stringByAppendingPathComponent:model.fileName];

    __weak typeof(self) weakSelf = self;
    NSArray<UIAlertAction *> *actions = @[
        [UIAlertAction actionWithTitle:@"系统分享" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [AppTool shareFileWithURLs:@[[NSURL fileURLWithPath:filePath]] sourceView:cell.contentView completionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {

            }];
        }],
        [UIAlertAction actionWithTitle:@"查看" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [weakSelf doViewDocFileWithFilePath:filePath];
        }],
        [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSError *rmError = nil;
            [[PPFileManager defaultManager] removeItemAtPath:filePath error:&rmError];
            if (nil == rmError) {
                [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"移除成功" afterDelay:1];
                [self refreshLoadData:YES];
            } else {
                [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"移除失败" afterDelay:1];
            }
        }],
        [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

        }],
    ];

    [self showAlertWithTitle:@"提示" message:@"你想对该文件做什么操作?" actions:actions];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return UIView.new;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return UIView.new;
}

@end
