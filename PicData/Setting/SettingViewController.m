//
//  SettingViewController.m
//  PicData
//
//  Created by CleverPeng on 2020/7/19.
//  Copyright © 2020 garenge. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@property (nonatomic, strong) UITextView *textView;

@end

@implementation SettingViewController

- (void)dealloc {
    NSLog(@"被释放了?");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"最好在开始下载任务之前设置路径, 避免不必要的错误" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self loadMainView];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)loadNavigationItem {
    self.navigationItem.title = @"设置";
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"确定修改" style:UIBarButtonItemStyleDone target:self action:@selector(confirmButtonClickAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)loadMainView {
    [super loadMainView];

    UILabel *staticLabel = [[UILabel alloc] init];
    staticLabel.text = @"下载目录";
    staticLabel.font = [UIFont systemFontOfSize:16];
    staticLabel.textColor = [UIColor darkTextColor];
    [self.view addSubview:staticLabel];

    [staticLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(24);
        make.height.mas_equalTo(20);
    }];

    UITextView *textView = [[UITextView alloc] init];
    textView.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:textView];
    self.textView = textView;

    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(staticLabel.mas_left);
        make.right.mas_equalTo(-24);
        make.top.equalTo(staticLabel.mas_bottom).with.offset(10);
        make.height.mas_equalTo(150);
    }];

    textView.layer.cornerRadius = 4;
    textView.layer.borderWidth = 1;
    textView.layer.borderColor = UIColor.lightGrayColor.CGColor;

    self.textView.text = [[PDDownloadManager sharedPDDownloadManager] systemDownloadPath];

    UIButton *checkButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [checkButton setTitle:@"检测地址正确性" forState:UIControlStateNormal];
    checkButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [checkButton addTarget:self action:@selector(checkButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkButton];

    [checkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(textView);
        make.top.equalTo(textView.mas_bottom).with.offset(10);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(35);
    }];

    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [resetButton setTitle:@"重置" forState:UIControlStateNormal];
    resetButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [resetButton addTarget:self action:@selector(resetPath) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetButton];

    [resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(checkButton);
        make.right.mas_equalTo(-24);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(35);
    }];

    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [clearButton setTitle:@"清空" forState:UIControlStateNormal];
    clearButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [clearButton addTarget:self action:@selector(clearContent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearButton];

    [clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.equalTo(checkButton);
        make.height.mas_equalTo(35);
    }];
}

- (void)checkButtonClickAction:(UIButton *)sender {
    [self checkPath];
}

- (BOOL)checkPath {
    BOOL isExist = [[PDDownloadManager sharedPDDownloadManager] checkDownloadPathExist:self.textView.text];
    [MBProgressHUD showInfoOnView:self.view WithStatus: isExist ? @"路径正确" : @"路径不存在"];
    return isExist;
}

- (void)clearContent {
    self.textView.text = @"";
    [MBProgressHUD showInfoOnView:self.view WithStatus:@"已清空"];
}

- (void)resetPath {
    [MBProgressHUD showInfoOnView:self.view WithStatus:@"已恢复默认地址"];
    NSString *path = [[PDDownloadManager sharedPDDownloadManager] defaultDownloadPath];
    [[PDDownloadManager sharedPDDownloadManager] updateSystemDownloadPath:path];
    self.textView.text = path;
}

- (void)confirmButtonClickAction{
    if (self.textView.text.length > 0) {

        if (![self checkPath]) {
            return;
        }

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"确定修改下载路径吗, 最好在开始下载任务之前设置路径, 避免不必要的错误" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.view endEditing:YES];
            [[PDDownloadManager sharedPDDownloadManager] updateSystemDownloadPath:self.textView.text];
            [MBProgressHUD showInfoOnView:self.view WithStatus:@"设置地址成功"];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self resetPath];
    }
}

@end
