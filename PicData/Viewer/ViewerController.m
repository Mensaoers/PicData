//
//  ViewerController.m
//  PicData
//
//  Created by Garenge on 2020/11/4.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "ViewerController.h"
#import "ViewerCell.h"

@interface ViewerController () <UITableViewDelegate, UITableViewDataSource, YBImageBrowserDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray <ViewerFileModel *>*fileNamesList;
@property (nonatomic, strong) NSMutableArray *imgsList;

@end

@implementation ViewerController

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

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)loadNavigationItem {
    self.navigationItem.title = @"浏览";

    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStyleDone target:self action:@selector(clearAllFiles)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)loadMainView {
    [super loadMainView];

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = BackgroundColor;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[ViewerCell class] forCellReuseIdentifier:ViewerCellIdentifier];
    [self.view addSubview:tableView];
    self.tableView = tableView;

    tableView.tableFooterView = [UIView new];

    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];

    PDBlockSelf
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
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
    self.navigationItem.title = [NSString stringWithFormat:@"%@", directory];

    NSFileManager *fileManager = [NSFileManager defaultManager];

    // 获取该目录下所有的文件夹和文件
    NSError *subError = nil;
    NSMutableArray *fileContents = [[fileManager contentsOfDirectoryAtPath:self.targetFilePath error:&subError] mutableCopy];
    [fileContents sortUsingSelector:@selector(localizedStandardCompare:)];
    if (nil == subError) {
        NSLog(@"%@", fileContents);

        [self.fileNamesList removeAllObjects];
        for (NSString *fileName in fileContents) {
            // fileName.pathExtension
            NSLog(@"%@", fileName.pathExtension);
            NSString *pathExtension = fileName.pathExtension;
            if ([pathExtension containsString:@"txt"] || [pathExtension containsString:@"jpg"]) {
                ViewerFileModel *fileModel = [ViewerFileModel modelWithName:fileName isFolder:NO];
                [self.fileNamesList addObject:fileModel];
            } else {
                ViewerFileModel *fileModel = [ViewerFileModel modelWithName:fileName isFolder:YES];
                [self.fileNamesList addObject:fileModel];
            }
        }

        [self.tableView reloadData];
    } else {
        NSLog(@"%@", subError);
    }
    [self.tableView.mj_header endRefreshing];
}

- (void)clearAllFiles {
    PDBlockSelf
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"确定清空所有文件吗?(该目录也将一并清除), 该过程不可逆" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [MBProgressHUD showHUDAddedTo:weakSelf.view WithStatus:@"正在删除"];
        NSError *rmError = nil;
        if (self.navigationController.viewControllers.count > 1) {
//            [[NSFileManager defaultManager] removeItemAtPath:[weakSelf.targetFilePath stringByAppendingPathComponent:@"."] error:&rmError];//可以删除该路径下所有文件包括文件夹
             [[NSFileManager defaultManager] removeItemAtPath:weakSelf.targetFilePath error:&rmError];//可以删除该路径下所有文件包括文件夹(包括目录本身)
        } else {
            [[NSFileManager defaultManager] removeItemAtPath:[weakSelf.targetFilePath stringByAppendingPathComponent:@"."] error:&rmError];//可以删除该路径下所有文件包括文件夹
        }
        if (nil == rmError) {
            [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"删除成功" afterDelay:1];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
//            [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"删除失败" afterDelay:1];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [weakSelf.tableView.mj_header beginRefreshing];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fileNamesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ViewerCell *cell = [tableView dequeueReusableCellWithIdentifier:ViewerCellIdentifier forIndexPath:indexPath];
    cell.fileModel = self.fileNamesList[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated: YES];

    ViewerFileModel *fileModel = self.fileNamesList[indexPath.row];

    if (fileModel.isFolder) {
        ViewerController *viewerVC = [[ViewerController alloc] init];
        viewerVC.targetFilePath = [self.targetFilePath stringByAppendingPathComponent:fileModel.fileName];
        [self.navigationController pushViewController:viewerVC animated:YES needHiddenTabBar:NO];
    } else {

        if (![fileModel.fileName.pathExtension containsString:@"jpg"]) {
            return;
        }

        [self.imgsList removeAllObjects];
        NSInteger currentIndex = 0;
        for (NSInteger index = 0; index < self.fileNamesList.count; index ++) {
            ViewerFileModel *tempModel = self.fileNamesList[index];
            if ([tempModel.fileName.pathExtension containsString:@"jpg"]) {
//                [self.imgsList addObject:tempModel];

                if ([tempModel.fileName isEqualToString:fileModel.fileName]) {
                    currentIndex = index;
                }

                YBIBImageData *data = [YBIBImageData new];
                data.imagePath = [self.targetFilePath stringByAppendingPathComponent:tempModel.fileName];
                data.projectiveView = [tableView cellForRowAtIndexPath:indexPath];
                [self.imgsList addObject:data];
            }
        }

        YBImageBrowser *browser = [YBImageBrowser new];
        browser.dataSourceArray = self.imgsList;
        browser.currentPage = currentIndex;
        // 只有一个保存操作的时候，可以直接右上角显示保存按钮
        browser.defaultToolViewHandler.topView.operationType = YBIBTopViewOperationTypeSave;
        [browser show];
    }
}

#pragma mark YBImageBrowserDataSource
//- (NSInteger)yb_numberOfCellsInImageBrowser:(YBImageBrowser *)imageBrowser {
//    return self.imgsList.count;
//}
//
//- (id<YBIBDataProtocol>)yb_imageBrowser:(YBImageBrowser *)imageBrowser dataForCellAtIndex:(NSInteger)index {
//
//}

@end
