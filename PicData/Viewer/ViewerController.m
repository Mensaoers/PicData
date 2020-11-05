//
//  ViewerController.m
//  PicData
//
//  Created by Garenge on 2020/11/4.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "ViewerController.h"
#import "ViewerCell.h"

@interface ViewerController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray <ViewerFileModel *>*fileNamesList;

@end

@implementation ViewerController

- (NSMutableArray<ViewerFileModel *> *)fileNamesList {
    if (nil == _fileNamesList) {
        _fileNamesList = [NSMutableArray array];
    }
    return _fileNamesList;
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

    [self.tableView.mj_header beginRefreshing];
}

- (void)refreshLoadData {
    // 每次页面加载出来的时候, 需要当前目录名字
    NSString *directory = [[PDDownloadManager sharedPDDownloadManager] systemDownloadFullDirectory];
    self.navigationItem.title = [NSString stringWithFormat:@"浏览-%@", directory];

    NSFileManager *fileManager = [NSFileManager defaultManager];

    // 获取该目录下所有的文件夹和文件
    NSError *subError = nil;
    NSArray *fileContents = [fileManager contentsOfDirectoryAtPath:self.targetFilePath error:&subError];
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fileNamesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ViewerCell *cell = [tableView dequeueReusableCellWithIdentifier:ViewerCellIdentifier forIndexPath:indexPath];
    cell.fileModel = self.fileNamesList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated: YES];

    ViewerFileModel *fileModel = self.fileNamesList[indexPath.row];

    if (fileModel.isFolder) {
        ViewerController *viewerVC = [[ViewerController alloc] init];
        viewerVC.targetFilePath = [self.targetFilePath stringByAppendingPathComponent:fileModel.fileName];
        [self.navigationController pushViewController:viewerVC animated:YES needHiddenTabBar:NO];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 64;
}

@end
