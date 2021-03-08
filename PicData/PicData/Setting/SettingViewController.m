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
@property (nonatomic, strong) UILabel *fullPathLabel;

@end

@implementation SettingViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"最好在开始下载任务之前设置路径, 避免不必要的错误" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self loadMainView];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)loadNavigationItem {
    self.navigationItem.title = @"设置";
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"重置" style:UIBarButtonItemStyleDone target:self action:@selector(resetPath)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)loadMainView {
    [super loadMainView];

    UILabel *staticLabel = [[UILabel alloc] init];
    staticLabel.text = @"当前下载路径:";
    staticLabel.font = [UIFont systemFontOfSize:16];
    staticLabel.textColor = [UIColor darkTextColor];
    [self.view addSubview:staticLabel];

    [staticLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(24);
        make.height.mas_equalTo(20);
    }];

    UILabel *fullPathLabel = [[UILabel alloc] init];
    fullPathLabel.font = [UIFont systemFontOfSize:14];
    fullPathLabel.textAlignment = NSTextAlignmentLeft;
    fullPathLabel.numberOfLines = 0;
    fullPathLabel.textColor = UIColor.lightGrayColor;
    [self.view addSubview:fullPathLabel];
    self.fullPathLabel = fullPathLabel;

    [fullPathLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(staticLabel.mas_bottom).with.offset(8);
        make.left.mas_equalTo(24);
        make.right.mas_equalTo(-24);
    }];

    self.fullPathLabel.text = [[PDDownloadManager sharedPDDownloadManager] systemDownloadFullPath];

    UILabel *tipsLabel = [[UILabel alloc] init];
    tipsLabel.text = @"设置路径:";
    tipsLabel.font = [UIFont systemFontOfSize:16];
    tipsLabel.textColor = [UIColor darkTextColor];
    [self.view addSubview:tipsLabel];

    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fullPathLabel.mas_bottom).with.offset(24);
        make.left.mas_equalTo(24);
        make.height.mas_equalTo(20);
    }];

    UITextView *textView = [[UITextView alloc] init];
    textView.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:textView];
    self.textView = textView;

    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(staticLabel.mas_left);
        make.right.mas_equalTo(-24);
        make.top.equalTo(tipsLabel.mas_bottom).with.offset(8);
        make.height.mas_equalTo(100);
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
    [resetButton setTitle:@"确定修改" forState:UIControlStateNormal];
    resetButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [resetButton addTarget:self action:@selector(confirmButtonClickAction) forControlEvents:UIControlEventTouchUpInside];
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

    // 不用检查
    return;
    // version
    UIButton *versionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [versionButton setTitle:[NSString stringWithFormat:@"V%@ [检查更新]", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]] forState:UIControlStateNormal];
    versionButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [versionButton addTarget:self action:@selector(checkNewVersion:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:versionButton];

    [versionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(MIN(300, self.view.mj_w - 40), 44));
        make.bottom.equalTo(self.view.mas_bottomMargin).with.offset(-20);
    }];
    versionButton.layer.cornerRadius = 4;
    versionButton.layer.borderColor = versionButton.tintColor.CGColor;
    versionButton.layer.borderWidth = 1;
    versionButton.layer.masksToBounds = YES;
}

- (void)checkNewVersion:(UIButton *)sender {

    PDBlockSelf
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PDRequest requestToCheckVersion:NO onView:self.view completehandler:^{
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    }];
}

- (void)checkButtonClickAction:(UIButton *)sender {
    [self checkPath];
}

- (BOOL)checkPath {
    NSString *fullPath = [PDDownloadManager getDocumentPathWithTarget:self.textView.text];
    BOOL isExist = [[PDDownloadManager sharedPDDownloadManager] checkFilePathExist:fullPath];
    [MBProgressHUD showInfoOnView:self.view WithStatus: isExist ? @"路径正确" : @"路径不存在"];
    return isExist;
}

- (void)clearContent {
    self.textView.text = @"";
    [MBProgressHUD showInfoOnView:self.view WithStatus:@"已清空"];
}

- (void)resetPath {
    [MBProgressHUD showInfoOnView:self.view WithStatus:@"已恢复默认地址"];
    [[PDDownloadManager sharedPDDownloadManager] resetDownloadPath];
    self.fullPathLabel.text = [[PDDownloadManager sharedPDDownloadManager] systemDownloadFullPath];
    self.textView.text = [[PDDownloadManager sharedPDDownloadManager] systemDownloadPath];
}

- (void)confirmButtonClickAction {
    PDBlockSelf
    if (self.textView.text.length > 0) {

        if (![self checkPath]) {
            return;
        }

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"确定修改下载路径吗, 最好在开始下载任务之前设置路径, 避免不必要的错误" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf.view endEditing:YES];
            [[PDDownloadManager sharedPDDownloadManager] updatesystemDownloadPath:weakSelf.textView.text];
            weakSelf.fullPathLabel.text = [[PDDownloadManager sharedPDDownloadManager] systemDownloadFullPath];
            [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"设置地址成功"];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self resetPath];
    }
}

@end
