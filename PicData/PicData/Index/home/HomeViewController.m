//
//  HomeViewController.m
//  PicData
//
//  Created by 鹏鹏 on 2021/9/12.
//  Copyright © 2021 garenge. All rights reserved.
//

#import "HomeViewController.h"
#import "ContentViewController.h"
#import "PicClassifyTableView.h"
#import "FloatingWindowView.h"

@interface HomeViewController () <PicClassifyTableViewActionDelegate>

/// 地址
@property (nonatomic, strong) NSString *addressUrl;
/// 搜索地址
@property (nonatomic, strong) NSString *searchAddressUrl;
/// tags地址
@property (nonatomic, strong) NSString *tagsAddressUrl;

@property (nonatomic, strong) UILabel *addressLabel;

@property (nonatomic, strong) PicSourceModel *sourceModel;

@property (nonatomic, strong) UITextField *searchTF;
@property (nonatomic, strong) UIButton *searchBtn;
@property (nonatomic, strong) PicClassifyTableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataList;

@end

@implementation HomeViewController

- (NSMutableArray *)dataList {
    if (nil == _dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (PicSourceModel *)sourceModel {
    if (nil == _sourceModel) {
        _sourceModel = [[PicSourceModel alloc] init];
    }
    return _sourceModel;
}

- (NSString *)addressUrl {
    if (nil == _addressUrl) {
        _addressUrl = @"https://v.zflfb.vip:9527/fb.html";
    }
    return _addressUrl;
}

- (NSString *)searchAddressUrl {
    if (nil == _searchAddressUrl) {
        _searchAddressUrl = @"https://so.azs2019.com/serch.php";
    }
    return _searchAddressUrl;
}

- (void)loadNavigationItem {
    self.navigationItem.title = @"地址发布页";

    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"arrow.clockwise"] style:UIBarButtonItemStyleDone target:self action:@selector(loadCurrentAddresses)];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)loadRightNavigationItem:(BOOL)isList {
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"square.and.arrow.up"] style:UIBarButtonItemStyleDone target:self action:@selector(shareUrl:)];

    UIBarButtonItem *rightItem;
    if (isList) {
        rightItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"list_tags"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(rightNavigationItemClickAction:)];
    } else {
        rightItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"list"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(rightNavigationItemClickAction:)];
    }

    self.navigationItem.rightBarButtonItems = @[shareItem, rightItem];
}

- (void)rightNavigationItemClickAction:(UIBarButtonItem *)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (self.tableView.classifyStyle == PicClassifyTableViewStyleDefault) {
        [self loadRightNavigationItem:NO];
        self.tableView.classifyStyle = PicClassifyTableViewStyleTags;
    } else if (self.tableView.classifyStyle == PicClassifyTableViewStyleTags) {
        [self loadRightNavigationItem:YES];
        self.tableView.classifyStyle = PicClassifyTableViewStyleDefault;
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)loadMainView {
    [super loadMainView];
    UILabel *addressLabel = [[UILabel alloc] init];
    addressLabel.numberOfLines = 0;
    addressLabel.textColor = [UIColor darkTextColor];
    [self.view addSubview:addressLabel];
    self.addressLabel = addressLabel;

    [addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.top.mas_equalTo(12);
        make.right.mas_equalTo(-12);
    }];

    addressLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toViewDetails)];
    [addressLabel addGestureRecognizer:tap];

    UITextField *searchTF = [[UITextField alloc] init];
    searchTF.font = [UIFont systemFontOfSize:17];
    searchTF.placeholder = @"请输入关键字";
    searchTF.borderStyle = UITextBorderStyleRoundedRect;
    searchTF.returnKeyType = UIReturnKeySearch;
    [searchTF addTarget:self action:@selector(searchBtnClickedAction:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:searchTF];
    self.searchTF = searchTF;

    [searchTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(addressLabel);
        make.top.equalTo(addressLabel.mas_bottom).with.offset(12);
        make.height.mas_equalTo(35);
    }];

    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchBtnClickedAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchBtn];
    self.searchBtn = searchBtn;

    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchTF.mas_right).with.offset(8);
        make.centerY.height.equalTo(searchTF);
        make.right.equalTo(addressLabel);
        make.width.mas_equalTo(70);
    }];

    PicClassifyTableView *tableView = [[PicClassifyTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self loadRightNavigationItem:tableView.classifyStyle == PicClassifyTableViewStyleDefault];
    tableView.actionDelegate = self;
    tableView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:tableView];

    self.tableView = tableView;

    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(searchTF.mas_bottom).with.offset(5);
        make.left.right.mas_equalTo(0);
        make.bottom.equalTo(self.view.mas_bottomMargin).with.offset(-5);
    }];

    [self setupFloating];
}

- (void)setupFloating {
    [[FloatingWindowView shareInstance] isHidden:NO];

    [FloatingWindowView shareInstance].ClickAction = ^{

        BaseTabBarController *tabBarVC = (BaseTabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [tabBarVC setSelectedIndex:0];
        BaseNavigationController *indexNavi = (BaseNavigationController *)tabBarVC.selectedViewController;

        NSArray *viewControllers = indexNavi.viewControllers;
        BOOL jumped = NO;
        for (UIViewController *viewController in viewControllers) {
            if ([viewController isKindOfClass:[AddNetTaskVC class]]) {
                // 弹过了, 不弹了
                jumped = YES;
                break;
            }
        }
        if (!jumped) {
            [indexNavi pushViewController:[[AddNetTaskVC alloc] init] animated:YES];
        }
    };
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [FloatingWindowView shareInstance].areaActFrame = self.view.bounds;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadCurrentAddresses];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.searchTF.text = @"";
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.view endEditing:YES];
}

#pragma mark - request

#pragma mark request host
- (void)loadCurrentAddresses {
    MJWeakSelf
    [MBProgressHUD showHUDAddedTo:self.view WithStatus:@"正在获取地址"];
    [PDRequest getWithURL:[NSURL URLWithString:self.addressUrl] isPhone:NO completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        });

        if (nil == error) {
            NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            // 解析html
            [weakSelf paraseHtmlString_address:htmlString];
        }
    }];
}

- (void)paraseHtmlString_address:(NSString *)htmlString {

    if (htmlString.length == 0) { return; }

    OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];

    OCGumboElement *methodDivE = document.QueryClass(@"method").firstObject;
    OCGumboElement *aE = document.QueryClass(@"panel").firstObject;
    if (methodDivE == nil || aE == nil) {
        return;
    }
    NSString *text = methodDivE.QueryElement(@"span").first().text();
    NSString *url = aE.attr(@"href");
    NSString *host = aE.text();

    MJWeakSelf
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.addressLabel.text = [NSString stringWithFormat:@"%@\n%@", text, url];
        [MBProgressHUD showInfoOnView:weakSelf.view WithStatus:@"已获取最新地址"];
        weakSelf.sourceModel.title = text;
        weakSelf.sourceModel.HOST_URL = host;
        [AppTool sharedAppTool].HOST_URL = host;
        weakSelf.sourceModel.sourceType = 4;
        weakSelf.sourceModel.url = url;
        [weakSelf.sourceModel insertTable];

        weakSelf.tagsAddressUrl = [host stringByAppendingPathComponent:@"tags.php"];
        [weakSelf loadAllTags];
    });

}

#pragma mark request tags

- (void)loadAllTags {

    if (self.tagsAddressUrl.length == 0) {
        return;
    }
    MJWeakSelf
    [PDRequest getWithURL:[NSURL URLWithString:self.tagsAddressUrl] isPhone:NO completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (nil == error) {
            NSString *htmlString = [AppTool getStringWithGB_18030_2000Code:data];

            // 解析html
            [weakSelf paraseHtmlString_tags:htmlString];
        }
    }];
}

- (void)paraseHtmlString_tags:(NSString *)htmlString {

    if (htmlString.length == 0) { return; }

    OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];

    OCQueryObject *tagsListEs = document.QueryClass(@"tags_list");

    NSMutableArray *classModels = [NSMutableArray array];
    for (OCGumboElement *tagsListE in tagsListEs) {

        NSString *title = tagsListE.QueryElement(@"dt").first().QueryElement(@"strong").first().text();

        OCQueryObject *aEs = tagsListE.QueryElement(@"dd").first().QueryElement(@"a");

        NSMutableArray *subTitles = [NSMutableArray array];
        for (OCGumboElement *aE in aEs) {
            NSString *href = aE.attr(@"href");
            NSString *subTitle = aE.text();

            PicSourceModel *sourceModel = [[PicSourceModel alloc] init];
            sourceModel.sourceType = 4;
            sourceModel.url = [self.sourceModel.HOST_URL stringByAppendingPathComponent:href];
            sourceModel.title = subTitle;
            sourceModel.HOST_URL = self.sourceModel.HOST_URL;
            [sourceModel insertTable];

            [subTitles addObject:sourceModel];
        }

        PicClassModel *classModel = [PicClassModel modelWithHOST_URL:self.sourceModel.HOST_URL Title:title sourceType:@"4" subTitles:subTitles];
        [classModels addObject:classModel];
    }

    MJWeakSelf
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tableView reloadDataWithSource:classModels];
    });
}

- (void)toViewDetails {
    ContentViewController *contentVC = [[ContentViewController alloc] initWithSourceModel:self.sourceModel];
    [self.navigationController pushViewController:contentVC animated:YES];
}

- (void)searchBtnClickedAction:(UIButton *)sender {

    [self.view endEditing:YES];

    if (self.searchTF.text.length == 0) {
        [self toViewDetails];
        return;
    }

    PicSourceModel *sourceModel = self.sourceModel.copy;
    NSString *valueString = [self.searchTF.text stringByAddingPercentEscapesUsingEncoding:[AppTool getNSStringEncoding_GB_18030_2000]];
    sourceModel.url = [NSString stringWithFormat:@"%@?keyword=%@", self.searchAddressUrl, valueString];
    ContentViewController *contentVC = [[ContentViewController alloc] initWithSourceModel:sourceModel];
    [self.navigationController pushViewController:contentVC animated:YES];
}

- (void)shareUrl:(UIButton *)sender {

    if (self.sourceModel.url.length == 0) {
        [MBProgressHUD showInfoOnView:self.view WithStatus:@"请先获取地址"];
        return;
    }

    [AppTool shareFileWithURLs:@[[NSURL URLWithString:self.sourceModel.url]] sourceView:sender completionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        NSLog(@"调用分享的应用id :%@", activityType);
        if (completed) {
            NSLog(@"分享成功!");
        } else {
            NSLog(@"分享失败!");
        }
    }];
}

#pragma mark PicClassifyTableViewActionDelegate
-  (void)tableView:(PicClassifyTableView *)tableView didSelectActionAtIndexPath:(NSIndexPath *)indexPath withClassModel:(PicClassModel *)classModel {
    PicSourceModel *sourceModel = classModel.subTitles[indexPath.row];
    [sourceModel insertTable];

    ContentViewController *contentVC = [[ContentViewController alloc] initWithSourceModel:sourceModel];
    [self.navigationController pushViewController:contentVC animated:YES];
}

@end
